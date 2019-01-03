//
//  PresentationTests.swift
//  ImagePickerSheetController
//
//  Created by Laurin Brandner on 06/09/15.
//  Copyright © 2015 Laurin Brandner. All rights reserved.
//

import XCTest
import KIF

class PresentationTests: ImagePickerSheetControllerTests {
    
    func testPresentation() {
        presentImagePickerSheetController(true)
        tester().acknowledgeSystemAlert()
        tester().waitForView(withAccessibilityIdentifier: imageControllerViewIdentifier)
    }
    
}
