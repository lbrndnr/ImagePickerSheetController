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
    
    var buttonInset = UIEdgeInsetsZero
    
    var selected: Bool = false {
        didSet {
            self.button.selected = self.selected
            self.button.backgroundColor = (self.selected) ? self.tintColor : nil
        }
    }
    
    class var checkmarkImage: UIImage {
        let bundle = NSBundle(forClass: BRNImagePickerSheet.self)
        let image = UIImage(named: "BRNImagePickerSheet-checkmark", inBundle: bundle, compatibleWithTraitCollection: nil)
        
        return image!.imageWithRenderingMode(.AlwaysTemplate)
    }
    
    class var selectedCheckmarkImage: UIImage {
        let bundle = NSBundle(forClass: BRNImagePickerSheet.self)
        let image = UIImage(named: "BRNImagePickerSheet-checkmark-selected", inBundle: bundle, compatibleWithTraitCollection: nil)
        
        return image!.imageWithRenderingMode(.AlwaysTemplate)
    }
    
    // MARK: Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.setup()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.setup()
    }
    
    private func setup() {
        self.button.tintColor = UIColor.whiteColor()
        self.button.setImage(BRNImageSupplementaryView.checkmarkImage, forState: .Normal)
        self.button.setImage(BRNImageSupplementaryView.selectedCheckmarkImage, forState: .Selected)
        self.addSubview(self.button)
    }
    
    // MARK: - Other Methods
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        self.selected = false
    }
    
    // MARK: - Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        self.button.sizeToFit()
        self.button.frame.origin = CGPointMake(self.buttonInset.left, CGRectGetHeight(self.bounds)-CGRectGetHeight(self.button.frame)-self.buttonInset.bottom)
        self.button.layer.cornerRadius = CGRectGetHeight(self.button.frame) / 2.0
    }
    
}
