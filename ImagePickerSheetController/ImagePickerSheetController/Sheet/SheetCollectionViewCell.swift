//
//  SheetCollectionViewCell.swift
//  ImagePickerSheetController
//
//  Created by Laurin Brandner on 24/08/15.
//  Copyright © 2015 Laurin Brandner. All rights reserved.
//

import UIKit

enum RoundedCorner {
    case all(CGFloat)
    case top(CGFloat)
    case bottom(CGFloat)
    case none
}

class SheetCollectionViewCell: UICollectionViewCell {

    var backgroundInsets = UIEdgeInsets() {
        didSet {
            reloadMask()
            reloadSeparator()
            setNeedsLayout()
        }
    }
    
    var roundedCorners = RoundedCorner.none {
        didSet {
            reloadMask()
        }
    }
    
    var separatorVisible = false {
        didSet {
            reloadSeparator()
        }
    }
    
    var separatorColor = UIColor.black {
        didSet {
            separatorView?.backgroundColor = separatorColor
        }
    }
    
    var separatorHeight: CGFloat = 1 {
        didSet {
            setNeedsLayout()
        }
    }
    
    fileprivate var separatorView: UIView?
    
    override var isHighlighted: Bool {
        didSet {
            reloadBackgroundColor()
        }
    }
    
    var highlightedBackgroundColor: UIColor = .clear {
        didSet {
            reloadBackgroundColor()
        }
    }
    
    var normalBackgroundColor: UIColor = .clear {
        didSet {
            reloadBackgroundColor()
        }
    }
    
    fileprivate var needsMasking: Bool {
        guard backgroundInsets == UIEdgeInsets() else {
            return true
        }
        
        switch roundedCorners {
        case .none:
            return false
        default:
            return true
        }
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
        layoutMargins = UIEdgeInsets()
    }
    
    // MARK: - Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        reloadMask()
        
        separatorView?.frame = CGRect(x: bounds.minY, y: bounds.maxY - separatorHeight, width: bounds.width, height: separatorHeight)
    }
    
    // MARK: - Mask
    
    fileprivate func reloadMask() {
        if needsMasking && layer.mask == nil {
            let maskLayer = CAShapeLayer()
            maskLayer.frame = bounds
            maskLayer.lineWidth = 0
            maskLayer.fillColor = UIColor.black.cgColor
            
            layer.mask = maskLayer
        }

        let layerMask = layer.mask as? CAShapeLayer
        layerMask?.frame = bounds
        layerMask?.path = maskPathWithRect(UIEdgeInsetsInsetRect(bounds, backgroundInsets), roundedCorner: roundedCorners)
    }
    
    fileprivate func maskPathWithRect(_ rect: CGRect, roundedCorner: RoundedCorner) -> CGPath {
        let radii: CGFloat
        let corners: UIRectCorner
        
        switch roundedCorner {
        case .all(let value):
            corners = .allCorners
            radii = value
        case .top(let value):
            corners = [.topLeft, .topRight]
            radii = value
        case .bottom(let value):
            corners = [.bottomLeft, .bottomRight]
            radii = value
        case .none:
            return UIBezierPath(rect: rect).cgPath
        }
        
        return UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radii, height: radii)).cgPath
    }
    
    // MARK: - Separator
    
    fileprivate func reloadSeparator() {
        if separatorVisible && backgroundInsets.bottom < separatorHeight {
            if separatorView == nil {
                let view = UIView()
                view.backgroundColor = separatorColor
                    
                addSubview(view)
                separatorView = view
            }
        }
        else {
            separatorView?.removeFromSuperview()
            separatorView = nil
        }
    }
    
    // MARK - Background
    
    fileprivate func reloadBackgroundColor() {
        backgroundColor = isHighlighted ? highlightedBackgroundColor : normalBackgroundColor
    }
    
}
