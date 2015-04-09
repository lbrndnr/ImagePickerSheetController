//
//  ImageSupplementaryView.swift
//  ImagePickerSheet
//
//  Created by Laurin Brandner on 06/09/14.
//  Copyright (c) 2014 Laurin Brandner. All rights reserved.
//

import UIKit

class ImageSupplementaryView : UICollectionReusableView {
    
    private let button: UIButton = {
        let button = UIButton()
        button.tintColor = UIColor.whiteColor()
        button.userInteractionEnabled = false
        button.setImage(ImageSupplementaryView.checkmarkImage, forState: .Normal)
        button.setImage(ImageSupplementaryView.selectedCheckmarkImage, forState: .Selected)
        
        return button
    }()
    
    var buttonInset = UIEdgeInsetsZero
    
    var selected: Bool = false {
        didSet {
            self.button.selected = self.selected
            self.button.backgroundColor = (self.selected) ? self.tintColor : nil
        }
    }
    
    class var checkmarkImage: UIImage? {
        let bundle = NSBundle(forClass: ImagePickerSheet.self)
        let image = UIImage(named: "ImagePickerSheet-checkmark", inBundle: bundle, compatibleWithTraitCollection: nil)
        
        return image?.imageWithRenderingMode(.AlwaysTemplate)
    }
    
    class var selectedCheckmarkImage: UIImage? {
        let bundle = NSBundle(forClass: ImagePickerSheet.self)
        let image = UIImage(named: "ImagePickerSheet-checkmark-selected", inBundle: bundle, compatibleWithTraitCollection: nil)
        
        return image?.imageWithRenderingMode(.AlwaysTemplate)
    }
    
    // MARK: Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.initialize()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.initialize()
    }
    
    private func initialize() {
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
