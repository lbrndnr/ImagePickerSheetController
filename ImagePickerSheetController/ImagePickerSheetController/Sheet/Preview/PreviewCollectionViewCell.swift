//
//  PreviewCollectionViewCell.swift
//  ImagePickerSheet
//
//  Created by Laurin Brandner on 06/09/14.
//  Copyright (c) 2014 Laurin Brandner. All rights reserved.
//

import UIKit

class PreviewCollectionViewCell: UICollectionViewCell {

    public let selectionElement = PreviewSupplementaryView(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 22, height: 22)))

    private var selectionCenter: CGPoint = .zero {
      didSet {
        if selectionCenter != oldValue {
          setNeedsLayout()
        }
      }
    }

    public var showSelectionCircles: Bool = true {
      didSet {
        if showSelectionCircles != oldValue {
          selectionElement.center = selectionCenter
          selectionElement.isHidden = !showSelectionCircles
        }
      }
    }

    let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        
        return imageView
    }()
    
    let videoIndicatorView: UIImageView = {
        let imageView = UIImageView(image: videoImage)
        imageView.isHidden = true
        
        return imageView
    }()
    
    fileprivate class var videoImage: UIImage? {
        let bundle = Bundle(for: ImagePickerSheetController.self)
        let image = UIImage(named: "PreviewCollectionViewCell-video", in: bundle, compatibleWith: nil)
        
        return image
    }

    public func updateSelection(isSelected: Bool) {
      selectionElement.isSelected = isSelected
    }
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        initialize()
    }
    
    fileprivate func initialize() {
        addSubview(imageView)
        addSubview(videoIndicatorView)
        addSubview(selectionElement)
    }
    
    // MARK: - Other Methods
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        imageView.image = nil
        videoIndicatorView.isHidden = true
    }
    
    // MARK: - Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        imageView.frame = bounds
        
        let videoIndicatViewSize = videoIndicatorView.image?.size ?? CGSize()
        let inset: CGFloat = 4
        let videoIndicatorViewOrigin = CGPoint(x: bounds.minX + inset, y: bounds.maxY - inset - videoIndicatViewSize.height)
        videoIndicatorView.frame = CGRect(origin: videoIndicatorViewOrigin, size: videoIndicatViewSize)

        selectionElement.center = selectionCenter
    }

    override public func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
      super.apply(layoutAttributes)
      if let attributes = layoutAttributes as? PreviewCollectionViewLayout.Attributes {
        selectionCenter = attributes.selectionCenter
      }
      layoutIfNeeded()
    }
}
