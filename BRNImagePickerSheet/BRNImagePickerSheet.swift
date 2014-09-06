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
    
    optional func willPresentImagePickerSheet(imagePickerSheet: BRNImagePickerSheet)
    optional func didPresentImagePickerSheet(imagePickerSheet: BRNImagePickerSheet)
    
    optional func imagePickerSheet(imagePickerSheet: BRNImagePickerSheet, willDismissWithButtonIndex buttonIndex: Int)
    optional func imagePickerSheet(imagePickerSheet: BRNImagePickerSheet, didDismissWithButtonIndex buttonIndex: Int)
}

class BRNImagePickerSheet: UIView, UITableViewDataSource, UITableViewDelegate, BRNImagePreviewCellDelegate {
    
    private let overlayView = UIView()
    private let tableView = UITableView()
    
    var delegate: BRNImagePickerSheetDelegate?
    private var photos = [UIImage]()
    private var selectedPhotos = [UIImage]()
    private var previewsPhotos: Bool {
        return (self.photos.count > 0)
    }
    
    var cancelButtonIndex: Int {
        let lastIndex = self.tableView.numberOfRowsInSection(0) - 1
        if self.previewsPhotos {
            return lastIndex - 1
        }
            
        return lastIndex
    }
    
    private var titles: [NSString] {
        return ["Photo Library", "Take Photo or Video", "Cancel"]
    }
    
    private var enlargedPreviews = false
    
    private class var animationDuration: Double {
        return 0.3
    }
    
    // MARK: Initialization
    
    override init() {
        super.init(frame: CGRectZero)
        
        let tapRecognizer = UITapGestureRecognizer()
        tapRecognizer.addTarget(self, action: "overlayViewWasTapped:")
        self.overlayView.addGestureRecognizer(tapRecognizer)
        self.overlayView.backgroundColor = UIColor(white: 0.0, alpha: 0.3)
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
                        let representation: ALAssetRepresentation = asset.defaultRepresentation()
                        let photo = UIImage(CGImage: representation.fullResolutionImage().takeUnretainedValue())
                        self.photos.append(photo)
                    }
                })
                
                self.tableView.reloadData()
            }
        }, failureBlock:nil)
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
                    return 200.0
                }
                
                return 100.0
            }
        }
        
        return self.tableView.rowHeight
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.row == 0 && self.previewsPhotos {
            let cell = BRNImagePreviewCell(style: UITableViewCellStyle.Default , reuseIdentifier: "Cell")
            cell.delegate = self
            cell.photos = self.photos
            
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
            self.dismissWithClickedButtonIndex(buttonIndex, animated: true)
        }
    }
    
    // MARK: - BRNImagePreviewCellDelegate
    
    func imagePreviewCell(imagePreviewCell: BRNImagePreviewCell, didSelectImageAtIndex imageIndex: Int) {
        self.enlargedPreviews = true
        self.tableView.reloadData()
        self.setNeedsLayout()
        
        self.selectedPhotos.append(self.photos[imageIndex])
    }
    
    func imagePreviewCell(imagePreviewCell: BRNImagePreviewCell, didDeselectImageAtIndex imageIndex: Int) {
        self.selectedPhotos.removeAtIndex(find(self.photos, self.photos[imageIndex])!)
    }
    
    // MARK: - Presentation
    
    func showInView(view: UIView) {
        self.frame = view.bounds
        view.addSubview(self)
    
        let originalTableViewOffset = CGRectGetMinY(self.tableView.frame)
        self.tableView.frame.origin.y = CGRectGetHeight(self.bounds)
        self.overlayView.alpha = 0.0
        
        self.delegate?.willPresentImagePickerSheet?(self)

        UIView.animateWithDuration(BRNImagePickerSheet.animationDuration, animations: { () -> Void in
            self.tableView.frame.origin.y = originalTableViewOffset
            self.overlayView.alpha = 1.0
            }, completion: { (finished: Bool) -> Void in
                self.delegate?.didPresentImagePickerSheet?(self)
            println("finished")
        })
    }
    
    func dismissWithClickedButtonIndex(buttonIndex: Int, animated: Bool) {
        self.delegate?.imagePickerSheet?(self, willDismissWithButtonIndex: buttonIndex)
        
        let duration = (animated) ? BRNImagePickerSheet.animationDuration : 0.0
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
        
        self.tableView.frame.size = CGSizeMake(CGRectGetWidth(bounds), self.tableView.contentSize.height)
        self.tableView.frame.origin.y = CGRectGetMaxY(bounds)-CGRectGetHeight(self.tableView.frame)
    }
    
}

@objc protocol BRNImagePreviewCellDelegate {
    
    optional func imagePreviewCell(imagePreviewCell: BRNImagePreviewCell, didSelectImageAtIndex imageIndex: Int)
    
    optional func imagePreviewCell(imagePreviewCell: BRNImagePreviewCell, didDeselectImageAtIndex imageIndex: Int)

}

class BRNImagePreviewCell : UITableViewCell, UICollectionViewDataSource, UICollectionViewDelegate {
    
    private let collectionView: UICollectionView
    
    var delegate: BRNImagePreviewCellDelegate?
    var photos = [UIImage]()
    private var sections = [Int: BRNImageSupplementaryView]()
    
    private class var sectionInset: UIEdgeInsets {
        return UIEdgeInsetsMake(4.0, 0.0, 4.0, -16.0)
    }
    
    private class var contentInset: UIEdgeInsets {
        return UIEdgeInsetsMake(0.0, 4.0, 0.0, 4.0)
    }
    
    // MARK: Initialization
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .Horizontal
        layout.sectionInset = BRNImagePreviewCell.sectionInset
        layout.footerReferenceSize = CGSizeMake(20.0, 100)
        self.collectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: layout)
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.contentInset = BRNImagePreviewCell.contentInset
        self.collectionView.backgroundColor = UIColor.clearColor()
        self.collectionView.showsHorizontalScrollIndicator = false
        self.collectionView.alwaysBounceHorizontal = true
        self.collectionView.registerClass(BRNImageCollectionViewCell.classForCoder(), forCellWithReuseIdentifier: "Cell")
        self.collectionView.registerClass(BRNImageSupplementaryView.classForCoder(), forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: "SupplementaryView")
        self.addSubview(self.collectionView)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
    
    func collectionView(collectionView: UICollectionView, layout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let photo = self.photos[indexPath.section]
        let height = CGRectGetHeight(self.frame) - BRNImagePreviewCell.sectionInset.top - BRNImagePreviewCell.sectionInset.bottom
        let factor = height / photo.size.height
        
        return CGSizeMake(factor * photo.size.width, height)
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        let view: BRNImageSupplementaryView = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionFooter, withReuseIdentifier: "SupplementaryView", forIndexPath: indexPath) as BRNImageSupplementaryView
        view.userInteractionEnabled = false
        
        self.sections[indexPath.section] = view
        return view
    }
    
    // MARK: - UICollectionViewDelegate
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let possibleView = self.sections[indexPath.section]
        if let view = possibleView {
            view.selected = true
        }
        
        self.delegate?.imagePreviewCell?(self, didSelectImageAtIndex: indexPath.section)
    }
    
    func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        let possibleView = self.sections[indexPath.section]
        if let view = possibleView {
            view.selected = false
        }
        
        self.delegate?.imagePreviewCell?(self, didDeselectImageAtIndex: indexPath.section)
    }

    // MARK: - Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.collectionView.frame = self.bounds
    }

}

class BRNImageCollectionViewCell : UICollectionViewCell {
    
    let imageView = UIImageView()
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.addSubview(imageView)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.imageView.frame = self.bounds
    }
}

class BRNImageSupplementaryView : UICollectionReusableView {
    
    private let button = UIButton()
    
    var selected: Bool = false {
        didSet {
            self.button.selected = self.selected
            self.button.backgroundColor = (self.selected) ? self.tintColor : nil
        }
    }
    
    private class var checkmarkImage: UIImage {
        return UIImage(named: "BRNImagePickerSheet-checkmark").imageWithRenderingMode(.AlwaysTemplate)
    }
    
    private class var selectedCheckmarkImage: UIImage {
        return UIImage(named: "BRNImagePickerSheet-checkmark-selected").imageWithRenderingMode(.AlwaysTemplate)
    }
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.button.tintColor = UIColor.whiteColor()
        self.button.setImage(BRNImageSupplementaryView.checkmarkImage, forState: .Normal)
        self.button.setImage(BRNImageSupplementaryView.selectedCheckmarkImage, forState: .Selected)
        self.addSubview(self.button)
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.button.sizeToFit()
        self.button.frame.origin.y = CGRectGetHeight(self.bounds)-CGRectGetHeight(self.button.frame)-20
        self.button.layer.cornerRadius = CGRectGetHeight(self.button.frame) / 2.0
    }
    
}
