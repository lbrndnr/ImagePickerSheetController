//
//  BRNImagePreviewFlowLayout.swift
//  BRNImagePickerSheet
//
//  Created by Laurin Brandner on 06/09/14.
//  Copyright (c) 2014 Laurin Brandner. All rights reserved.
//

import UIKit

@objc public class BRNHorizontalImagePreviewFlowLayout: UICollectionViewFlowLayout {
    
    var invalidationCenteredIndexPath: NSIndexPath?
    var supplementaryViewBounds: CGSize?
    
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

    required public init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Layout
    
    override public func collectionViewContentSize() -> CGSize {
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
    
    override public func targetContentOffsetForProposedContentOffset(proposedContentOffset: CGPoint) -> CGPoint {
        var contentOffset = proposedContentOffset
        if let indexPath = self.invalidationCenteredIndexPath {
            if let collectionView = self.collectionView {
                let frame = self.frameAttributeForItemAtIndexPath(indexPath)
                contentOffset.x = frame.midX - collectionView.frame.width / 2.0
                
                contentOffset.x = max(contentOffset.x, -collectionView.contentInset.left)
                contentOffset.x = min(contentOffset.x, self.collectionViewContentSize().width - collectionView.frame.width + collectionView.contentInset.right)
            }
            self.invalidationCenteredIndexPath = nil
        }
        
        return super.targetContentOffsetForProposedContentOffset(contentOffset)
    }
    
    override public func shouldInvalidateLayoutForBoundsChange(newBounds: CGRect) -> Bool {
        if (self.collectionView == nil) {
            return true
        }
        
        return (self.collectionView!.bounds != newBounds)
    }
    
    override public func layoutAttributesForElementsInRect(rect: CGRect) -> [AnyObject]? {
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
                let itemAttributes = self.layoutAttributesForItemAtIndexPath(indexPath, frame: itemFrame)
                let headerAttributes = self.layoutAttributesForSupplementaryViewOfKind(UICollectionElementKindSectionHeader, atIndexPath: indexPath, itemFrame: itemFrame)
                
                allAttributes += [itemAttributes, headerAttributes]
            }

            itemOrigin.x = itemFrame.maxX + self.sectionInset.right
        }

        return allAttributes
    }
    
    override public func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes! {
        return self.layoutAttributesForItemAtIndexPath(indexPath, frame: nil)
    }
    
    func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath, var frame: CGRect?) -> UICollectionViewLayoutAttributes! {
        let attributes = UICollectionViewLayoutAttributes(forCellWithIndexPath: indexPath)
        attributes.zIndex = 0
        
        if frame == nil {
            frame = self.frameAttributeForItemAtIndexPath(indexPath)
        }
        attributes.frame = frame!
        
        return attributes
    }
    
    func frameAttributeForItemAtIndexPath(indexPath: NSIndexPath) -> CGRect {
        if (self.collectionView == nil || self.collectionView?.dataSource == nil) {
            return CGRectZero
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
                return frame
            }
            
            origin.x = frame.maxX + self.sectionInset.right
        }
        
        return CGRectZero
    }
    
    override public func layoutAttributesForSupplementaryViewOfKind(elementKind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes! {
        return self.layoutAttributesForSupplementaryViewOfKind(elementKind, atIndexPath: indexPath, itemFrame: nil)
    }
    
    func layoutAttributesForSupplementaryViewOfKind(elementKind: String, atIndexPath indexPath: NSIndexPath, var itemFrame: CGRect?) -> UICollectionViewLayoutAttributes! {
        let attributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: elementKind, withIndexPath: indexPath)
        attributes.zIndex = 1
        attributes.hidden = !self.showsSupplementaryViews
        
        if itemFrame == nil {
            itemFrame = self.frameAttributeForItemAtIndexPath(indexPath)
        }
        
        attributes.frame = self.frameAttributeForSupplementaryViewAtIndexPath(indexPath, itemFrame: itemFrame!)
        
        return attributes
    }
    
    func frameAttributeForSupplementaryViewAtIndexPath(indexPath: NSIndexPath, itemFrame: CGRect) -> CGRect {
        if (self.collectionView == nil || self.collectionView?.dataSource == nil) {
            return CGRectZero
        }
        
        let collectionView = self.collectionView!
        let layoutDataSource: UICollectionViewDelegateFlowLayout = collectionView.dataSource! as UICollectionViewDelegateFlowLayout
        
        var contentOffset = collectionView.contentOffset
        contentOffset.x += collectionView.contentInset.left
        var collectionViewSize = collectionView.frame.size
        if let size = self.supplementaryViewBounds {
            collectionViewSize = size
        }
        
        let visibleFrame = CGRect(origin: contentOffset, size: collectionViewSize)
        
        let size = layoutDataSource.collectionView!(collectionView, layout: self, referenceSizeForHeaderInSection: indexPath.section)
        let originX = max(itemFrame.minX, min(itemFrame.maxX - size.width, visibleFrame.maxX - size.width))
        
        return CGRect(origin: CGPoint(x: originX, y: itemFrame.minY), size: size)
    }
    
    override public func initialLayoutAttributesForAppearingItemAtIndexPath(itemIndexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        return self.layoutAttributesForItemAtIndexPath(itemIndexPath)
    }
    
    override public func finalLayoutAttributesForDisappearingItemAtIndexPath(itemIndexPath: NSIndexPath) -> UICollectionViewLayoutAttributes? {
        return self.layoutAttributesForItemAtIndexPath(itemIndexPath)
    }
    
}
