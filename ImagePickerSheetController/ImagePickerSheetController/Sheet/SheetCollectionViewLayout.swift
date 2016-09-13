//
//  SheetCollectionViewLayout.swift
//  ImagePickerSheetController
//
//  Created by Laurin Brandner on 26/08/15.
//  Copyright © 2015 Laurin Brandner. All rights reserved.
//

import UIKit

class SheetCollectionViewLayout: UICollectionViewLayout {

    fileprivate var layoutAttributes = [[UICollectionViewLayoutAttributes]]()
    fileprivate var invalidatedLayoutAttributes: [[UICollectionViewLayoutAttributes]]?
    fileprivate var contentSize = CGSize.zero
    
    // MARK: - Layout
    
    override func prepare() {
        super.prepare()
        
        layoutAttributes.removeAll(keepingCapacity: false)
        contentSize = CGSize.zero
        
        if let collectionView = collectionView,
            let dataSource = collectionView.dataSource,
            let delegate = collectionView.delegate as? UICollectionViewDelegateFlowLayout {
                let sections = dataSource.numberOfSections?(in: collectionView) ?? 0
                var origin = CGPoint()
                
                for section in 0 ..< sections {
                    var sectionAttributes = [UICollectionViewLayoutAttributes]()
                    let items = dataSource.collectionView(collectionView, numberOfItemsInSection: section)
                    let indexPaths = (0 ..< items).map { IndexPath(item: $0, section: section) }
                    
                    for indexPath in indexPaths {
                        let size = delegate.collectionView?(collectionView, layout: self, sizeForItemAt: indexPath) ?? CGSize.zero
                        
                        let attributes = UICollectionViewLayoutAttributes(forCellWith: indexPath)
                        attributes.frame = CGRect(origin: origin, size: size)
                        
                        sectionAttributes.append(attributes)
                        origin.y = attributes.frame.maxY
                    }

                    layoutAttributes.append(sectionAttributes)
                }
                
                contentSize = CGSize(width: collectionView.frame.width, height: origin.y)
        }
    }
    
    override func shouldInvalidateLayout(forBoundsChange newBounds: CGRect) -> Bool {
        return true
    }
    
    override func invalidateLayout() {
        invalidatedLayoutAttributes = layoutAttributes
        super.invalidateLayout()
    }
    
    override var collectionViewContentSize : CGSize {
        return contentSize
    }
    
    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        return layoutAttributes.reduce([], +)
                               .filter { rect.intersects($0.frame) }
    }
    
    fileprivate func layoutAttributesForItemAtIndexPath(_ indexPath: IndexPath, allAttributes: [[UICollectionViewLayoutAttributes]]) -> UICollectionViewLayoutAttributes? {
        guard allAttributes.count > (indexPath as NSIndexPath).section && allAttributes[(indexPath as NSIndexPath).section].count > (indexPath as NSIndexPath).item else {
            return nil
        }
        
        return allAttributes[(indexPath as NSIndexPath).section][(indexPath as NSIndexPath).item]
    }
    
    fileprivate func invalidatedLayoutAttributesForItemAtIndexPath(_ indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        guard let invalidatedLayoutAttributes = invalidatedLayoutAttributes else {
            return nil
        }
        
        return layoutAttributesForItemAtIndexPath(indexPath, allAttributes: invalidatedLayoutAttributes)
    }
    
    override func layoutAttributesForItem(at indexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return layoutAttributesForItemAtIndexPath(indexPath, allAttributes: layoutAttributes)
    }
    
    override func initialLayoutAttributesForAppearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return invalidatedLayoutAttributesForItemAtIndexPath(itemIndexPath) ?? layoutAttributesForItem(at: itemIndexPath)
     }
    
    override func finalLayoutAttributesForDisappearingItem(at itemIndexPath: IndexPath) -> UICollectionViewLayoutAttributes? {
        return layoutAttributesForItem(at: itemIndexPath)
    }
    
}
