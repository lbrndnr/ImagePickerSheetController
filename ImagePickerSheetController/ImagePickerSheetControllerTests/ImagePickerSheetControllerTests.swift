//
//  ImagePickerSheetControllerTests.swift
//  ImagePickerSheetControllerTests
//
//  Created by Laurin Brandner on 26/05/15.
//  Copyright (c) 2015 Laurin Brandner. All rights reserved.
//

import UIKit
import XCTest
import KIF
import Nimble
import Photos
import ImagePickerSheetController

let imageControllerViewIdentifier = "ImagePickerSheet"
let imageControllerBackgroundViewIdentifier = "ImagePickerSheetBackground"
let imageControllerPreviewIdentifier = "ImagePickerSheetPreview"

class ImagePickerSheetControllerTests: XCTestCase {
    
    let rootViewController = UIApplication.shared.windows.first!.rootViewController!
    var imageController: ImagePickerSheetController!
    
    let defaultActionTitle = "Action"
    let cancelActionTitle = "Cancel"
    
    // MARK: - Setup
    
    override func setUp() {
        super.setUp()
        
        imageController = ImagePickerSheetController(mediaType: .imageAndVideo)
    }
    
    override func tearDown() {
        super.tearDown()
        
        rootViewController.dismiss(animated: false, completion: nil)
    }
    
    // MARK: - Utilities
    
    func presentImagePickerSheetController(_ animated: Bool = false) {
        rootViewController.present(imageController, animated: animated, completion: nil)
        tester().waitForView(withAccessibilityIdentifier: imageControllerViewIdentifier)
    }
    
}
