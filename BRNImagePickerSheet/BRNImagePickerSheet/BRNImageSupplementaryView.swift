//
//  BRNImageSupplementaryView.swift
//  BRNImagePickerSheet
//
//  Created by Laurin Brandner on 06/09/14.
//  Copyright (c) 2014 Laurin Brandner. All rights reserved.
//

import UIKit

class BRNImageSupplementaryView : UICollectionReusableView {
    
    private let button = UIButton()
    
    var selected: Bool = false {
        didSet {
            self.button.selected = self.selected
            self.button.backgroundColor = (self.selected) ? self.tintColor : nil
        }
    }
    
    private class var checkmarkImage: UIImage {
        return UIImage(named: "BRNImagePickerSheet-checkmark").imageWithRenderingMode(.AlwaysTemplate)
    }
    
    private class var selectedCheckmarkImage: UIImage {
        return UIImage(named: "BRNImagePickerSheet-checkmark-selected").imageWithRenderingMode(.AlwaysTemplate)
    }
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.button.tintColor = UIColor.whiteColor()
        self.button.setImage(BRNImageSupplementaryView.checkmarkImage, forState: .Normal)
        self.button.setImage(BRNImageSupplementaryView.selectedCheckmarkImage, forState: .Selected)
        self.addSubview(self.button)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.button.sizeToFit()
        self.button.frame.origin.y = CGRectGetHeight(self.bounds)-CGRectGetHeight(self.button.frame)-20
        self.button.layer.cornerRadius = CGRectGetHeight(self.button.frame) / 2.0
    }
    
}
