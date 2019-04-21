//
//  ImagePickerController.swift
//  ImagePickerSheet
//
//  Created by Laurin Brandner on 24/05/15.
//  Copyright (c) 2015 Laurin Brandner. All rights reserved.
//

import Foundation
import Photos

let previewInset: CGFloat = 8

/// The media type an instance of ImagePickerSheetController can display
public enum ImagePickerMediaType {
    case image
    case video
    case imageAndVideo
}

@objc public protocol ImagePickerSheetControllerDelegate {
    
    @objc optional func controllerWillEnlargePreview(_ controller: ImagePickerSheetController)
    @objc optional func controllerDidEnlargePreview(_ controller: ImagePickerSheetController)
    
    @objc optional func controller(_ controller: ImagePickerSheetController, willSelectAsset asset: PHAsset)
    @objc optional func controller(_ controller: ImagePickerSheetController, didSelectAsset asset: PHAsset)
    
    @objc optional func controller(_ controller: ImagePickerSheetController, willDeselectAsset asset: PHAsset)
    @objc optional func controller(_ controller: ImagePickerSheetController, didDeselectAsset asset: PHAsset)
    
}

@available(iOS 9.0, *)
public final class ImagePickerSheetController: UIViewController {
    
    fileprivate lazy var sheetController: SheetController = {
        let controller = SheetController(previewCollectionView: self.previewCollectionView)
        controller.actionHandlingCallback = { [weak self] in
                // Possible retain cycle when action handlers hold a reference to the IPSC
                // Remove all actions to break it
            self?.dismiss(animated: true, completion: {
                controller.removeAllActions()
            })
        }
        
        return controller
    }()
    
    //    self?.dismiss(animated: true, completion: { _ in
    //    // Possible retain cycle when action handlers hold a reference to the IPSC
    //    // Remove all actions to break it
    //    controller.removeAllActions()
    //    })
    var sheetCollectionView: UICollectionView {
        return sheetController.sheetCollectionView
    }
    
    fileprivate(set) lazy var previewCollectionView: PreviewCollectionView = {
        let collectionView = PreviewCollectionView()
        collectionView.accessibilityIdentifier = "ImagePickerSheetPreview"
        collectionView.backgroundColor = .clear
        collectionView.allowsMultipleSelection = true
        collectionView.contentInset = UIEdgeInsets(top: previewInset, left: previewInset, bottom: previewInset, right: previewInset)
        collectionView.dataSource = self
        collectionView.delegate = self
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.alwaysBounceHorizontal = true
        collectionView.register(PreviewCollectionViewCell.self, forCellWithReuseIdentifier: NSStringFromClass(PreviewCollectionViewCell.self))
        
        return collectionView
    }()
    
    lazy var backgroundView: UIView = {
        let view = UIView()
        view.accessibilityIdentifier = "ImagePickerSheetBackground"
        view.backgroundColor = UIColor(white: 0.0, alpha: 0.3961)
        view.addGestureRecognizer(UITapGestureRecognizer(target: self.sheetController, action: #selector(SheetController.handleCancelAction)))
        
        return view
    }()
    
    public var delegate: ImagePickerSheetControllerDelegate?
    
    /// All the actions. The first action is shown at the top.
    public var actions: [ImagePickerAction] {
        return sheetController.actions
    }

    /// Corner radius of preview cells.
    public var cornerRadius: CGFloat = 0
    
    /// Maximum selection of images.
    public var maximumSelection: Int?
    
    fileprivate var selectedAssetIndices = [Int]() {
        didSet {
            sheetController.numberOfSelectedAssets = selectedAssetIndices.count
        }
    }
    
    /// The selected image assets
    public var selectedAssets: [PHAsset] {
        return selectedAssetIndices.map {
            let asset = PHAsset()
            if case let asset? = self.fetchedResults?[$0] as? PHAsset {
                return asset
            }
            return asset
        }
    }
    
    /// The media type of the displayed assets
    public let mediaType: ImagePickerMediaType

    private var fetchedResults: PHFetchResult<PHAsset>?
    
    fileprivate lazy var requestOptions: PHImageRequestOptions = {
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.resizeMode = .fast
        
        return options
    }()
    
    fileprivate let imageManager = PHCachingImageManager()
    
    /// Whether the image preview has been elarged. This is the case when at least once
    /// image has been selected.
    public fileprivate(set) var enlargedPreviews = false
    
    fileprivate let minimumPreviewHeight: CGFloat = 100
    fileprivate var maximumPreviewHeight: CGFloat = 100
    
    fileprivate var previewCheckmarkInset: CGFloat {
        return 12.5
    }
    
    // MARK: - Initialization
    
    public init(mediaType: ImagePickerMediaType) {
        self.mediaType = mediaType
        super.init(nibName: nil, bundle: nil)
        initialize()
    }
    
    public required init?(coder aDecoder: NSCoder) {
        self.mediaType = .imageAndVideo
        super.init(coder: aDecoder)
        initialize()
    }
    
    fileprivate func initialize() {
        modalPresentationStyle = .custom
        transitioningDelegate = self
        
        NotificationCenter.default.addObserver(sheetController, selector: #selector(sheetController.handleCancelAction), name: UIApplication.didEnterBackgroundNotification, object: nil)
    }
    
    @objc deinit {
        NotificationCenter.default.removeObserver(sheetController, name: UIApplication.didEnterBackgroundNotification, object: nil)
    }
    
    // MARK: - View Lifecycle
    
    override public func loadView() {
        super.loadView()
        
        view.addSubview(backgroundView)
        view.addSubview(sheetCollectionView)
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        preferredContentSize = CGSize(width: 400, height: view.frame.height)
        
        if PHPhotoLibrary.authorizationStatus() == .authorized {
            prepareAssets()
        }
    }
    
    override public func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if PHPhotoLibrary.authorizationStatus() == .notDetermined {
            PHPhotoLibrary.requestAuthorization() { status in
                if status == .authorized {
                    DispatchQueue.main.async {
                        self.prepareAssets()
                        self.previewCollectionView.reloadData()
                        self.sheetCollectionView.reloadData()
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
    /// If the passed action is of type Cancel, any pre-existing Cancel actions will be removed.
    /// Always arranges the actions so that the Cancel action appears at the bottom.
    public func addAction(_ action: ImagePickerAction) {
        sheetController.addAction(action)
        view.setNeedsLayout()
    }
    
    // MARK: - Images
    
    fileprivate func sizeForAsset(_ asset: PHAsset, scale: CGFloat = 1) -> CGSize {
        let proportion = CGFloat(asset.pixelWidth)/CGFloat(asset.pixelHeight)
        
        let imageHeight = maximumPreviewHeight - 2 * previewInset
        let imageWidth = floor(proportion * imageHeight)
        
        return CGSize(width: imageWidth * scale, height: imageHeight * scale)
    }
    
    fileprivate func prepareAssets() {
        fetchAssets()
        reloadMaximumPreviewHeight()
        reloadCurrentPreviewHeight(invalidateLayout: false)
    }
    
    fileprivate func fetchAssets() {
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        
        switch mediaType {
        case .image:
            options.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.image.rawValue)
        case .video:
            options.predicate = NSPredicate(format: "mediaType = %d", PHAssetMediaType.video.rawValue)
        case .imageAndVideo:
            options.predicate = NSPredicate(format: "mediaType = %d OR mediaType = %d", PHAssetMediaType.image.rawValue, PHAssetMediaType.video.rawValue)
        }
        
        let fetchLimit = 50
        options.fetchLimit = fetchLimit
        
        let result = PHAsset.fetchAssets(with: options)
        fetchedResults = result
        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = true
        requestOptions.deliveryMode = .fastFormat
        
        result.enumerateObjects(options: [], using: { asset, index, stop in
            if index == fetchLimit {
                stop.initialize(to: true)
            }
            
            self.prefetchImagesForAsset(asset)
        })
    }
    
    fileprivate func requestImageForAsset(_ asset: PHAsset, completion: @escaping (_ image: UIImage?) -> ()) {
        let targetSize = sizeForAsset(asset, scale: UIScreen.main.scale)
        requestOptions.isSynchronous = true
        requestOptions.deliveryMode = .fastFormat
        
        // Workaround because PHImageManager.requestImageForAsset doesn't work for burst images
        if asset.representsBurst {
            imageManager.requestImageData(for: asset, options: requestOptions) { data, _, _, _ in
                let image = data.flatMap { UIImage(data: $0) }
                completion(image)
            }
        }
        else {
            imageManager.requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFill, options: requestOptions) { image, _ in
                completion(image)
            }
        }
    }
    
    fileprivate func prefetchImagesForAsset(_ asset: PHAsset) {
        let targetSize = sizeForAsset(asset, scale: UIScreen.main.scale)
        imageManager.startCachingImages(for: [asset], targetSize: targetSize, contentMode: .aspectFill, options: requestOptions)
    }
    
    // MARK: - Layout
    
    override public func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if popoverPresentationController == nil {
            // Offset necessary for expanded status bar
            // Bug in UIKit which doesn't reset the view's frame correctly
            
            let offset = UIApplication.shared.statusBarFrame.height
            var backgroundViewFrame = UIScreen.main.bounds
            backgroundViewFrame.origin.y = -offset
            backgroundViewFrame.size.height += offset
            backgroundView.frame = backgroundViewFrame
        }
        else {
            backgroundView.frame = view.bounds
        }
        
        reloadMaximumPreviewHeight()
        reloadCurrentPreviewHeight(invalidateLayout: true)
        
        let sheetHeight = sheetController.preferredSheetHeight
        let sheetSize = CGSize(width: view.bounds.width, height: sheetHeight)

        let additionalPadding: CGFloat
        if #available(iOS 11, *) {
          additionalPadding = view.safeAreaInsets.bottom
        } else {
          additionalPadding = 0
        }

        // This particular order is necessary so that the sheet is layed out
        // correctly with and without an enclosing popover
        preferredContentSize = sheetSize
        sheetCollectionView.frame = CGRect(origin: CGPoint(x: view.bounds.minX, y: view.bounds.maxY - view.frame.origin.y - sheetHeight - additionalPadding), size: sheetSize)
    }
    
    fileprivate func reloadCurrentPreviewHeight(invalidateLayout invalidate: Bool) {
        guard let fetchedResults = fetchedResults else { return }

        if fetchedResults.count <= 0 {
            sheetController.setPreviewHeight(0, invalidateLayout: invalidate)
        }
        else if fetchedResults.count > 0 && enlargedPreviews {
            sheetController.setPreviewHeight(maximumPreviewHeight, invalidateLayout: invalidate)
        }
        else {
            sheetController.setPreviewHeight(minimumPreviewHeight, invalidateLayout: invalidate)
        }
    }
    
    fileprivate func reloadMaximumPreviewHeight() {
        let maxHeight: CGFloat = 400
        let maxImageWidth = (view.bounds.width - ((2 * sheetInset) + (2 * previewInset))) * 0.75

        guard let fetchedResults = fetchedResults else {
          return
        }

        let results: [PHAsset] = (0..<fetchedResults.count).map { fetchedResults[$0] }

        let assetRatios = results
          .map { CGSize(width: max($0.pixelHeight, $0.pixelWidth), height: min($0.pixelHeight, $0.pixelWidth))}
          .map { $0.height / $0.width }
        
        let assetHeights = assetRatios
            .map { $0 * maxImageWidth }
            .filter { $0 < maxImageWidth && $0 < maxHeight } // Make sure the preview isn't too high eg for squares
            .sorted(by: >)

        let assetHeight: CGFloat
        if let first = assetHeights.first {
            assetHeight = first
        }
        else {
            assetHeight = 0
        }
        
        // Just a sanity check, to make sure this doesn't exceed 400 points
        let scaledHeight: CGFloat = min(assetHeight, maxHeight)
        maximumPreviewHeight = scaledHeight + 2 * previewInset
    }
    
    // MARK: -
    
    func enlargePreviewsByCenteringToIndexPath(_ indexPath: IndexPath?, completion: (() -> ())?) {
        enlargedPreviews = true
        previewCollectionView.imagePreviewLayout.selectedCellIndexPath = indexPath
        reloadCurrentPreviewHeight(invalidateLayout: false)
        
        view.setNeedsLayout()
        
        self.delegate?.controllerWillEnlargePreview?(self)
        
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.92, initialSpringVelocity: 1, options: .curveLinear, animations: {
            self.view.layoutIfNeeded()
            self.sheetCollectionView.collectionViewLayout.invalidateLayout()
            self.updateVisibleCellsVisibleAreaRects()
        }, completion: { _ in
            self.delegate?.controllerDidEnlargePreview?(self)
            
            completion?()
        })
    }

    func shrinkPreviews(_ indexPath: IndexPath?, completion: (() -> ())?) {
      enlargedPreviews = false

      previewCollectionView.imagePreviewLayout.selectedCellIndexPath = indexPath
      self.reloadCurrentPreviewHeight(invalidateLayout: false)

      view.setNeedsLayout()

      UIView.animate(withDuration: 0.35, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 1, options: .curveLinear, animations: {
        self.view.layoutIfNeeded()
        self.sheetCollectionView.collectionViewLayout.invalidateLayout()
        self.updateVisibleCellsVisibleAreaRects()
      }, completion: { _ in
        completion?()
      })
    }
    
}

// MARK: - UICollectionViewDataSource

extension ImagePickerSheetController: UICollectionViewDataSource {
    
    public func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }
    
    public func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return fetchedResults?.count ?? 0
    }
    
    public func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: NSStringFromClass(PreviewCollectionViewCell.self), for: indexPath) as! PreviewCollectionViewCell

        if let asset = fetchedResults?[indexPath.row] {
          cell.videoIndicatorView.isHidden = asset.mediaType != .video

          requestImageForAsset(asset) { image in
              cell.imageView.image = image
          }
        }
        
        cell.selectionElement.isSelected = selectedAssetIndices.contains(indexPath.row)
        cell.imageView.layer.cornerRadius = cornerRadius
      
        return cell
    }
}

// MARK: - UICollectionViewDelegate

extension ImagePickerSheetController: UICollectionViewDelegate {
    
    public func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let maximumSelection = maximumSelection,
           selectedAssetIndices.count >= maximumSelection,
           let previousItemIndex = selectedAssetIndices.first,
           let deselectedAsset = fetchedResults?[previousItemIndex]
        {
            delegate?.controller?(self, willDeselectAsset: deselectedAsset)

            selectedAssetIndices.remove(at: 0)
            if let cell = previewCollectionView.cellForItem(at: IndexPath(row: previousItemIndex, section: 0)) as? PreviewCollectionViewCell {
              cell.updateSelection(isSelected: false)
            }

            delegate?.controller?(self, didDeselectAsset: deselectedAsset)
        }
        
        if let selectedAsset = fetchedResults?[indexPath.row] {
          delegate?.controller?(self, willSelectAsset: selectedAsset)

          // Just to make sure the image is only selected once
          selectedAssetIndices = selectedAssetIndices.filter { $0 != indexPath.row }
          selectedAssetIndices.append(indexPath.row)

          if !enlargedPreviews {
              enlargePreviewsByCenteringToIndexPath(indexPath) {
                  self.sheetController.reloadActionItems()
                  self.previewCollectionView.imagePreviewLayout.invalidateLayout()
              }
          }
          else {
              // scrollToItemAtIndexPath doesn't work reliably
              if let cell = collectionView.cellForItem(at: indexPath) {
                  var contentOffset = CGPoint(x: cell.frame.midX - collectionView.frame.width / 2.0, y: -previewInset)
                  contentOffset.x = max(contentOffset.x, -collectionView.contentInset.left)
                  contentOffset.x = min(contentOffset.x, collectionView.contentSize.width - collectionView.frame.width + collectionView.contentInset.right)

                  collectionView.setContentOffset(contentOffset, animated: true)
              }

              sheetController.reloadActionItems()
          }

          if let cell = previewCollectionView.cellForItem(at: indexPath) as? PreviewCollectionViewCell {
            cell.updateSelection(isSelected: true)
          }

          delegate?.controller?(self, didSelectAsset: selectedAsset)
      }
    }
    
    public func collectionView(_ collectionView: UICollectionView, didDeselectItemAt indexPath: IndexPath) {
        if let index = selectedAssetIndices.index(of: indexPath.row) {
            let deselectedAsset = selectedAssets[index]
            delegate?.controller?(self, willDeselectAsset: deselectedAsset)
            
            selectedAssetIndices.remove(at: index)
            shrinkPreviews(indexPath) {
              self.sheetController.reloadActionItems()
              self.previewCollectionView.imagePreviewLayout.invalidateLayout()
            }
            
            delegate?.controller?(self, didDeselectAsset: deselectedAsset)
        }

        if let cell = previewCollectionView.cellForItem(at: indexPath) as? PreviewCollectionViewCell {
          cell.updateSelection(isSelected: false)
        }
    }

    public func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
      updateVisibleAreaRect(cell: cell, indexPath: indexPath)
    }

    public func scrollViewDidScroll(_ scrollView: UIScrollView) {
      guard scrollView === previewCollectionView else {
        return
      }

      updateVisibleCellsVisibleAreaRects()
    }

    private func updateVisibleCellsVisibleAreaRects() {
      let indexPaths = previewCollectionView.indexPathsForVisibleItems
      for indexPath in indexPaths {
        if let cell = previewCollectionView.cellForItem(at: indexPath) {
          updateVisibleAreaRect(cell: cell, indexPath: indexPath)
        }
      }
    }

    private func updateVisibleAreaRect(cell: UICollectionViewCell, indexPath: IndexPath) {
      guard let cell = cell as? PreviewCollectionViewCell else {
        return
      }

      let cellVisibleRectInCollectionView = cell.convert(cell.bounds, to: previewCollectionView)
      let cellVisibleAreaInCollectionView = cellVisibleRectInCollectionView.intersection(previewCollectionView.bounds)
      let cellVisibleRect = cell.convert(cellVisibleAreaInCollectionView, from: previewCollectionView)

      previewCollectionView.imagePreviewLayout.updateVisibleArea(cellVisibleRect, itemAt: indexPath, cell: cell)
    }
}

// MARK: - UICollectionViewDelegateFlowLayout

extension ImagePickerSheetController: PreviewCollectionViewLayoutDelegate {
    
    public func collectionView(_ aCollectionView: UICollectionView, layout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
      if enlargedPreviews {
        return collectionView(aCollectionView, layout: layout, largeSizeForItemAt: indexPath)
      }

      let size = minimumPreviewHeight - 2 * previewInset
      return CGSize(width: size, height: size)
    }

    public func collectionView(_ collectionView: UICollectionView, layout: UICollectionViewLayout, largeSizeForItemAt indexPath: IndexPath) -> CGSize {
      guard let asset = fetchedResults?[indexPath.row] else {
        return .zero
      }

      let size = sizeForAsset(asset)

      let currentImagePreviewHeight = sheetController.previewHeight - 2 * previewInset
      let scale = currentImagePreviewHeight / size.height
        
      return CGSize(width: size.width * scale, height: currentImagePreviewHeight)
    }
}

// MARK: - UIViewControllerTransitioningDelegate

extension ImagePickerSheetController: UIViewControllerTransitioningDelegate {
    
    public func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return AnimationController(imagePickerSheetController: self, presenting: true)
    }
    
    public func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return AnimationController(imagePickerSheetController: self, presenting: false)
    }
    
}
