//
//  ImageActionCollectionViewCell.swift
//  ImagePickerSheetController
//
//  Created by Laurin Brandner on 26/08/15.
//  Copyright © 2015 Laurin Brandner. All rights reserved.
//

import UIKit

class ImageActionCollectionViewCell: ImageSheetCollectionViewCell {

    lazy private(set) var textLabel: UILabel = {
        let label = UILabel()
        label.textColor = self.tintColor
        label.textAlignment = .Center
        
        self.addSubview(label)
        
        return label
    }()
    
    override func tintColorDidChange() {
        super.tintColorDidChange()
        
        textLabel.textColor = tintColor
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        textLabel.frame = UIEdgeInsetsInsetRect(bounds, backgroundInsets)
    }
    
}
