//
//  PreviewSupplementaryView.swift
//  ImagePickerSheet
//
//  Created by Laurin Brandner on 06/09/14.
//  Copyright (c) 2014 Laurin Brandner. All rights reserved.
//

import UIKit

class PreviewSupplementaryView: UIButton {

    var buttonInset = UIEdgeInsets.zero
    
    override var isSelected: Bool {
        didSet {
            reloadButtonBackgroundColor()
        }
    }
    
    class var checkmarkImage: UIImage? {
        let bundle = Bundle(for: ImagePickerSheetController.self)
        let image = UIImage(named: "PreviewSupplementaryView-Checkmark", in: bundle, compatibleWith: nil)
        
        return image?.withRenderingMode(.alwaysTemplate)
    }
    
    class var selectedCheckmarkImage: UIImage? {
        let bundle = Bundle(for: ImagePickerSheetController.self)
        let image = UIImage(named: "PreviewSupplementaryView-Checkmark-Selected", in: bundle, compatibleWith: nil)
        
        return image?.withRenderingMode(.alwaysTemplate)
    }
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        initialize()
    }
    
    fileprivate func initialize() {
        tintColor = .white
        layer.cornerRadius = frame.height / 2
        isUserInteractionEnabled = false
        setImage(PreviewSupplementaryView.checkmarkImage, for: UIControl.State())
        setImage(PreviewSupplementaryView.selectedCheckmarkImage, for: .selected)
    }
    
    override func tintColorDidChange() {
        super.tintColorDidChange()
        
        reloadButtonBackgroundColor()
    }
    
    fileprivate func reloadButtonBackgroundColor() {
        backgroundColor = isSelected ? superview?.tintColor : .clear
    }
}
