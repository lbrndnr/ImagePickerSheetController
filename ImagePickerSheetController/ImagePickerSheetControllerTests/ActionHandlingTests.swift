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
    
    var defaultAction: ImagePickerAction!
    var cancelAction: ImagePickerAction!
    
    var defaultActionCalled: Int!
    var defaultSecondaryActionCalled: Int!
    var cancelActionCalled: Int!
    var cancelSecondaryActionCalled: Int!
    
    override func setUp() {
        super.setUp()
        
        defaultActionCalled = 0
        defaultSecondaryActionCalled = 0
        cancelActionCalled = 0
        cancelSecondaryActionCalled = 0
        
        defaultAction = ImagePickerAction(title: "Action", handler: { _ in
            self.defaultActionCalled = self.defaultActionCalled+1
        }, secondaryHandler: { _, _ in
            self.defaultSecondaryActionCalled = self.defaultSecondaryActionCalled+1
        })
        imageController.addAction(defaultAction)
        
        cancelAction = ImagePickerAction(title: "Cancel", style: .cancel, handler: { _ in
            self.cancelActionCalled = self.cancelActionCalled+1
        }, secondaryHandler: { _, _ in
            self.cancelSecondaryActionCalled = self.cancelSecondaryActionCalled+1
        })
        imageController.addAction(cancelAction)
    }
    
    func testDefaultActionHandling() {
        presentImagePickerSheetController()
        
        tester().tapView(withAccessibilityLabel: defaultAction.title)
        
        expect(self.defaultActionCalled) == 1
        expect(self.defaultSecondaryActionCalled) == 0
        expect(self.cancelActionCalled) == 0
        expect(self.cancelSecondaryActionCalled) == 0
    }
    
    func testSecondaryActionHandling() {
        presentImagePickerSheetController()
        
        tester().tapImagePreviewAtIndexPath(IndexPath(item: 0, section: 0), inCollectionViewWithAccessibilityIdentifier: imageControllerPreviewIdentifier)
        tester().tapView(withAccessibilityLabel: defaultAction.title)
        
        expect(self.defaultActionCalled) == 0
        expect(self.defaultSecondaryActionCalled) == 1
        expect(self.cancelActionCalled) == 0
        expect(self.cancelSecondaryActionCalled) == 0
    }
    
    func testCancelActionHandlingWhenTappingAction() {
        presentImagePickerSheetController()
        
        tester().tapView(withAccessibilityLabel: cancelAction.title)
        
        expect(self.defaultActionCalled) == 0
        expect(self.defaultSecondaryActionCalled) == 0
        expect(self.cancelActionCalled) == 1
        expect(self.cancelSecondaryActionCalled) == 0
    }
    
    func testCancelActionHandlingWhenTappingBackground() {
        presentImagePickerSheetController()
        
        tester().tapView(withAccessibilityIdentifier: imageControllerBackgroundViewIdentifier)
        
        expect(self.defaultActionCalled) == 0
        expect(self.defaultSecondaryActionCalled) == 0
        expect(self.cancelActionCalled) == 1
        expect(self.cancelSecondaryActionCalled) == 0
    }
    
    func testAdaptionOfActionTitles() {
        imageController.addAction(ImagePickerAction(title: "Action", secondaryTitle: { "Secondary \($0)" }, handler: { _ in }))
        presentImagePickerSheetController()
        
        let indexPath = IndexPath(item: 0, section: 0)
        tester().tapImagePreviewAtIndexPath(indexPath, inCollectionViewWithAccessibilityIdentifier: imageControllerPreviewIdentifier)
        
        tester().waitForView(withAccessibilityLabel: "Secondary 1")
    }
    
}
