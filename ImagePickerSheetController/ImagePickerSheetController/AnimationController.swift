//
//  AnimationController.swift
//  ImagePickerSheet
//
//  Created by Laurin Brandner on 25/05/15.
//  Copyright (c) 2015 Laurin Brandner. All rights reserved.
//

import UIKit

@objc class AnimationController: NSObject {
    
    let imagePickerSheetController: ImagePickerSheetController
    let presenting: Bool
    
    // MARK: - Initialization
    
    init(imagePickerSheetController: ImagePickerSheetController, presenting: Bool) {
        self.imagePickerSheetController = imagePickerSheetController
        self.presenting = presenting
    }
    
    // MARK: - Animation
    
    private func animatePresentation(context: UIViewControllerContextTransitioning) {
        guard let containerView = context.containerView() else {
            return
        }
        
        containerView.addSubview(imagePickerSheetController.view)
        
        let sheetOriginY = imagePickerSheetController.sheetCollectionView.frame.origin.y
        imagePickerSheetController.sheetCollectionView.frame.origin.y = containerView.bounds.maxY
        imagePickerSheetController.backgroundView.alpha = 0
        
        UIView.animateWithDuration(transitionDuration(context), delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 0.9, options: .BeginFromCurrentState, animations: { () -> Void in
            self.imagePickerSheetController.sheetCollectionView.frame.origin.y = sheetOriginY
            self.imagePickerSheetController.backgroundView.alpha = 1
        }, completion: { _ in
            context.completeTransition(true)
        })
    }
    
    private func animateDismissal(context: UIViewControllerContextTransitioning) {
        guard let containerView = context.containerView() else {
            return
        }
        
        UIView.animateWithDuration(transitionDuration(context), delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1.0, options: .BeginFromCurrentState, animations: { () -> Void in
            self.imagePickerSheetController.sheetCollectionView.frame.origin.y = containerView.bounds.maxY
            self.imagePickerSheetController.backgroundView.alpha = 0
        }, completion: { _ in
            self.imagePickerSheetController.view.removeFromSuperview()
            context.completeTransition(true)
        })
    }
    
}

// MARK: - UIViewControllerAnimatedTransitioning
extension AnimationController: UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(transitionContext: UIViewControllerContextTransitioning?) -> NSTimeInterval {
        return 0.5
    }
    
    func animateTransition(transitionContext: UIViewControllerContextTransitioning) {
        if presenting {
            animatePresentation(transitionContext)
        }
        else {
            animateDismissal(transitionContext)
        }
    }
    
}
