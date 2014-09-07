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
        get {
            let contentOffset = self.contentOffset
            let contentSize = self.contentSize
            let contentInset = self.contentInset
            
            return contentOffset.x < contentInset.left || contentOffset.x + self.frame.width > contentSize.width + contentInset.right
        }
    }
    
    // MARK: Initialization

    override init(frame: CGRect, collectionViewLayout layout: UICollectionViewLayout) {
        super.init(frame: frame, collectionViewLayout: layout)
        
        self.panGestureRecognizer.addTarget(self, action: "handlePanGesture:")
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
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
