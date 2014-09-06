//
//  BRNImagePreviewTableViewCell.swift
//  BRNImagePickerSheet
//
//  Created by Laurin Brandner on 06/09/14.
//  Copyright (c) 2014 Laurin Brandner. All rights reserved.
//

import UIKit

@objc protocol BRNImagePreviewTableViewCellDelegate {
    
    optional func imagePreviewCell(imagePreviewCell: BRNImagePreviewTableViewCell, didSelectImageAtIndex imageIndex: Int)
    
    optional func imagePreviewCell(imagePreviewCell: BRNImagePreviewTableViewCell, didDeselectImageAtIndex imageIndex: Int)
    
}

class BRNImagePreviewTableViewCell : UITableViewCell, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    private let collectionView: UICollectionView
    
    var delegate: BRNImagePreviewTableViewCellDelegate?
    var photos = [UIImage]()
    private var sections = [Int: BRNImageSupplementaryView]()
    
    private class var sectionInset: UIEdgeInsets {
        return UIEdgeInsetsMake(4.0, 0.0, 4.0, -16.0)
    }
    
    private class var contentInset: UIEdgeInsets {
        return UIEdgeInsetsMake(0.0, 4.0, 0.0, 4.0)
    }
    
    // MARK: Initialization
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .Horizontal
        layout.sectionInset = BRNImagePreviewTableViewCell.sectionInset
        layout.footerReferenceSize = CGSizeMake(20.0, 0.0)
        self.collectionView = UICollectionView(frame: CGRectZero, collectionViewLayout: layout)
        
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        self.collectionView.contentInset = BRNImagePreviewTableViewCell.contentInset
        self.collectionView.backgroundColor = UIColor.clearColor()
        self.collectionView.showsHorizontalScrollIndicator = false
        self.collectionView.alwaysBounceHorizontal = true
        self.collectionView.registerClass(BRNImageCollectionViewCell.classForCoder(), forCellWithReuseIdentifier: "Cell")
        self.collectionView.registerClass(BRNImageSupplementaryView.classForCoder(), forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: "SupplementaryView")
        self.addSubview(self.collectionView)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UICollectionViewDataSource
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return self.photos.count
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 1
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell: BRNImageCollectionViewCell = collectionView.dequeueReusableCellWithReuseIdentifier("Cell", forIndexPath: indexPath) as BRNImageCollectionViewCell
        cell.imageView.image = self.photos[indexPath.section]
        
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        let view: BRNImageSupplementaryView = collectionView.dequeueReusableSupplementaryViewOfKind(UICollectionElementKindSectionFooter, withReuseIdentifier: "SupplementaryView", forIndexPath: indexPath) as BRNImageSupplementaryView
        view.userInteractionEnabled = false
        
        self.sections[indexPath.section] = view
        return view
    }
    
    // MARK: - UICollectionViewDelegateFlowLayout
    
    func collectionView(collectionView: UICollectionView, layout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        let photo = self.photos[indexPath.section]
        let height = CGRectGetHeight(self.frame) - BRNImagePreviewTableViewCell.sectionInset.top - BRNImagePreviewTableViewCell.sectionInset.bottom
        let factor = height / photo.size.height
        
        return CGSizeMake(factor * photo.size.width, height)
    }
    
    // MARK: - UICollectionViewDelegate
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        let possibleView = self.sections[indexPath.section]
        if let view = possibleView {
            view.selected = true
        }
        
        self.delegate?.imagePreviewCell?(self, didSelectImageAtIndex: indexPath.section)
    }
    
    func collectionView(collectionView: UICollectionView, didDeselectItemAtIndexPath indexPath: NSIndexPath) {
        let possibleView = self.sections[indexPath.section]
        if let view = possibleView {
            view.selected = false
        }
        
        self.delegate?.imagePreviewCell?(self, didDeselectImageAtIndex: indexPath.section)
    }
    
    // MARK: - Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.collectionView.frame = self.bounds
    }
    
}
