//
//  ImageSheetTableViewCell.swift
//  ImagePickerSheetController
//
//  Created by Laurin Brandner on 24/08/15.
//  Copyright © 2015 Laurin Brandner. All rights reserved.
//

import UIKit

enum RoundedCorner {
    case All(CGFloat)
    case Top(CGFloat)
    case Bottom(CGFloat)
    case None
}

class ImageSheetTableViewCell: UITableViewCell {

    var backgroundInsets = UIEdgeInsets() {
        didSet {
            reloadMask()
        }
    }
    
    var roundedCorners = RoundedCorner.None {
        didSet {
            reloadMask()
        }
    }
    
    // MARK: - Initialization
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        initialize()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initialize()
    }
    
    private func initialize() {
        layoutMargins = UIEdgeInsets()
    }
    
    // MARK: - Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        reloadMask()
    }
    
    // MARK: - Masking
    
    private func reloadMask() {
        if layer.mask == nil {
            let maskLayer = CAShapeLayer()
            maskLayer.frame = bounds
            maskLayer.fillColor = UIColor.blackColor().CGColor
            maskLayer.strokeColor = maskLayer.fillColor
            
            layer.mask = maskLayer
        }

        let layerMask = layer.mask as? CAShapeLayer
        layerMask?.frame = bounds
        layerMask?.path = maskPathWithRect(UIEdgeInsetsInsetRect(bounds, backgroundInsets), roundedCorner: roundedCorners)
    }
    
    private func maskPathWithRect(rect: CGRect, roundedCorner: RoundedCorner) -> CGPathRef {
        let radii: CGFloat
        let corners: UIRectCorner
        
        switch roundedCorner {
        case .All(let value):
            corners = .AllCorners
            radii = value
        case .Top(let value):
            corners = [.TopLeft, .TopRight]
            radii = value
        case .Bottom(let value):
            corners = [.BottomLeft, .BottomRight]
            radii = value
        case .None:
            return UIBezierPath(rect: rect).CGPath
        }
        
        return UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radii, height: radii)).CGPath
    }
    
}
