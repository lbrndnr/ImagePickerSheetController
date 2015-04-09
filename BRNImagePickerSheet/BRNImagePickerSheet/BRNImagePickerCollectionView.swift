//
//  BRNImagePickerCollectionView.swift
//  BRNImagePickerSheet
//
//  Created by Laurin Brandner on 07/09/14.
//  Copyright (c) 2014 Laurin Brandner. All rights reserved.
//

import UIKit

class BRNImagePickerCollectionView: UICollectionView {
    
    var bouncing: Bool {
        let contentOffset = self.contentOffset
        let contentSize = self.contentSize
        let contentInset = self.contentInset
        
        return contentOffset.x < -contentInset.left || contentOffset.x + self.frame.width > contentSize.width + contentInset.right
    }
    
    var horizontalImagePreviewLayout: BRNHorizontalImagePreviewFlowLayout {
        return self.collectionViewLayout as! BRNHorizontalImagePreviewFlowLayout
    }
    
    // MARK: Initialization

    init() {
        super.init(frame: CGRectZero, collectionViewLayout: BRNHorizontalImagePreviewFlowLayout())
        
        self.initialize()
    }

    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.initialize()
    }
    
    private func initialize() {
        self.panGestureRecognizer.addTarget(self, action: "handlePanGesture:")
    }
    
    // MARK: - Panning

    func handlePanGesture(gestureRecognizer: UIPanGestureRecognizer) {
        if gestureRecognizer.state == .Ended {
            let translation = gestureRecognizer.translationInView(self)
            if translation == CGPointZero {
                if !self.bouncing {
                    let possibleIndexPath = self.indexPathForItemAtPoint(gestureRecognizer.locationInView(self))
                    if let indexPath = possibleIndexPath {
                        self.selectItemAtIndexPath(indexPath, animated: false, scrollPosition: .None)
                        self.delegate?.collectionView?(self, didSelectItemAtIndexPath: indexPath)
                    }
                }
            }
        }
    }
    
}
