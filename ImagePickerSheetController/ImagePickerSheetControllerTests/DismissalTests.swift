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
        tester().tapView(withAccessibilityLabel: defaultActionTitle)
        tester().waitForAbsenceOfView(withAccessibilityIdentifier: imageControllerViewIdentifier)
    }
    
    func testDismissalByTappingCancelAction() {
        tester().tapView(withAccessibilityLabel: cancelActionTitle)
        tester().waitForAbsenceOfView(withAccessibilityIdentifier: imageControllerViewIdentifier)
    }
    
    func testDismissalByTappingBackground() {
        tester().tapView(withAccessibilityIdentifier: imageControllerBackgroundViewIdentifier)
        tester().waitForAbsenceOfView(withAccessibilityIdentifier: imageControllerViewIdentifier)
    }
    
}
