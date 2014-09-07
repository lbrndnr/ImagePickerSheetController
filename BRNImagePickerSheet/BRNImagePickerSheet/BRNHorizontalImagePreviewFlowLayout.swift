//
//  BRNImagePreviewFlowLayout.swift
//  BRNImagePickerSheet
//
//  Created by Laurin Brandner on 06/09/14.
//  Copyright (c) 2014 Laurin Brandner. All rights reserved.
//

import UIKit

class BRNHorizontalImagePreviewFlowLayout: UICollectionViewFlowLayout {
    
    var showsSupplementaryViews: Bool = true {
        didSet {
            self.invalidateLayout()
        }
    }
    
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
                let itemAttributes = self.layoutAttributesForItemAtIndexPath(indexPath)
                let headerAttributes = self.layoutAttributesForSupplementaryViewOfKind(UICollectionElementKindSectionHeader, atIndexPath: indexPath)
                
                allAttributes += [itemAttributes, headerAttributes]
            }
            
            itemOrigin.x = itemFrame.maxX + self.sectionInset.right
        }

        return allAttributes
    }
    
    override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes! {
        if (self.collectionView == nil || self.collectionView?.dataSource == nil) {
            return nil
        }
        
        let collectionView = self.collectionView!
        let dataSource = collectionView.dataSource!
        let layoutDataSource: UICollectionViewDelegateFlowLayout = collectionView.dataSource! as UICollectionViewDelegateFlowLayout
        
        // TODO: really necessary to have to dataSources?
        
        var origin = CGPoint(x: self.sectionInset.left, y: self.sectionInset.top)
        for section in 0 ..< dataSource.numberOfSectionsInCollectionView!(collectionView) {
            let currentIndexPath = NSIndexPath(forRow: 0, inSection: section)
            let size = layoutDataSource.collectionView!(collectionView, layout: self, sizeForItemAtIndexPath: currentIndexPath)
            let frame = CGRect(origin: origin, size: size)
            
            if currentIndexPath == indexPath {
                let attributes = UICollectionViewLayoutAttributes(forCellWithIndexPath: indexPath)
                attributes.zIndex = 0
                attributes.frame = frame
                
                return attributes
            }
            
            origin.x = frame.maxX + self.sectionInset.right
        }
        
        return nil
    }
    
    override func layoutAttributesForSupplementaryViewOfKind(elementKind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes! {
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
        
        let possibleItemAttributes = self.layoutAttributesForItemAtIndexPath(indexPath)
        if let itemAttributes = possibleItemAttributes {
            let itemFrame = itemAttributes.frame
            
            let attributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: elementKind, withIndexPath: indexPath)
            attributes.zIndex = 1
            attributes.hidden = !self.showsSupplementaryViews
            
            let size = layoutDataSource.collectionView!(collectionView, layout: self, referenceSizeForHeaderInSection: indexPath.section)
            let originX = max(itemFrame.minX, min(itemFrame.maxX - size.width, visibleFrame.maxX - size.width))
            attributes.frame = CGRect(origin: CGPoint(x: originX, y: itemFrame.minY), size: size)
            
            return attributes
        }
        
        return nil
    }
    
    override func initialLayoutAttributesForAppearingItemAtIndexPath(itemIndexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        return self.layoutAttributesForItemAtIndexPath(itemIndexPath)
    }
    
    override func finalLayoutAttributesForDisappearingItemAtIndexPath(itemIndexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        return self.layoutAttributesForItemAtIndexPath(itemIndexPath)
    }
    
}
