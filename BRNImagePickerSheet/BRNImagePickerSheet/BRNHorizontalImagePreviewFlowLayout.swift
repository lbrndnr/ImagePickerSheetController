//
//  BRNImagePreviewFlowLayout.swift
//  BRNImagePickerSheet
//
//  Created by Laurin Brandner on 06/09/14.
//  Copyright (c) 2014 Laurin Brandner. All rights reserved.
//

import UIKit

class BRNHorizontalImagePreviewFlowLayout: UICollectionViewFlowLayout {
    
    var invalidationCenteredIndexPath: NSIndexPath?
    
    var layoutAttributes = [UICollectionViewLayoutAttributes]()
    var contentSize = CGSizeZero
    
    var showsSupplementaryViews: Bool = true {
        didSet {
            self.invalidateLayout()
        }
    }
    
    // MARK: Initialization
    
    override init() {
        super.init()
        
        self.initialize()
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.initialize()
    }
    
    private func initialize() {
        self.scrollDirection = .Horizontal
    }

    // MARK: - Layout
    
    override func prepareLayout() {
        super.prepareLayout()
        
        self.layoutAttributes.removeAll(keepCapacity: false)
        self.contentSize = CGSizeZero
        
        // Could use swift 1.2 here
        if let collectionView = self.collectionView {
            if let dataSource = collectionView.dataSource {
                if let delegate = collectionView.delegate as? UICollectionViewDelegateFlowLayout {
                    var origin = CGPoint(x: self.sectionInset.left, y: self.sectionInset.top)
                    let numberOfSections = dataSource.numberOfSectionsInCollectionView?(collectionView) ?? 0
                    
                    for s in 0 ..< numberOfSections {
                        let indexPath = NSIndexPath(forRow: 0, inSection: s)
                        let size = delegate.collectionView?(collectionView, layout: self, sizeForItemAtIndexPath: indexPath) ?? CGSizeZero
                        
                        let attributes = UICollectionViewLayoutAttributes(forCellWithIndexPath: indexPath)
                        attributes.frame = CGRect(origin: origin, size: size)
                        attributes.zIndex = 0
                    
                        self.layoutAttributes.append(attributes)
                        
                        origin.x = attributes.frame.maxX + self.sectionInset.right
                    }
                    
                    self.contentSize = CGSize(width: origin.x, height: collectionView.frame.height)
                }
            }
        }
    }
    
    override func shouldInvalidateLayoutForBoundsChange(newBounds: CGRect) -> Bool {
        return true
    }
    
    override func collectionViewContentSize() -> CGSize {
        return self.contentSize
    }
    
    override func targetContentOffsetForProposedContentOffset(proposedContentOffset: CGPoint) -> CGPoint {
        var contentOffset = proposedContentOffset
        if let indexPath = self.invalidationCenteredIndexPath {
            if let collectionView = self.collectionView {
                let frame = self.layoutAttributes[indexPath.section].frame
                contentOffset.x = frame.midX - collectionView.frame.width / 2.0
                
                contentOffset.x = max(contentOffset.x, -collectionView.contentInset.left)
                contentOffset.x = min(contentOffset.x, self.collectionViewContentSize().width - collectionView.frame.width + collectionView.contentInset.right)
            }
            self.invalidationCenteredIndexPath = nil
        }
        
        return super.targetContentOffsetForProposedContentOffset(contentOffset)
    }
    
    override func layoutAttributesForElementsInRect(rect: CGRect) -> [AnyObject]? {
        return self.layoutAttributes.filter { CGRectIntersectsRect(rect, $0.frame) }.reduce([UICollectionViewLayoutAttributes](), combine: { memo, attributes in
            let supplementaryAttributes = self.layoutAttributesForSupplementaryViewOfKind(UICollectionElementKindSectionHeader, atIndexPath: attributes.indexPath)
            return memo + [attributes, supplementaryAttributes]
        })
    }
    
    override func layoutAttributesForItemAtIndexPath(indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes! {
        return self.layoutAttributes[indexPath.section]
    }
    
    override func layoutAttributesForSupplementaryViewOfKind(elementKind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionViewLayoutAttributes! {
        // swift 1.2
        if let collectionView = self.collectionView {
            if let dataSource = collectionView.dataSource {
                if let delegate = collectionView.delegate as? UICollectionViewDelegateFlowLayout {
                    let itemAttributes = self.layoutAttributesForItemAtIndexPath(indexPath)
                    
                    let inset = collectionView.contentInset
                    let bounds = collectionView.bounds
                    let contentOffset: CGPoint = {
                        var contentOffset = collectionView.contentOffset
                        contentOffset.x += inset.left
                        contentOffset.y += inset.top
                        
                        return contentOffset
                    }()
                    let visibleSize: CGSize = {
                        var size = bounds.size
                        size.width -= (inset.left+inset.right)
                        
                        return size
                    }()
                    let visibleFrame = CGRect(origin: contentOffset, size: visibleSize)
                    
                    let size = delegate.collectionView?(collectionView, layout: self, referenceSizeForHeaderInSection: indexPath.section) ?? CGSizeZero
                    let originX = max(itemAttributes.frame.minX, min(itemAttributes.frame.maxX - size.width, visibleFrame.maxX - size.width))
                    
                    let attributes = UICollectionViewLayoutAttributes(forSupplementaryViewOfKind: elementKind, withIndexPath: indexPath)
                    attributes.zIndex = 1
                    attributes.hidden = !self.showsSupplementaryViews
                    attributes.frame = CGRect(origin: CGPoint(x: originX, y: itemAttributes.frame.minY), size: size)
                    
                    return attributes
                }
            }
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
