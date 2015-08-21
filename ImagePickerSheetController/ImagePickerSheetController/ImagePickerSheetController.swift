//
//  ImagePickerController.swift
//  ImagePickerSheet
//
//  Created by Laurin Brandner on 24/05/15.
//  Copyright (c) 2015 Laurin Brandner. All rights reserved.
//

import Foundation
import Photos

private let collectionViewInset: CGFloat = 5.0
private let collectionViewCheckmarkInset: CGFloat = 3.5

public class ImagePickerSheetController: UIViewController {
    
    lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.accessibilityIdentifier = "ImagePickerSheet"
        tableView.dataSource = self
        tableView.delegate = self
        tableView.alwaysBounceVertical = false
        tableView.layoutMargins = UIEdgeInsetsZero
        tableView.separatorInset = UIEdgeInsetsZero
        tableView.registerClass(ImagePreviewTableViewCell.self, forCellReuseIdentifier: NSStringFromClass(ImagePreviewTableViewCell.self))
        tableView.registerClass(UITableViewCell.self, forCellReuseIdentifier: NSStringFromClass(UITableViewCell.self))
        
        return tableView
    }()
    
    private lazy var collectionView: ImagePickerCollectionView = {
        let collectionView = ImagePickerCollectionView()
        collectionView.accessibilityIdentifier = "ImagePickerSheetPreview"
        collectionView.backgroundColor = .clearColor()
        collectionView.allowsMultipleSelection = true
        collectionView.imagePreviewLayout.sectionInset = UIEdgeInsetsMake(collectionViewInset, collectionViewInset, collectionViewInset, collectionViewInset)
        collectionView.imagePreviewLayout.showsSupplementaryViews = false
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.alwaysBounceHorizontal = true
        collectionView.registerClass(ImageCollectionViewCell.self, forCellWithReuseIdentifier: NSStringFromClass(ImageCollectionViewCell.self))
        collectionView.registerClass(PreviewSupplementaryView.self, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: NSStringFromClass(PreviewSupplementaryView.self))
        
        return collectionView
    }()
    
    lazy var backgroundView: UIView = {
        let view = UIView()
        view.accessibilityIdentifier = "ImagePickerSheetBackground"
        view.backgroundColor = UIColor(white: 0.0, alpha: 0.3961)
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: "cancel"))
        
        return view
    }()
    
    /// All the actions in the same order as they were added. The first action is shown at the top.
    public private(set) var actions = [ImageAction]() {
        didSet {
            if isViewLoaded() {
                reloadButtons()
                view.setNeedsLayout()
            }
        }
    }
    
    /// Maximum selection of images.
    public var maximumSelection: Int?
    
    private var assets = [PHAsset]()
    
    private var selectedImageIndices = [Int]()
    
    /// The number of the currently selected images.
    public var numberOfSelectedImages: Int {
        return selectedImageIndices.count
    }
    
    /// The selected image assets
    public var selectedImageAssets: [PHAsset] {
        return selectedImageIndices.map { self.assets[$0] }
    }
    
    /// Whether the preview row has been elarged. This is the case when at least once
    /// image has been selected.
    public private(set) var enlargedPreviews = false
    
    private var imagePreviewHeight: CGFloat = 0
    
    private var supplementaryViews = [Int: PreviewSupplementaryView]()
    
    private let imageManager = PHCachingImageManager()
    
    // MARK: - Initialization
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        initialize()
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    private func initialize() {
        modalPresentationStyle = .Custom
        transitioningDelegate = self
    }
    
    // MARK: - View Lifecycle
    
    override public func loadView() {
        super.loadView()
        
        view.addSubview(backgroundView)
        view.addSubview(tableView)
    }
    
    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        if PHPhotoLibrary.authorizationStatus() == .Authorized {
            fetchAssets()
        }
    }
    
    public override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if PHPhotoLibrary.authorizationStatus() == .NotDetermined {
            PHPhotoLibrary.requestAuthorization() { status in
                if status == .Authorized {
                    dispatch_async(dispatch_get_main_queue()) {
                        self.fetchAssets()
                        
                        self.tableView.reloadData()
                        self.view.setNeedsLayout()
                        
                        // Explicitely disable animations so it wouldn't animate either
                        // if it was in a popover
                        CATransaction.begin()
                        CATransaction.setDisableActions(true)
                        self.view.layoutIfNeeded()
                        CATransaction.commit()
                    }
                }
            }
        }
    }
    
    // MARK: - Actions
    
    /// Adds an new action.
    /// Will replace any existing action of type .Cancel in order to make sure that only one is present.
    public func addAction(action: ImageAction) {
        actions = actions.filter { $0.style != ImageActionStyle.Cancel }
        actions.append(action)
    }
    
    // MARK: - Images
    
    private func sizeForAsset(asset: PHAsset) -> CGSize {
        let proportion = CGFloat(asset.pixelWidth)/CGFloat(asset.pixelHeight)
        return CGSize(width: floor(proportion*imagePreviewHeight), height: imagePreviewHeight)
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
            if let asset = obj as? PHAsset where self.assets.count < 50 {
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
                let image = data.flatMap { UIImage(data: $0) }
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
    
    // MARK: - Buttons
    
    private func reloadButtons() {
        tableView.reloadSections(NSIndexSet(index: 1), withRowAnimation: .None)
    }
    
    @objc private func cancel() {
        presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
        
        let cancelActions = actions.filter { $0.style == ImageActionStyle.Cancel }
        if let cancelAction = cancelActions.first {
            cancelAction.handle(numberOfSelectedImages)
        }
    }
    
    // MARK: - Layout
    
    public override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        reloadImagePreviewHeight()
        
        backgroundView.frame = view.bounds
        
        let tableViewHeight = Array(0..<tableView.numberOfRowsInSection(1)).reduce(tableView(tableView, heightForRowAtIndexPath: NSIndexPath(forRow: 0, inSection: 0))) { total, row in
            total + tableView(tableView, heightForRowAtIndexPath: NSIndexPath(forRow: row, inSection: 1))
        }
        let tableViewSize = CGSize(width: view.bounds.width, height: tableViewHeight)
        
        // This particular order is necessary so that the sheet is layed out
        // correctly with and without an enclosing popover
        preferredContentSize = tableViewSize
        tableView.frame = CGRect(origin: CGPoint(x: view.bounds.minX, y: view.bounds.maxY-tableViewHeight), size: tableViewSize)
    }
    
    private func reloadImagePreviewHeight() {
        guard enlargedPreviews else {
            imagePreviewHeight = 129
            return
        }
        
        let maxImageWidth = view.bounds.width - 2 * collectionViewInset

        let assetRatios = assets.map { CGSize(width: max($0.pixelHeight, $0.pixelWidth), height: min($0.pixelHeight, $0.pixelWidth)) }
                                .map { $0.height / $0.width }
            
        let assetHeights = assetRatios.map { $0 * maxImageWidth }
                                      .filter { $0 < maxImageWidth && $0 < 300 } // Make sure the preview isn't too high
                                      .sort(>)
        
        // Fallback, if the user only has square images
        imagePreviewHeight = assetHeights.first ?? 250
    }

}

// MARK: - UITableViewDataSource

extension ImagePickerSheetController: UITableViewDataSource {
    
    public func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }
    
    public func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if section == 0 {
            return 1
        }
        
        return actions.count
    }
    
    public func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if indexPath.section == 0 {
            if assets.count > 0 {
                return imagePreviewHeight + 2 * collectionViewInset
            }
            
            return 0
        }
        
        return 50
    }
    
    public func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.section == 0 {
            let cell = tableView.dequeueReusableCellWithIdentifier(NSStringFromClass(ImagePreviewTableViewCell.self), forIndexPath: indexPath) as! ImagePreviewTableViewCell
            cell.collectionView = collectionView
            cell.separatorInset = UIEdgeInsets(top: 0, left: tableView.bounds.width, bottom: 0, right: 0)
            
            return cell
        }
        
        let action = actions[indexPath.row]
        
        let cell = tableView.dequeueReusableCellWithIdentifier(NSStringFromClass(UITableViewCell.self), forIndexPath: indexPath)
        cell.textLabel?.textAlignment = .Center
        cell.textLabel?.textColor = tableView.tintColor
        cell.textLabel?.font = UIFont.systemFontOfSize(21)
        cell.textLabel?.text = selectedImageIndices.count > 0 ? action.secondaryTitle(numberOfSelectedImages) : action.title
        cell.layoutMargins = UIEdgeInsetsZero
        
        return cell
    }
    
}

// MARK: - UITableViewDelegate

extension ImagePickerSheetController: UIScrollViewDelegate, UITableViewDelegate {
    
    public func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return indexPath.section != 0
    }
    
    public func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
        
        actions[indexPath.row].handle(numberOfSelectedImages)
    }
    
}

// MARK: - UICollectionViewDataSource

extension ImagePickerSheetController: UICollectionViewDataSource {
    
    public func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return assets.count
    }
    
    public func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    public func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(NSStringFromClass(ImageCollectionViewCell.self), forIndexPath: indexPath) as! ImageCollectionViewCell
        
        let asset = assets[indexPath.section]
        let size = sizeForAsset(asset)
        
        requestImageForAsset(asset, size: size) { image in
            cell.imageView.image = image
        }
        
        cell.selected = selectedImageIndices.contains(indexPath.section)
        
        return cell
    }
    
    public func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        let view = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionHeader, withReuseIdentifier: NSStringFromClass(PreviewSupplementaryView.self), forIndexPath: indexPath) as! PreviewSupplementaryView
        view.userInteractionEnabled = false
        view.buttonInset = UIEdgeInsetsMake(0.0, collectionViewCheckmarkInset, collectionViewCheckmarkInset, 0.0)
        view.selected = selectedImageIndices.contains(indexPath.section)
        
        supplementaryViews[indexPath.section] = view
        
        return view
    }
    
}

// MARK: - UICollectionViewDelegate

extension ImagePickerSheetController: UICollectionViewDelegate {
    
    public func collectionView(collectionView: UICollectionView, willDisplayCell cell: UICollectionViewCell, forItemAtIndexPath indexPath: NSIndexPath) {
        let nextIndex = indexPath.row+1
        if nextIndex < assets.count {
            let asset = assets[nextIndex]
            let size = sizeForAsset(asset)
            
            self.prefetchImagesForAsset(asset, size: size)
        }
    }
    
    public func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        if let maximumSelection = maximumSelection {
            if selectedImageIndices.count >= maximumSelection,
                let previousItemIndex = selectedImageIndices.first {
                    supplementaryViews[previousItemIndex]?.selected = false
                    selectedImageIndices.removeAtIndex(0)
            }
        }
        
        selectedImageIndices.append(indexPath.section)
        
        if !enlargedPreviews {
            enlargedPreviews = true
            
            self.collectionView.imagePreviewLayout.invalidationCenteredIndexPath = indexPath
            
            view.setNeedsLayout()
            reloadImagePreviewHeight()
            UIView.animateWithDuration(0.3, animations: {
                self.tableView.beginUpdates()
                self.tableView.endUpdates()
                self.view.layoutIfNeeded()
                }, completion: { finished in
                    self.reloadButtons()
                    self.collectionView.imagePreviewLayout.showsSupplementaryViews = true
            })
        }
        else {
            if let cell = collectionView.cellForItemAtIndexPath(indexPath) {
                var contentOffset = CGPointMake(cell.frame.midX - collectionView.frame.width / 2.0, 0.0)
                contentOffset.x = max(contentOffset.x, -collectionView.contentInset.left)
                contentOffset.x = min(contentOffset.x, collectionView.contentSize.width - collectionView.frame.width + collectionView.contentInset.right)
                
                collectionView.setContentOffset(contentOffset, animated: true)
            }
            
            reloadButtons()
        }
        
        supplementaryViews[indexPath.section]?.selected = true
    }
    
    public func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        if let index = selectedImageIndices.indexOf(indexPath.section) {
            selectedImageIndices.removeAtIndex(index)
            reloadButtons()
        }
        
        supplementaryViews[indexPath.section]?.selected = false
    }
    
}

// MARK: - UICollectionViewDelegateFlowLayout

extension ImagePickerSheetController: UICollectionViewDelegateFlowLayout {
    
    public func collectionView(collectionView: UICollectionView, layout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let asset = assets[indexPath.section]
        
        return sizeForAsset(asset)
    }
    
    public func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        let inset = 2.0 * collectionViewCheckmarkInset
        let size = self.collectionView(collectionView, layout: collectionViewLayout, sizeForItemAtIndexPath: NSIndexPath(forRow: 0, inSection: section))
        let imageWidth = PreviewSupplementaryView.checkmarkImage?.size.width ?? 0
        
        return CGSizeMake(imageWidth  + inset, size.height)
    }
    
}

// MARK: - UIViewControllerTransitioningDelegate

extension ImagePickerSheetController: UIViewControllerTransitioningDelegate {
    
    public func animationControllerForPresentedController(presented: UIViewController, presentingController presenting: UIViewController, sourceController source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return AnimationController(imagePickerSheetController: self, presenting: true)
    }
    
    public func animationControllerForDismissedController(dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return AnimationController(imagePickerSheetController: self, presenting: false)
    }
    
}
