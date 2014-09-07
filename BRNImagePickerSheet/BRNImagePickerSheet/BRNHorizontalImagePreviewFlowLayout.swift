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
        if self.collectionView == nil {
            return CGSizeZero
        }
        
        let collectionView = self.collectionView!
        let dataSource = collectionView.dataSource!
        let layoutDataSource: UICollectionViewDelegateFlowLayout = collectionView.dataSource! as UICollectionViewDelegateFlowLayout
        
        // TODO: really necessary to have to dataSources?
        
        var width: CGFloat = self.sectionInset.left
        for section in 0 ..< dataSource.numberOfSectionsInCollectionView!(collectionView) {
            let indexPath = NSIndexPath(forRow: 0, inSection: section)
            let size = layoutDataSource.collectionView!(collectionView, layout: self, sizeForItemAtIndexPath: indexPath)
            
            width += size.width + self.sectionInset.right
        }
        
        return CGSizeMake(width, collectionView.frame.height)
    }
    
    override func shouldInvalidateLayoutForBoundsChange(newBounds: CGRect) -> Bool {
        return true
    }
    
    override func layoutAttributesForElementsInRect(rect: CGRect) -> [AnyObject]? {
        if (self.collectionView == nil || self.collectionView?.dataSource == nil) {
            return nil
        }
        
        let collectionView = self.collectionView!
        let dataSource = collectionView.dataSource!
        let layoutDataSource: UICollectionViewDelegateFlowLayout = collectionView.dataSource! as UICollectionViewDelegateFlowLayout
        
        // TODO: really necessary to have to dataSources?
        
        let contentOffset = collectionView.contentOffset
        let collectionViewSize = collectionView.frame.size
        let visibleFrame = CGRect(origin: contentOffset, size: collectionViewSize)
        
        var allAttributes = [UICollectionViewLayoutAttributes]()
        var itemOrigin = CGPoint(x: self.sectionInset.left, y: self.sectionInset.top)
        for section in 0 ..< dataSource.numberOfSectionsInCollectionView!(collectionView) {
            let indexPath = NSIndexPath(forRow: 0, inSection: section)
            let itemSize = layoutDataSource.collectionView!(collectionView, layout: self, sizeForItemAtIndexPath: indexPath)
            let itemFrame = CGRect(origin: itemOrigin, size: itemSize)
            
            if visibleFrame.intersects(itemFrame) {
                let itemAttributes = UICollectionViewLayoutAttributes(forCellWithIndexPath: indexPath)
                itemAttributes.zIndex = 0
                itemAttributes.frame = itemFrame
                
                let headerAttributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withIndexPath: indexPath)
                headerAttributes.zIndex = 1
                
                let headerSize = layoutDataSource.collectionView!(collectionView, layout: self, referenceSizeForHeaderInSection: section)
                let headerOriginX = max(itemFrame.minX, min(itemFrame.maxX - headerSize.width, visibleFrame.maxX - headerSize.width))
                headerAttributes.frame = CGRect(origin: CGPoint(x: headerOriginX, y: itemFrame.minY), size: headerSize)
                
                allAttributes += [itemAttributes, headerAttributes]
            }
            
            itemOrigin.x = itemFrame.maxX + self.sectionInset.right
        }

        return allAttributes
    }
    
    override func initialLayoutAttributesForAppearingItemAtIndexPath(itemIndexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        let possibleAttributes = super.initialLayoutAttributesForAppearingItemAtIndexPath(itemIndexPath)
        if let attributes = possibleAttributes {
            attributes.alpha = 1.0
        }
        
        return possibleAttributes
    }
    
    override func finalLayoutAttributesForDisappearingItemAtIndexPath(itemIndexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        let possibleAttributes = super.finalLayoutAttributesForDisappearingItemAtIndexPath(itemIndexPath)
        if let attributes = possibleAttributes {
            attributes.alpha = 1.0
        }
        
        return possibleAttributes
    }
    
}
