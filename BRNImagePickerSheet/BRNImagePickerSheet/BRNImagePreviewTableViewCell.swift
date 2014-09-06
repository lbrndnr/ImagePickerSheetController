//
//  BRNImagePreviewTableViewCell.swift
//  BRNImagePickerSheet
//
//  Created by Laurin Brandner on 06/09/14.
//  Copyright (c) 2014 Laurin Brandner. All rights reserved.
//

import UIKit

class BRNImagePreviewTableViewCell : UITableViewCell {
    
    var collectionView: UICollectionView? {
        willSet {
            if let collectionView = self.collectionView {
                collectionView.removeFromSuperview()
            }
            
            if let collectionView = newValue {
                self.addSubview(collectionView)
            }
        }
    }
    
    // MARK: Other Methods
    
    override func prepareForReuse() {
        self.collectionView = nil
    }
    
    // MARK: - Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if let collectionView = self.collectionView {
            collectionView.frame = self.bounds
        }
    }
    
}
