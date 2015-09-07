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
    
    let rootViewController = UIApplication.sharedApplication().windows.first!.rootViewController!
    var imageController: ImagePickerSheetController!
    
    let defaultActionTitle = "Action"
    let cancelActionTitle = "Cancel"
    
    // MARK: - Setup
    
    override func setUp() {
        super.setUp()
        
        imageController = ImagePickerSheetController(mediaType: .ImageAndVideo)
    }
    
    override func tearDown() {
        super.tearDown()
        
        rootViewController.dismissViewControllerAnimated(false, completion: nil)
    }
    
    // MARK: - Utilities
    
    func presentImagePickerSheetController(animated: Bool = false) {
        rootViewController.presentViewController(imageController, animated: animated, completion: nil)
        tester().waitForViewWithAccessibilityIdentifier(imageControllerViewIdentifier)
    }
    
}
