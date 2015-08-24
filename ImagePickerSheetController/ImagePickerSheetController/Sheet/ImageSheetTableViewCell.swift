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

    var roundedCorners = RoundedCorner.None {
        didSet {
            reloadMask()
        }
    }
    
    // MARK: - Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        layer.mask?.frame = bounds
        
        reloadMask()
    }
    
    // MARK: - Masking
    
    private func reloadMask() {
        let maskLayer = layer.mask as? CAShapeLayer ?? {
            let maskLayer = CAShapeLayer()
            maskLayer.frame = bounds
            maskLayer.fillColor = UIColor.blackColor().CGColor
            maskLayer.strokeColor = maskLayer.fillColor
            layer.mask = maskLayer
            
            return maskLayer
        }()
        
        maskLayer.path = maskPathWithRect(UIEdgeInsetsInsetRect(bounds, layoutMargins), roundedCorner: roundedCorners)
    }
    
    private func maskPathWithRect(rect: CGRect, roundedCorner: RoundedCorner) -> CGPathRef {
        let radii: CGFloat
        let corners: UIRectCorner
        
        switch roundedCorner {
        case .All(let value):
            corners = .AllCorners
            radii = value
        case .Top(let value):
            corners = .AllCorners
            radii = value
        case .Bottom(let value):
            corners = .AllCorners
            radii = value
        case .None:
            return UIBezierPath(rect: rect).CGPath
        }
        
        return UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radii, height: radii)).CGPath
    }
    
}
