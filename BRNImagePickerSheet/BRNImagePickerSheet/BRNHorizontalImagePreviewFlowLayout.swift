//
//  BRNImagePreviewFlowLayout.swift
//  BRNImagePickerSheet
//
//  Created by Laurin Brandner on 06/09/14.
//  Copyright (c) 2014 Laurin Brandner. All rights reserved.
//

import UIKit

class BRNHorizontalImagePreviewFlowLayout: UICollectionViewFlowLayout {
    
    // MARK: Initialization
    
    override init() {
        super.init()
        
        self.scrollDirection = .Horizontal
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Layout
    
    override func collectionViewContentSize() -> CGSize {
        var contentSize = super.collectionViewContentSize()
        
        if let collectionView = self.collectionView {
            var sectionsCount = collectionView.numberOfSections()
            contentSize.width -= CGFloat(sectionsCount) * self.headerReferenceSize.width
        }
        
        return contentSize
    }
    
    override func shouldInvalidateLayoutForBoundsChange(newBounds: CGRect) -> Bool {
        return true
    }
    
    override func layoutAttributesForElementsInRect(rect: CGRect) -> [AnyObject]? {
        let attributes: [UICollectionViewLayoutAttributes] = super.layoutAttributesForElementsInRect(rect) as [UICollectionViewLayoutAttributes]
        
        var sectionedAttributes = [Int: UICollectionViewLayoutAttributes]()
        for attribute in attributes {
            if attribute.representedElementCategory == .Cell {
                attribute.zIndex = 0
                attribute.frame.origin.x -= CGFloat(attribute.indexPath.section+1) * self.headerReferenceSize.width
                
                sectionedAttributes[attribute.indexPath.section] = attribute
            }
        }
        
        for attribute in attributes {
            if attribute.representedElementCategory == .SupplementaryView {
                attribute.zIndex = 1
                
                let width = CGRectGetWidth(attribute.frame)
                let contentOffset = (self.collectionView? != nil) ? (self.collectionView!.contentOffset.x + CGRectGetWidth(self.collectionView!.frame) - width) : 0.0
                var minOriginX: CGFloat = 0.0
                var maxOriginX: CGFloat = 0.0
                let possibleCellAttributes = sectionedAttributes[attribute.indexPath.section]
                if let cellAttributes = possibleCellAttributes {
                    minOriginX = CGRectGetMinX(cellAttributes.frame)
                    maxOriginX = CGRectGetMaxX(cellAttributes.frame)-width
                }

                attribute.frame.origin.x = max(minOriginX, min(maxOriginX, contentOffset))
            }
        }
        
        return attributes
    }
    
}
