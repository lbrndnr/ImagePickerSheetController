//
//  BRNImagePickerSheet.swift
//  BRNImagePickerSheet
//
//  Created by Laurin Brandner on 04/09/14.
//  Copyright (c) 2014 Laurin Brandner. All rights reserved.
//

import UIKit
import AssetsLibrary

@objc protocol BRNImagePickerSheetDelegate {
    optional func imagePickerSheet(imagePickerSheet: BRNImagePickerSheet, clickedButtonAtIndex buttonIndex: Int)
    optional func imagePickerSheetCancel(imagePickerSheet: BRNImagePickerSheet)
    // TODO: Call cancel delegate method
    
    optional func willPresentImagePickerSheet(imagePickerSheet: BRNImagePickerSheet)
    optional func didPresentImagePickerSheet(imagePickerSheet: BRNImagePickerSheet)
    
    optional func imagePickerSheet(imagePickerSheet: BRNImagePickerSheet, willDismissWithButtonIndex buttonIndex: Int)
    optional func imagePickerSheet(imagePickerSheet: BRNImagePickerSheet, didDismissWithButtonIndex buttonIndex: Int)
}

class BRNImagePickerSheet: UIView, UITableViewDataSource, UITableViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    private let overlayView = UIView()
    private let tableView = UITableView()
    private let collectionView: BRNImagePickerCollectionView
    
    var delegate: BRNImagePickerSheetDelegate?
    private var photos = [UIImage]()
    private var selectedPhotoIndices = [Int]()
    private var previewsPhotos: Bool {
        return (self.photos.count > 0)
    }
    private var supplementaryViews = [Int: BRNImageSupplementaryView]()
    
    var cancelButtonIndex: Int {
        let lastIndex = self.tableView.numberOfRowsInSection(0) - 1
        if self.previewsPhotos {
            return lastIndex - 1
        }
            
        return lastIndex
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
    
    private var titles: [NSString] {
        return ["Photo Library", "Take Photo or Video", "Cancel"]
    }
    
    private var enlargedPreviews = false
    
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
        let inset = BRNImagePickerSheet.collectionViewInset
        let layout = BRNHorizontalImagePreviewFlowLayout()
        layout.showsSupplementaryViews = false
        layout.sectionInset = UIEdgeInsetsMake(inset, inset, inset, inset)
        self.collectionView = BRNImagePickerCollectionView(frame: CGRectZero, collectionViewLayout: layout)
        
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
        
        let library = ALAssetsLibrary()
        library.enumerateGroupsWithTypes((1 << 4), usingBlock: { (group: ALAssetsGroup!, stop: UnsafeMutablePointer<ObjCBool>) -> Void in
            if group != nil {
                group.setAssetsFilter(ALAssetsFilter.allPhotos())
                group.enumerateAssetsUsingBlock({ (asset: ALAsset!, index: Int, stop: UnsafeMutablePointer<ObjCBool>) -> Void in
                    if asset != nil {
                        // TODO: Rotate CGImage properly
                        
                        let representation: ALAssetRepresentation = asset.defaultRepresentation()
                        let photo = UIImage(CGImage: representation.fullResolutionImage().takeUnretainedValue())
                        self.photos.insert(photo, atIndex: 0)
                    }
                })
                
                self.tableView.reloadData()
            }
        }, failureBlock:nil)
        
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
        
        var titleIndex = indexPath.row
        if self.previewsPhotos {
            --titleIndex
        }
        
        let cell = UITableViewCell(style: UITableViewCellStyle.Default , reuseIdentifier: "Cell")
        cell.textLabel!.textAlignment = .Center
        cell.textLabel!.textColor = self.tintColor
        cell.textLabel!.text = self.titles[titleIndex]
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return !(self.previewsPhotos && indexPath.row == 0)
    }
    
    func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        var buttonIndex = indexPath.row
        var dismiss = true
        if self.previewsPhotos {
            --buttonIndex
            dismiss = (indexPath.row != 0)
        }
        
        if dismiss {
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
        var scrolled = false
        
        if !self.enlargedPreviews {
            self.enlargedPreviews = true
            
            self.setNeedsLayout()
            UIView.animateWithDuration(BRNImagePickerSheet.enlargementAnimationDuration*5, animations: { () -> Void in
                self.tableView.beginUpdates()
                self.tableView.endUpdates()
                self.layoutIfNeeded()
                //self.collectionView.scrollToItemAtIndexPath(indexPath, atScrollPosition: .CenteredHorizontally, animated: false)
                scrolled = true
                }, completion: { (finished) -> Void in
                    let layout: BRNHorizontalImagePreviewFlowLayout = self.collectionView.collectionViewLayout as BRNHorizontalImagePreviewFlowLayout
                    layout.showsSupplementaryViews = true
            })
        }
        
        if selected {
            self.selectedPhotoIndices.removeAtIndex(find(self.selectedPhotoIndices, indexPath.section)!)
        }
        else {
            self.selectedPhotoIndices.append(indexPath.section)
            if !scrolled {
                self.collectionView.scrollToItemAtIndexPath(indexPath, atScrollPosition: .CenteredHorizontally, animated: true)
            }
        }
        
        if let sectionView = self.supplementaryViews[indexPath.section] {
            sectionView.selected = !selected
        }
    }
    
    // MARK: - Presentation
    
    func showInView(view: UIView) {
        self.frame = view.bounds
        view.addSubview(self)
    
        let originalTableViewOffset = CGRectGetMinY(self.tableView.frame)
        self.tableView.frame.origin.y = CGRectGetHeight(self.bounds)
        self.overlayView.alpha = 0.0
        
        self.delegate?.willPresentImagePickerSheet?(self)

        UIView.animateWithDuration(BRNImagePickerSheet.presentationAnimationDuration, animations: { () -> Void in
            self.tableView.frame.origin.y = originalTableViewOffset
            self.overlayView.alpha = 1.0
            }, completion: { (finished: Bool) -> Void in
            self.delegate?.didPresentImagePickerSheet?(self)
            println("finished")
        })
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
