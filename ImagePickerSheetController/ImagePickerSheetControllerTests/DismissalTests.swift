//
//  DismissalTests.swift
//  ImagePickerSheetController
//
//  Created by Laurin Brandner on 06/09/15.
//  Copyright © 2015 Laurin Brandner. All rights reserved.
//

import XCTest
import KIF
import ImagePickerSheetController

class DismissalTests: ImagePickerSheetControllerTests {
    
    override func setUp() {
        super.setUp()
        
        imageController.addAction(ImagePickerAction(title: defaultActionTitle, style: .default, handler: { _ in }))
        imageController.addAction(ImagePickerAction(title: cancelActionTitle, style: .cancel, handler: { _ in }))
        
        presentImagePickerSheetController()
    }
    
    func testDismissalByTappingDefaultAction() {
        tester().tapViewWithAccessibilityLabel(defaultActionTitle)
        tester().waitForAbsenceOfViewWithAccessibilityIdentifier(imageControllerViewIdentifier)
    }
    
    func testDismissalByTappingCancelAction() {
        tester().tapViewWithAccessibilityLabel(cancelActionTitle)
        tester().waitForAbsenceOfViewWithAccessibilityIdentifier(imageControllerViewIdentifier)
    }
    
    func testDismissalByTappingBackground() {
        tester().tapViewWithAccessibilityIdentifier(imageControllerBackgroundViewIdentifier)
        tester().waitForAbsenceOfViewWithAccessibilityIdentifier(imageControllerViewIdentifier)
    }
    
}
