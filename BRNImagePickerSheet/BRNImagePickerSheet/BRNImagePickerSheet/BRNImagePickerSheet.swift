//
//  BRNImagePickerSheet.swift
//  BRNImagePickerSheet
//
//  Created by Laurin Brandner on 04/09/14.
//  Copyright (c) 2014 Laurin Brandner. All rights reserved.
//

import UIKit
import Photos

private let sheetCellIdentifier = "SheetCell"
private let previewCellIdentifier = "PreviewCell"
private let imageCellIdentifier = "ImageCell"
private let imageSupplementaryViewIdentifier = "ImageSupplementaryView"

private let presentationAnimationDuration = 0.3
private let enlargementAnimationDuration = 0.3
private let tableViewRowHeight: CGFloat = 50.0
private let tableViewPreviewRowHeight: CGFloat = 140.0
private let tableViewEnlargedPreviewRowHeight: CGFloat = 243.0
private let collectionViewInset: CGFloat = 5.0
private let collectionViewCheckmarkInset: CGFloat = 3.5

@objc public protocol BRNImagePickerSheetDelegate {
    func imagePickerSheet(imagePickerSheet: BRNImagePickerSheet, titleForButtonAtIndex buttonIndex: Int) -> String
    
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

public class BRNImagePickerSheet: UIView, UITableViewDataSource, UITableViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    private let overlayView = UIView()
    private let tableView = UITableView()
    private let collectionView = BRNImagePickerCollectionView()
    
    private(set) var enlargedPreviews = false
    public var delegate: BRNImagePickerSheetDelegate?
    private var assets = [PHAsset]()
    private var selectedPhotoIndices = [Int]()
    private var previewsPhotos: Bool {
        return (self.assets.count > 0)
    }
    private var supplementaryViews = [Int: BRNImageSupplementaryView]()
    
    public var cancelButtonIndex: Int {
        let lastRow = self.tableView.numberOfRowsInSection(0) - 1
        return self.buttonIndexForRow(lastRow)
    }
    
    public var numberOfSelectedPhotos: Int {
        return self.selectedPhotoIndices.count
    }
    
    public var numberOfButtons: Int = 1 {
        didSet {
            numberOfButtons = max(numberOfButtons, 1)
        }
    }

    private var firstButtonIndex: Int {
        return self.previewsPhotos ? 1 : 0
    }
    
    private let imageManager = PHCachingImageManager()
    
    private var titles: [(title: String, singularSecondaryTitle: String?, pluralSecondaryTitle: String?)] = [(NSLocalizedString("Cancel", comment: "Cancel"), nil, nil)]
    
    // MARK: Initialization
    
    public override init() {
        super.init(frame: CGRectZero)
        
        self.setup()
    }
    
    public required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.setup()
    }
    
    private func setup() {
        let tapRecognizer = UITapGestureRecognizer()
        tapRecognizer.addTarget(self, action: Selector("overlayViewWasTapped:"))
        self.overlayView.addGestureRecognizer(tapRecognizer)
        self.overlayView.backgroundColor = UIColor(white: 0.0, alpha: 0.3961)
        self.addSubview(self.overlayView)
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.alwaysBounceVertical = false
        self.tableView.registerClass(BRNImagePreviewTableViewCell.self, forCellReuseIdentifier: previewCellIdentifier)
        self.tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: sheetCellIdentifier)
        self.addSubview(self.tableView)
        
        self.collectionView.horizontalImagePreviewLayout.sectionInset = UIEdgeInsetsMake(collectionViewInset, collectionViewInset, collectionViewInset, collectionViewInset)
        self.collectionView.horizontalImagePreviewLayout.showsSupplementaryViews = false
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.backgroundColor = UIColor.clearColor()
        self.collectionView.showsHorizontalScrollIndicator = false
        self.collectionView.alwaysBounceHorizontal = true
        self.collectionView.registerClass(BRNImageCollectionViewCell.self, forCellWithReuseIdentifier: imageCellIdentifier)
        self.collectionView.registerClass(BRNImageSupplementaryView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: imageSupplementaryViewIdentifier)
    }
    
    // MARK: - UITableViewDataSource
    
    public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var numberOfRows = self.numberOfButtons
        if self.previewsPhotos {
            numberOfRows += 1
        }
        
        return numberOfRows
    }
    
    public func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if self.previewsPhotos {
            if indexPath.row == 0 {
                if (self.enlargedPreviews) {
                    return tableViewEnlargedPreviewRowHeight
                }
                
                return tableViewPreviewRowHeight
            }
        }
        
        return tableViewRowHeight
    }
    
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.row == 0 && self.previewsPhotos {
            let cell = tableView.dequeueReusableCellWithIdentifier(previewCellIdentifier, forIndexPath: indexPath) as BRNImagePreviewTableViewCell
            cell.collectionView = self.collectionView
            
            return cell
        }
        
        let cell = tableView.dequeueReusableCellWithIdentifier(sheetCellIdentifier, forIndexPath: indexPath) as UITableViewCell
        cell.textLabel?.textAlignment = .Center
        cell.textLabel?.textColor = self.tintColor
        cell.textLabel?.font = UIFont.systemFontOfSize(21)
        
        let buttonIndex = self.buttonIndexForRow(indexPath.row)
        let buttonTitle: String? = {
            if buttonIndex == self.cancelButtonIndex {
                return NSLocalizedString("Cancel", comment: "Cancel")
            }
            else {
                return self.delegate?.imagePickerSheet(self, titleForButtonAtIndex: buttonIndex)
            }
        }()
        
        cell.textLabel?.text = buttonTitle
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    public func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return !(self.previewsPhotos && indexPath.row == 0)
    }
    
    public func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
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
    
    public func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return self.assets.count
    }
    
    public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(imageCellIdentifier, forIndexPath: indexPath) as BRNImageCollectionViewCell
        
        let asset = self.assets[indexPath.section]
        let size = self.sizeForAsset(asset)
        
        self.requestImageForAsset(asset, size: size) { image in
            cell.imageView.image = image
        }
        
        return cell
    }
    
    public func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        let view = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier: imageSupplementaryViewIdentifier, forIndexPath: indexPath) as BRNImageSupplementaryView
        view.userInteractionEnabled = false
        view.buttonInset = UIEdgeInsetsMake(0.0, collectionViewCheckmarkInset, collectionViewCheckmarkInset, 0.0)
        view.selected = contains(self.selectedPhotoIndices, indexPath.section)
        
        self.supplementaryViews[indexPath.section] = view
        
        return view
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    public func collectionView(collectionView: UICollectionView, layout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let asset = self.assets[indexPath.section]
        
        return self.sizeForAsset(asset)
    }
    
    public func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let inset = 2.0 * collectionViewCheckmarkInset
        let size = self.collectionView(collectionView, layout: collectionViewLayout, sizeForItemAtIndexPath: NSIndexPath(forRow: 0, inSection: section))
        
        return CGSizeMake(BRNImageSupplementaryView.checkmarkImage.size.width + inset, size.height)
    }
    
    // MARK: - UICollectionViewDelegate
    
    public func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        let nextIndex = indexPath.row+1
        if nextIndex < self.assets.count {
            let asset = self.assets[nextIndex]
            let size = self.sizeForAsset(asset)
            
            self.prefetchImagesForAsset(asset, size: size)
        }
    }
    
    public func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let selected = contains(self.selectedPhotoIndices, indexPath.section)
        
        if !selected {
            self.selectedPhotoIndices.append(indexPath.section)
            
            if !self.enlargedPreviews {
                self.delegate?.imagePickerSheetWillEnlargePreviews?(self)
                self.enlargedPreviews = true
                
                let layout: BRNHorizontalImagePreviewFlowLayout = self.collectionView.collectionViewLayout as BRNHorizontalImagePreviewFlowLayout
                layout.invalidationCenteredIndexPath = indexPath
                
                self.setNeedsLayout()
                UIView.animateWithDuration(enlargementAnimationDuration, animations: {
                    self.tableView.beginUpdates()
                    self.tableView.endUpdates()
                    self.layoutIfNeeded()
                    }, completion: { finished in
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
    
    public func showInView(view: UIView) {
        if let superview = view.superview {
            self.fetchAssets()
            self.tableView.reloadData()
            
            self.delegate?.willPresentImagePickerSheet?(self)
            
            self.frame = view.frame
            superview.addSubview(self)
            
            let originalTableViewOffset = CGRectGetMinY(self.tableView.frame)
            self.tableView.frame.origin.y = CGRectGetHeight(self.bounds)
            self.overlayView.alpha = 0.0
            self.overlayView.userInteractionEnabled = false
            
            UIView.animateWithDuration(presentationAnimationDuration, animations: {
                self.tableView.frame.origin.y = originalTableViewOffset
                self.overlayView.alpha = 1.0
                }, completion: { finished in
                    self.delegate?.didPresentImagePickerSheet?(self)
                    self.overlayView.userInteractionEnabled = true
            })
        }
    }
    
    public func dismissWithClickedButtonIndex(buttonIndex: Int, animated: Bool) {
        self.delegate?.imagePickerSheet?(self, willDismissWithButtonIndex: buttonIndex)
        
        let duration = (animated) ? presentationAnimationDuration : 0.0
        UIView.animateWithDuration(duration, animations: {
            self.overlayView.alpha = 0.0
            self.tableView.frame.origin.y += CGRectGetHeight(self.tableView.frame)
            }, completion: { finished in
                self.delegate?.imagePickerSheet?(self, didDismissWithButtonIndex: buttonIndex)
                self.removeFromSuperview()
        })
    }
    
    // MARK: - Images
    
    private func sizeForAsset(asset: PHAsset) -> CGSize {
        let proportion = CGFloat(asset.pixelWidth)/CGFloat(asset.pixelHeight)
        
        let height: CGFloat = {
            let rowHeight = self.enlargedPreviews ? tableViewEnlargedPreviewRowHeight : tableViewPreviewRowHeight
            return rowHeight-2.0*collectionViewInset
        }()
        
        return CGSize(width: proportion*height, height: height)
    }
    
    private func targetSizeForAssetOfSize(size: CGSize) -> CGSize {
        let scale = UIScreen.mainScreen().scale
        return CGSize(width: scale*size.width, height: scale*size.height)
    }
    
    private func fetchAssets() {
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        let result = PHAsset.fetchAssetsWithMediaType(.Image, options: options)
        result.enumerateObjectsUsingBlock { obj, _, _ in
            if let asset = obj as? PHAsset {
                self.assets.append(asset)
            }
        }
    }
    
    private func requestImageForAsset(asset: PHAsset, size: CGSize?, completion: (image: UIImage) -> Void) {
        var targetSize = PHImageManagerMaximumSize
        if let size = size {
            targetSize = self.targetSizeForAssetOfSize(size)
        }
        
        self.imageManager.requestImageForAsset(asset, targetSize: targetSize, contentMode: .AspectFit, options: nil) { (image, _) -> Void in
            completion(image: image)
        }
    }
    
    private func prefetchImagesForAsset(asset: PHAsset, size: CGSize) {
        let targetSize = self.targetSizeForAssetOfSize(size)
        self.imageManager.startCachingImagesForAssets([asset], targetSize: targetSize, contentMode: .AspectFit, options: nil)
    }
    
    public func getSelectedImagesWithCompletion(completion: (images:[UIImage]) -> Void) {
        var images = [UIImage]()
        var counter = self.selectedPhotoIndices.count
        
        for index in self.selectedPhotoIndices {
            let asset = self.assets[index]
            self.requestImageForAsset(asset, size: nil, completion: { (image) -> Void in
                images.append(image)
                counter--
                
                if counter <= 0 {
                    completion(images: images)
                }
            })
        }
    }
    
    // MARK: - Other Methods
    
    public func buttonIndexForRow(row: Int) -> Int {
        return row-self.firstButtonIndex
    }
    
    private func reloadButtonTitles() {
        let indexPaths = Array(self.firstButtonIndex ..< self.firstButtonIndex+self.numberOfButtons-1).map({ NSIndexPath(forRow: $0, inSection: 0) })
        
        self.tableView.reloadRowsAtIndexPaths(indexPaths, withRowAnimation: .None)
    }
    
    @objc private func overlayViewWasTapped(gestureRecognizer: UITapGestureRecognizer) {
        self.dismissWithClickedButtonIndex(self.cancelButtonIndex, animated: true)
    }
    
    // MARK: - Layout
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        let bounds = self.bounds
        
        self.overlayView.frame = bounds
        
        let tableViewHeight = Array(0..<self.tableView.numberOfRowsInSection(0)).reduce(0.0) { total, row in
            total + self.tableView(self.tableView, heightForRowAtIndexPath: NSIndexPath(forRow: row, inSection: 0))
        }
        
        self.tableView.frame.size = CGSizeMake(CGRectGetWidth(bounds), tableViewHeight)
        self.tableView.frame.origin.y = CGRectGetMaxY(bounds)-CGRectGetHeight(self.tableView.frame)
    }
    
}
