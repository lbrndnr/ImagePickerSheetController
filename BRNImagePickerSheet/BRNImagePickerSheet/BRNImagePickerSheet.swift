//
//  BRNImagePickerSheet.swift
//  BRNImagePickerSheet
//
//  Created by Laurin Brandner on 04/09/14.
//  Copyright (c) 2014 Laurin Brandner. All rights reserved.
//

import UIKit
import AssetsLibrary

extension UIImageOrientation {
    init(_ value: ALAssetOrientation) {
        switch value {
        case .Up:
            self = .Up
        case .Down:
            self = .Down
        case .Left:
            self = .Left
        case .Right:
            self = .Right
        case .UpMirrored:
            self = .UpMirrored
        case .DownMirrored:
            self = DownMirrored
        case .LeftMirrored:
            self = .LeftMirrored
        case .RightMirrored:
            self = .RightMirrored
        }
    }
}

@objc protocol BRNImagePickerSheetDelegate {
    optional func imagePickerSheet(imagePickerSheet: BRNImagePickerSheet, clickedButtonAtIndex buttonIndex: Int)
    optional func imagePickerSheetCancel(imagePickerSheet: BRNImagePickerSheet)
    // TODO: Call cancel delegate method
    
    optional func willPresentImagePickerSheet(imagePickerSheet: BRNImagePickerSheet)
    optional func didPresentImagePickerSheet(imagePickerSheet: BRNImagePickerSheet)
    
    optional func imagePickerSheetWillEnlargePreviews(imagePickerSheet: BRNImagePickerSheet)
    optional func imagePickerSheetDidEnlargePreviews(imagePickerSheet: BRNImagePickerSheet)
    
    optional func imagePickerSheet(imagePickerSheet: BRNImagePickerSheet, willDismissWithButtonIndex buttonIndex: Int)
    optional func imagePickerSheet(imagePickerSheet: BRNImagePickerSheet, didDismissWithButtonIndex buttonIndex: Int)
}

class BRNImagePickerSheet: UIView, UITableViewDataSource, UITableViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    private let overlayView = UIView()
    private let tableView = UITableView()
    private let collectionView = BRNImagePickerCollectionView()
    
    var enlargedPreviews = false
    var delegate: BRNImagePickerSheetDelegate?
    private var photos = [UIImage]()
    private var selectedPhotoIndices = [Int]()
    private var previewsPhotos: Bool {
        return (self.photos.count > 0)
    }
    private var supplementaryViews = [Int: BRNImageSupplementaryView]()
    
    var cancelButtonIndex: Int {
        let lastRow = self.tableView.numberOfRowsInSection(0) - 1
        return self.buttonIndexForRow(lastRow)
    }
    
    var selectedPhotos: [UIImage] {
        get {
            var selectedPhotos = [UIImage]()
            for index in self.selectedPhotoIndices {
                selectedPhotos.append(self.photos[index])
            }
            
            return selectedPhotos
        }
    }
    
    var numberOfButtons: Int {
        get {
           return self.titles.count
        }
    }
    
    var showsSecondaryTitles: Bool {
        get {
            return (self.selectedPhotoIndices.count > 0)
        }
    }
    var showsPluralSecondaryTitles: Bool {
        get {
            return (self.selectedPhotoIndices.count > 1)
        }
    }
    
    private var titles: [(title: String, singularSecondaryTitle: String?, pluralSecondaryTitle: String?)] = [("Cancel", nil, nil)]
    
    class var selectedPhotoCountPlaceholder: String {
        return "[ch.laurinbrandner.BRNImagePickerSheet.placeholder]"
    }
    
    private class var presentationAnimationDuration: Double {
        return 0.3
    }
    private class var enlargementAnimationDuration: Double {
        return 0.3
    }
    private class var tableViewRowHeight: CGFloat {
        return 50.0
    }
    private class var tableViewPreviewRowHeight: CGFloat {
        return 140.0
    }
    private class var tableViewEnlargedPreviewRowHeight: CGFloat {
        return 243.0
    }
    private class var collectionViewInset: CGFloat {
        return 5.0
    }
    private class var collectionViewCheckmarkInset: CGFloat {
        return 3.5
    }
    
    // MARK: Initialization
    
    override init() {
        super.init(frame: CGRectZero)
        
        let tapRecognizer = UITapGestureRecognizer()
        tapRecognizer.addTarget(self, action: "overlayViewWasTapped:")
        self.overlayView.addGestureRecognizer(tapRecognizer)
        self.overlayView.backgroundColor = UIColor(white: 0.0, alpha: 0.3961)
        self.addSubview(self.overlayView)
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.alwaysBounceVertical = false
        self.addSubview(self.tableView)
        
        let inset = BRNImagePickerSheet.collectionViewInset
        self.collectionView.horizontalImagePreviewLayout.sectionInset = UIEdgeInsetsMake(inset, inset, inset, inset)
        self.collectionView.horizontalImagePreviewLayout.showsSupplementaryViews = false
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.backgroundColor = UIColor.clearColor()
        self.collectionView.showsHorizontalScrollIndicator = false
        self.collectionView.alwaysBounceHorizontal = true
        self.collectionView.registerClass(BRNImageCollectionViewCell.classForCoder(), forCellWithReuseIdentifier: "Cell")
        self.collectionView.registerClass(BRNImageSupplementaryView.classForCoder(), forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: "SupplementaryView")
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UITableViewDataSource
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let numberOfTitles = self.titles.count
        if self.previewsPhotos {
            return numberOfTitles + 1
        }
        
        return numberOfTitles
    }
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if self.previewsPhotos {
            if indexPath.row == 0 {
                if (self.enlargedPreviews) {
                    return BRNImagePickerSheet.tableViewEnlargedPreviewRowHeight
                }
                
                return BRNImagePickerSheet.tableViewPreviewRowHeight
            }
        }
        
        return BRNImagePickerSheet.tableViewRowHeight
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.row == 0 && self.previewsPhotos {
            let cell = BRNImagePreviewTableViewCell(style: UITableViewCellStyle.Default , reuseIdentifier: "Cell")
            cell.collectionView = self.collectionView
            
            return cell
        }
        
        let cell = UITableViewCell(style: UITableViewCellStyle.Default , reuseIdentifier: "Cell")
        cell.textLabel.textAlignment = .Center
        cell.textLabel.textColor = self.tintColor
        cell.textLabel.font = UIFont.systemFontOfSize(21)
        
        let buttonIndex = self.buttonIndexForRow(indexPath.row)
        let (title, singularSecondaryTitle, pluralSecondaryTitle) = self.titles[buttonIndex]
        var cellTitle = title
        if self.showsSecondaryTitles {
            let photoCountString = String(self.selectedPhotos.count)
            if self.showsPluralSecondaryTitles && pluralSecondaryTitle != nil {
                if let secondaryTitle = pluralSecondaryTitle {
                    cellTitle = secondaryTitle
                }
            }
            else {
                if let secondaryTitle = singularSecondaryTitle {
                    cellTitle = secondaryTitle
                }
            }
            
            cellTitle = cellTitle.stringByReplacingOccurrencesOfString(BRNImagePickerSheet.selectedPhotoCountPlaceholder, withString: photoCountString, options: .LiteralSearch, range:nil)
        }
        
        cell.textLabel.text = cellTitle
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return !(self.previewsPhotos && indexPath.row == 0)
    }
    
    func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        var handle = true
        if self.previewsPhotos {
            if indexPath.row == 0 {
                handle = false
            }
        }
        
        if handle {
            let buttonIndex = self.buttonIndexForRow(indexPath.row)
            
            self.delegate?.imagePickerSheet?(self, clickedButtonAtIndex: buttonIndex)
            self.dismissWithClickedButtonIndex(buttonIndex, animated: true)
        }
    }
    
    // MARK: - UICollectionViewDataSource
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return self.photos.count
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell: BRNImageCollectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as BRNImageCollectionViewCell
        cell.imageView.image = self.photos[indexPath.section]
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        let view: BRNImageSupplementaryView = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier: "SupplementaryView", forIndexPath: indexPath) as BRNImageSupplementaryView
        view.userInteractionEnabled = false
        view.buttonInset = UIEdgeInsetsMake(0.0, BRNImagePickerSheet.collectionViewCheckmarkInset, BRNImagePickerSheet.collectionViewCheckmarkInset, 0.0)
        view.selected = contains(self.selectedPhotoIndices, indexPath.section)
        
        self.supplementaryViews[indexPath.section] = view
        
        return view
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    func collectionView(collectionView: UICollectionView, layout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let photo = self.photos[indexPath.section]
        let height = self.tableView(self.tableView, heightForRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 0)) - 2.0 * BRNImagePickerSheet.collectionViewInset
        let factor = height / photo.size.height
        
        return CGSizeMake(factor * photo.size.width, height)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let inset = 2.0 * BRNImagePickerSheet.collectionViewCheckmarkInset
        let size = self.collectionView(collectionView, layout: collectionViewLayout, sizeForItemAtIndexPath: NSIndexPath(forRow: 0, inSection: section))
        return CGSizeMake(BRNImageSupplementaryView.checkmarkImage.size.width + inset, size.height)
    }
    
    // MARK: - UICollectionViewDelegate
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let selected = contains(self.selectedPhotoIndices, indexPath.section)
        
        if !selected {
            self.selectedPhotoIndices.append(indexPath.section)
            
            if !self.enlargedPreviews {
                self.delegate?.imagePickerSheetWillEnlargePreviews?(self)
                self.enlargedPreviews = true
                
                let layout: BRNHorizontalImagePreviewFlowLayout = self.collectionView.collectionViewLayout as BRNHorizontalImagePreviewFlowLayout
                layout.invalidationCenteredIndexPath = indexPath
                
                self.setNeedsLayout()
                UIView.animateWithDuration(BRNImagePickerSheet.enlargementAnimationDuration, animations: { () -> Void in
                    self.tableView.beginUpdates()
                    self.tableView.endUpdates()
                    self.layoutIfNeeded()
                    }, completion: { (finished) -> Void in
                        self.reloadButtonTitles()
                        layout.showsSupplementaryViews = true
                        self.delegate?.imagePickerSheetDidEnlargePreviews?(self)
                })
            }
            else {
                let possibleCell = collectionView.cellForItemAtIndexPath(indexPath)
                if let cell = possibleCell {
                    var contentOffset = CGPointMake(cell.frame.midX - collectionView.frame.width / 2.0, 0.0)
                    contentOffset.x = max(contentOffset.x, -collectionView.contentInset.left)
                    contentOffset.x = min(contentOffset.x, collectionView.contentSize.width - collectionView.frame.width + collectionView.contentInset.right)
                    
                    collectionView.setContentOffset(contentOffset, animated: true)
                }
                
                self.reloadButtonTitles()
            }
        }
        else {
            self.selectedPhotoIndices.removeAtIndex(find(self.selectedPhotoIndices, indexPath.section)!)
            self.reloadButtonTitles()
        }
        
        if let sectionView = self.supplementaryViews[indexPath.section] {
            sectionView.selected = !selected
        }
    }
    
    // MARK: - Presentation
    
    func showInView(view: UIView) {
        if view.superview == nil {
            return
        }
        
        self.delegate?.willPresentImagePickerSheet?(self)
        
        var show: () {
            self.frame = view.frame
            view.superview!.addSubview(self)
                
            let originalTableViewOffset = CGRectGetMinY(self.tableView.frame)
            self.tableView.frame.origin.y = CGRectGetHeight(self.bounds)
            self.overlayView.alpha = 0.0
            
            UIView.animateWithDuration(BRNImagePickerSheet.presentationAnimationDuration, animations: { () -> Void in
                self.tableView.frame.origin.y = originalTableViewOffset
                self.overlayView.alpha = 1.0
                }, completion: { (finished: Bool) -> Void in
                    // Known issue, closures require more than one line or an explicit return. Will fix this whenever possible
                    self.delegate?.didPresentImagePickerSheet?(self)
                    return
            })
        }
        
        let library = ALAssetsLibrary()
        library.enumerateGroupsWithTypes((1 << 4), usingBlock: { (group: ALAssetsGroup!, stop: UnsafeMutablePointer<ObjCBool>) -> Void in
            if group != nil {
                group.setAssetsFilter(ALAssetsFilter.allPhotos())
                group.enumerateAssetsUsingBlock({ (asset: ALAsset!, index: Int, stop: UnsafeMutablePointer<ObjCBool>) -> Void in
                    if asset != nil {
                        let representation: ALAssetRepresentation = asset.defaultRepresentation()
                        let orientation = UIImageOrientation(representation.orientation())
                        let photo = UIImage(CGImage: representation.fullResolutionImage().takeUnretainedValue(), scale: CGFloat(representation.scale()), orientation: orientation)
                        self.photos.insert(photo!, atIndex: 0)
                    }
                })
                
                self.tableView.reloadData()
            }
            show
        }) { (error) -> Void in
            show
        }
    }
    
    func dismissWithClickedButtonIndex(buttonIndex: Int, animated: Bool) {
        self.delegate?.imagePickerSheet?(self, willDismissWithButtonIndex: buttonIndex)
        
        let duration = (animated) ? BRNImagePickerSheet.presentationAnimationDuration : 0.0
        UIView.animateWithDuration(duration, animations: { () -> Void in
            self.overlayView.alpha = 0.0
            self.tableView.frame.origin.y += CGRectGetHeight(self.tableView.frame)
            }, completion: { (finished: Bool) -> Void in
                self.delegate?.imagePickerSheet?(self, didDismissWithButtonIndex: buttonIndex)
                self.removeFromSuperview()
        })
    }
    
    // MARK: - Other Methods
    
    func buttonIndexForRow(row: Int) -> Int {
        var buttonIndex = row
        if self.previewsPhotos {
            --buttonIndex
        }
        
        // TODO: Why is endIndex not working?
        
        return self.titles.count - 1 - buttonIndex
    }
    
    func reloadButtonTitles() {
        var indexPaths = [NSIndexPath]()
        for row in 0 ..< self.titles.count {
            indexPaths.append(NSIndexPath(forRow: self.buttonIndexForRow(row), inSection: 0))
        }
        
        self.tableView.reloadRowsAtIndexPaths(indexPaths, withRowAnimation: .None)
    }
    
    func addButtonWithTitle(title: String, singularSecondaryTitle: String?, pluralSecondaryTitle: String?) -> Int {
        self.titles.append(title: title, singularSecondaryTitle: singularSecondaryTitle, pluralSecondaryTitle: pluralSecondaryTitle)
        
        return self.titles.endIndex
    }
    
    func buttonTitlesAtIndex(buttonIndex: Int) -> (String, String?, String?) {
        return self.titles[buttonIndex]
    }
    
    func overlayViewWasTapped(gestureRecognizer: UITapGestureRecognizer) {
        self.dismissWithClickedButtonIndex(self.cancelButtonIndex, animated: true)
    }
    
    // MARK: - Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        var bounds = self.bounds
        
        self.overlayView.frame = bounds
        
        var tableViewHeight: CGFloat = 0.0
        for var row = 0; row < self.tableView.numberOfRowsInSection(0); ++row {
            tableViewHeight += self.tableView(self.tableView, heightForRowAtIndexPath: NSIndexPath(forRow: row, inSection: 0))
        }
        
        self.tableView.frame.size = CGSizeMake(CGRectGetWidth(bounds), tableViewHeight)
        self.tableView.frame.origin.y = CGRectGetMaxY(bounds)-CGRectGetHeight(self.tableView.frame)
    }
    
}
