//
//  ImagePickerSheet.swift
//  ImagePickerSheet
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

@objc public protocol ImagePickerSheetDelegate {
    func imagePickerSheet(imagePickerSheet: ImagePickerSheet, titleForButtonAtIndex buttonIndex: Int) -> String
    
    optional func imagePickerSheet(imagePickerSheet: ImagePickerSheet, clickedButtonAtIndex buttonIndex: Int)
    optional func imagePickerSheetCancel(imagePickerSheet: ImagePickerSheet)
    // TODO: Call cancel delegate method
    
    optional func willPresentImagePickerSheet(imagePickerSheet: ImagePickerSheet)
    optional func didPresentImagePickerSheet(imagePickerSheet: ImagePickerSheet)
    
    optional func imagePickerSheetWillEnlargePreviews(imagePickerSheet: ImagePickerSheet)
    optional func imagePickerSheetDidEnlargePreviews(imagePickerSheet: ImagePickerSheet)
    
    optional func imagePickerSheet(imagePickerSheet: ImagePickerSheet, willDismissWithButtonIndex buttonIndex: Int)
    optional func imagePickerSheet(imagePickerSheet: ImagePickerSheet, didDismissWithButtonIndex buttonIndex: Int)
}

public class ImagePickerSheet: UIView, UITableViewDataSource, UITableViewDelegate, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    private let overlayView = UIView()
    private let tableView = UITableView()
    private let collectionView = ImagePickerCollectionView()
    
    private(set) var enlargedPreviews = false
    public var delegate: ImagePickerSheetDelegate?
    private var assets = [PHAsset]()
    private var selectedPhotoIndices = [Int]()
    private var previewsPhotos: Bool {
        return (assets.count > 0)
    }
    private var supplementaryViews = [Int: ImageSupplementaryView]()
    
    public var cancelButtonIndex: Int {
        let lastRow = tableView.numberOfRowsInSection(0) - 1
        return buttonIndexForRow(lastRow)
    }
    
    public var numberOfSelectedPhotos: Int {
        return selectedPhotoIndices.count
    }
    
    public var numberOfButtons: Int = 1 {
        didSet {
            numberOfButtons = max(numberOfButtons, 1)
        }
    }

    private var firstButtonIndex: Int {
        return previewsPhotos ? 1 : 0
    }
    
    private let imageManager = PHCachingImageManager()
    
    private var titles: [(title: String, singularSecondaryTitle: String?, pluralSecondaryTitle: String?)] = [(NSLocalizedString("Cancel", comment: "Cancel"), nil, nil)]
    
    // MARK: - Initialization
    
    public init() {
        super.init(frame: CGRectZero)
        
        initialize()
    }
    
    public required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        initialize()
    }
    
    private func initialize() {
        let tapRecognizer = UITapGestureRecognizer()
        tapRecognizer.addTarget(self, action: Selector("overlayViewWasTapped:"))
        overlayView.addGestureRecognizer(tapRecognizer)
        overlayView.backgroundColor = UIColor(white: 0.0, alpha: 0.3961)
        addSubview(overlayView)
        
        tableView.dataSource = self
        tableView.delegate = self
        tableView.alwaysBounceVertical = false
        tableView.registerClass(ImagePreviewTableViewCell.self, forCellReuseIdentifier: previewCellIdentifier)
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: sheetCellIdentifier)
        addSubview(tableView)
        
        collectionView.horizontalImagePreviewLayout.sectionInset = UIEdgeInsetsMake(collectionViewInset, collectionViewInset, collectionViewInset, collectionViewInset)
        collectionView.horizontalImagePreviewLayout.showsSupplementaryViews = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.backgroundColor = UIColor.clearColor()
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.alwaysBounceHorizontal = true
        collectionView.registerClass(ImageCollectionViewCell.self, forCellWithReuseIdentifier: imageCellIdentifier)
        collectionView.registerClass(ImageSupplementaryView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: imageSupplementaryViewIdentifier)
    }
    
    // MARK: - UITableViewDataSource
    
    public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var numberOfRows = numberOfButtons
        if previewsPhotos {
            numberOfRows += 1
        }
        
        return numberOfRows
    }
    
    public func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if previewsPhotos {
            if indexPath.row == 0 {
                if (enlargedPreviews) {
                    return tableViewEnlargedPreviewRowHeight
                }
                
                return tableViewPreviewRowHeight
            }
        }
        
        return tableViewRowHeight
    }
    
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.row == 0 && previewsPhotos {
            let cell = tableView.dequeueReusableCellWithIdentifier(previewCellIdentifier, forIndexPath: indexPath) as! ImagePreviewTableViewCell
            cell.collectionView = collectionView
            
            return cell
        }
        
        let cell = tableView.dequeueReusableCellWithIdentifier(sheetCellIdentifier, forIndexPath: indexPath) as! UITableViewCell
        cell.textLabel?.textAlignment = .Center
        cell.textLabel?.textColor = tintColor
        cell.textLabel?.font = UIFont.systemFontOfSize(21)
        
        let buttonIndex = buttonIndexForRow(indexPath.row)
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
        return !(previewsPhotos && indexPath.row == 0)
    }
    
    public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        var handle = true
        if previewsPhotos {
            if indexPath.row == 0 {
                handle = false
            }
        }
        
        if handle {
            let buttonIndex = buttonIndexForRow(indexPath.row)
            
            delegate?.imagePickerSheet?(self, clickedButtonAtIndex: buttonIndex)
            dismissWithClickedButtonIndex(buttonIndex, animated: true)
        }
    }
    
    // MARK: - UICollectionViewDataSource
    
    public func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return assets.count
    }
    
    public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(imageCellIdentifier, forIndexPath: indexPath) as! ImageCollectionViewCell
        
        let asset = assets[indexPath.section]
        let size = sizeForAsset(asset)
        
        requestImageForAsset(asset, size: size) { image in
            cell.imageView.image = image
        }
        
        return cell
    }
    
    public func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        let view = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier: imageSupplementaryViewIdentifier, forIndexPath: indexPath) as! ImageSupplementaryView
        view.userInteractionEnabled = false
        view.buttonInset = UIEdgeInsetsMake(0.0, collectionViewCheckmarkInset, collectionViewCheckmarkInset, 0.0)
        view.selected = contains(selectedPhotoIndices, indexPath.section)
        
        supplementaryViews[indexPath.section] = view
        
        return view
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    public func collectionView(collectionView: UICollectionView, layout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let asset = assets[indexPath.section]
        
        return sizeForAsset(asset)
    }
    
    public func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let inset = 2.0 * collectionViewCheckmarkInset
        let size = self.collectionView(collectionView, layout: collectionViewLayout, sizeForItemAtIndexPath: NSIndexPath(forRow: 0, inSection: section))
        let imageWidth = ImageSupplementaryView.checkmarkImage?.size.width ?? 0
        
        return CGSizeMake(imageWidth  + inset, size.height)
    }
    
    // MARK: - UICollectionViewDelegate
    
    public func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        let nextIndex = indexPath.row+1
        if nextIndex < assets.count {
            let asset = assets[nextIndex]
            let size = sizeForAsset(asset)
            
            self.prefetchImagesForAsset(asset, size: size)
        }
    }
    
    public func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let selected = contains(selectedPhotoIndices, indexPath.section)
        
        if !selected {
            selectedPhotoIndices.append(indexPath.section)
            
            if !enlargedPreviews {
                delegate?.imagePickerSheetWillEnlargePreviews?(self)
                enlargedPreviews = true
                
                self.collectionView.horizontalImagePreviewLayout.invalidationCenteredIndexPath = indexPath
                
                setNeedsLayout()
                UIView.animateWithDuration(enlargementAnimationDuration, animations: {
                    self.tableView.beginUpdates()
                    self.tableView.endUpdates()
                    self.layoutIfNeeded()
                    }, completion: { finished in
                        self.reloadButtonTitles()
                        self.collectionView.horizontalImagePreviewLayout.showsSupplementaryViews = true
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
                
                reloadButtonTitles()
            }
        }
        else {
            selectedPhotoIndices.removeAtIndex(find(selectedPhotoIndices, indexPath.section)!)
            reloadButtonTitles()
        }
        
        if let sectionView = supplementaryViews[indexPath.section] {
            sectionView.selected = !selected
        }
    }
    
    // MARK: - Presentation
    
    public func showInView(view: UIView) {
        if let superview = view.superview {
            fetchAssets()
            tableView.reloadData()
            
            delegate?.willPresentImagePickerSheet?(self)
            
            frame = view.frame
            superview.addSubview(self)
            
            let originalTableViewOffset = CGRectGetMinY(tableView.frame)
            tableView.frame.origin.y = CGRectGetHeight(bounds)
            overlayView.alpha = 0.0
            overlayView.userInteractionEnabled = false
            
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
        delegate?.imagePickerSheet?(self, willDismissWithButtonIndex: buttonIndex)
        
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
        
        return CGSize(width: CGFloat(floorf(Float(proportion*height))), height: height)
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
    
    private func requestImageForAsset(asset: PHAsset, size: CGSize? = nil, deliveryMode: PHImageRequestOptionsDeliveryMode = .Opportunistic, completion: (image: UIImage?) -> Void) {
        var targetSize = PHImageManagerMaximumSize
        if let size = size {
            targetSize = targetSizeForAssetOfSize(size)
        }
        
        let options = PHImageRequestOptions()
        options.deliveryMode = deliveryMode;

        // Workaround because PHImageManager.requestImageForAsset doesn't work for burst images
        if asset.representsBurst {
            imageManager.requestImageDataForAsset(asset, options: options) { data, _, _, _ in
                let image = UIImage(data: data)
                completion(image: image)
            }
        }
        else {
            imageManager.requestImageForAsset(asset, targetSize: targetSize, contentMode: .AspectFill, options: options) { image, _ in
                completion(image: image)
            }
        }
    }
    
    private func prefetchImagesForAsset(asset: PHAsset, size: CGSize) {
        // Not necessary to cache image because PHImageManager won't return burst images
        if !asset.representsBurst {
            let targetSize = targetSizeForAssetOfSize(size)
            imageManager.startCachingImagesForAssets([asset], targetSize: targetSize, contentMode: .AspectFill, options: nil)
        }
    }
    
    public func getSelectedImagesWithCompletion(completion: (images:[UIImage?]) -> Void) {
        var images = [UIImage?]()
        var counter = selectedPhotoIndices.count
        
        for index in selectedPhotoIndices {
            let asset = assets[index]
            
            requestImageForAsset(asset, deliveryMode: .HighQualityFormat) { image in
                images.append(image)
                counter--
                
                if counter <= 0 {
                    completion(images: images)
                }
            }
        }
    }
    
    // MARK: - Other Methods
    
    public override func tintColorDidChange() {
        super.tintColorDidChange()
        
        reloadButtonTitles()
    }
    
    public func buttonIndexForRow(row: Int) -> Int {
        return row-firstButtonIndex
    }
    
    private func reloadButtonTitles() {
        let indexPaths = Array(firstButtonIndex ..< firstButtonIndex+numberOfButtons-1).map({ NSIndexPath(forRow: $0, inSection: 0) })
        
        tableView.reloadRowsAtIndexPaths(indexPaths, withRowAnimation: .None)
    }
    
    @objc private func overlayViewWasTapped(gestureRecognizer: UITapGestureRecognizer) {
        dismissWithClickedButtonIndex(cancelButtonIndex, animated: true)
    }
    
    // MARK: - Layout
    
    override public func layoutSubviews() {
        super.layoutSubviews()
        
        overlayView.frame = bounds
        
        let tableViewHeight = Array(0..<tableView.numberOfRowsInSection(0)).reduce(0.0) { total, row in
            total + tableView(tableView, heightForRowAtIndexPath: NSIndexPath(forRow: row, inSection: 0))
        }
        
        tableView.frame.size = CGSizeMake(CGRectGetWidth(bounds), tableViewHeight)
        tableView.frame.origin.y = CGRectGetMaxY(bounds)-CGRectGetHeight(tableView.frame)
    }
    
}
