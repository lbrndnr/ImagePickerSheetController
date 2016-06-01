//
//  PreviewCollectionView.swift
//  ImagePickerSheet
//
//  Created by Laurin Brandner on 07/09/14.
//  Copyright (c) 2014 Laurin Brandner. All rights reserved.
//

import UIKit

class PreviewCollectionView: UICollectionView {
    
    var bouncing: Bool {
        if contentOffset.x < -contentInset.left { return true }
        if contentOffset.x + frame.width > contentSize.width + contentInset.right { return true }
        return false
    }
    
    var imagePreviewLayout: PreviewCollectionViewLayout {
        return collectionViewLayout as! PreviewCollectionViewLayout
    }
    
    // MARK: - Initialization

    init() {
        super.init(frame: CGRectZero, collectionViewLayout: PreviewCollectionViewLayout())
        
        initialize()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        initialize()
    }
    
    private func initialize() {
        panGestureRecognizer.addTarget(self, action: #selector(PreviewCollectionView.handlePanGesture(_:)))
    }
    
    // MARK: - Panning

    @objc private func handlePanGesture(gestureRecognizer: UIPanGestureRecognizer) {
        if gestureRecognizer.state == .Ended {
            let translation = gestureRecognizer.translationInView(self)
            if translation == CGPoint() {
                if !bouncing {
                    let possibleIndexPath = indexPathForItemAtPoint(gestureRecognizer.locationInView(self))
                    if let indexPath = possibleIndexPath {
                        selectItemAtIndexPath(indexPath, animated: false, scrollPosition: .None)
                        delegate?.collectionView?(self, didSelectItemAtIndexPath: indexPath)
                    }
                }
            }
        }
    }
    
}
