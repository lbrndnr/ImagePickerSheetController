//
//  AnimationController.swift
//  ImagePickerSheet
//
//  Created by Laurin Brandner on 25/05/15.
//  Copyright (c) 2015 Laurin Brandner. All rights reserved.
//

import UIKit

class AnimationController: NSObject, UIViewControllerAnimatedTransitioning {
    
    let presenting: Bool
    
    // MARK: - Initialization
    
    init(presenting: Bool) {
        self.presenting = presenting
    }
    
    // MARK: - UIViewControllerAnimatedTransitioning
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning) -> NSTimeInterval {
        return 0.3
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        if presenting {
            animatePresentation()
        }
        else {
            animateDismissal()
        }
    }
    
    // MARK: - Animation
    
    private func animatePresentation() {
        
    }
    
    private func animateDismissal() {
        
    }
    
}
