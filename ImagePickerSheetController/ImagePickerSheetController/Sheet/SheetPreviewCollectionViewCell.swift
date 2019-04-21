//
//  SheetPreviewCollectionViewCell.swift
//  ImagePickerSheetController
//
//  Created by Laurin Brandner on 06/09/14.
//  Copyright (c) 2014 Laurin Brandner. All rights reserved.
//

import UIKit

class SheetPreviewCollectionViewCell: SheetCollectionViewCell {
    
    var collectionView: PreviewCollectionView? {
        willSet {
            if let collectionView = collectionView {
                collectionView.removeFromSuperview()
            }
            
            if let collectionView = newValue {
                addSubview(collectionView)
            }
        }
    }
    
    // MARK: - Other Methods
    
    override func prepareForReuse() {
        collectionView = nil
    }
    
    // MARK: - Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        collectionView?.frame = bounds.inset(by: backgroundInsets)
    }
    
    override func reloadMask() {
      if needsMasking && layer.mask == nil {
        let maskLayer = CAShapeLayer()
        maskLayer.frame = bounds
        maskLayer.lineWidth = 0
        maskLayer.fillColor = UIColor.black.cgColor

        layer.mask = maskLayer
      }

      let layerMask = layer.mask as? CAShapeLayer

      var bounds = self.bounds
      bounds.size.height = max(bounds.size.height, collectionView?.bounds.height ?? 0)

      layerMask?.frame = bounds
      layerMask?.path = maskPathWithRect(bounds.inset(by: backgroundInsets), roundedCorner: roundedCorners)
    }
}
