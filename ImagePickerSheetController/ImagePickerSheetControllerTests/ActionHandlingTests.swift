//
//  ActionHandlingTests.swift
//  ImagePickerSheetController
//
//  Created by Laurin Brandner on 06/09/15.
//  Copyright © 2015 Laurin Brandner. All rights reserved.
//

import XCTest
import KIF
import Nimble
import ImagePickerSheetController

class ActionHandlingTests: ImagePickerSheetControllerTests {
    
    // MARK: - Action Handling
    
    var defaultAction: ImagePickerAction!
    var cancelAction: ImagePickerAction!
    
    var defaultActionCalled: Int!
    var cancelActionCalled: Int!
    
    override func setUp() {
        super.setUp()
        
        defaultActionCalled = 0
        cancelActionCalled = 0
        
        defaultAction = ImagePickerAction(title: "Action", handler: { _ in
            self.defaultActionCalled = self.defaultActionCalled+1
        })
        imageController.addAction(defaultAction)
        
        cancelAction = ImagePickerAction(title: "Cancel", style: .Cancel, handler: { _ in
            self.cancelActionCalled = self.cancelActionCalled+1
        })
        imageController.addAction(cancelAction)
    }
    
    func testDefaultActionHandling() {
        presentImagePickerSheetController()
        
        tester().tapViewWithAccessibilityLabel(defaultAction.title)
        
        expect(self.defaultActionCalled) == 1
        expect(self.cancelActionCalled) == 0
    }
    
    func testCancelActionHandlingWhenTappingAction() {
        presentImagePickerSheetController()
        
        tester().tapViewWithAccessibilityLabel(cancelAction.title)
        
        expect(self.defaultActionCalled) == 0
        expect(self.cancelActionCalled) == 1
    }
    
    func testCancelActionHandlingWhenTappingBackground() {
        presentImagePickerSheetController()
        
        tester().tapViewWithAccessibilityIdentifier(imageControllerBackgroundViewIdentifier)
        
        expect(self.defaultActionCalled) == 0
        expect(self.cancelActionCalled) == 1
    }
    
    func testAdaptionOfActionTitles() {
        imageController.addAction(ImagePickerAction(title: "Action", secondaryTitle: { "Secondary \($0)" }))
        presentImagePickerSheetController()
        
        let indexPath = NSIndexPath(forItem: 0, inSection: 0)
        tester().tapImagePreviewAtIndexPath(indexPath, inCollectionViewWithAccessibilityIdentifier: imageControllerPreviewIdentifier)
        
        tester().waitForViewWithAccessibilityLabel("Secondary 1")
    }
    
}
