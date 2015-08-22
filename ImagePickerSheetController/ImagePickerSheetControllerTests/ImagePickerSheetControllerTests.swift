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
    
    // MARK: - Setup
    
    override func setUp() {
        super.setUp()
        
        imageController = ImagePickerSheetController()
    }
    
    override func tearDown() {
        super.tearDown()
        
        rootViewController.dismissViewControllerAnimated(false, completion: nil)
    }
    
    // MARK: - Presentation
    
    func testPresentation() {
        presentImagePickerSheetController()
        tester().acknowledgeSystemAlert()
        tester().waitForViewWithAccessibilityIdentifier(imageControllerViewIdentifier)
    }
    
    // MARK: - Dismissal
    
    let actionTitle = "Action"
    
    func beforeEachDismissalTest(actionTitle: String, style: ImageActionStyle) {
        imageController.addAction(ImageAction(title: actionTitle, style: style))
        presentImagePickerSheetController()
    }
    
    func testDismissalByTappingDefaultAction() {
        beforeEachDismissalTest(actionTitle, style: .Default)
        
        tester().tapViewWithAccessibilityLabel(actionTitle)
        tester().waitForAbsenceOfViewWithAccessibilityIdentifier(imageControllerViewIdentifier)
    }
    
    func testDismissalByTappingCancelAction() {
        beforeEachDismissalTest(actionTitle, style: .Cancel)
        
        tester().tapViewWithAccessibilityLabel(actionTitle)
        tester().waitForAbsenceOfViewWithAccessibilityIdentifier(imageControllerViewIdentifier)
    }
    
    func testDismissalByTappingBackground() {
        beforeEachDismissalTest(actionTitle, style: .Default)
        
        tester().tapViewWithAccessibilityIdentifier(imageControllerBackgroundViewIdentifier)
        tester().waitForAbsenceOfViewWithAccessibilityIdentifier(imageControllerViewIdentifier)
    }
    
    // MARK: - Adding Actions
    
    func testAddingTwoCancelActions() {
        imageController.addAction(ImageAction(title: "Cancel1", style: .Cancel))
        imageController.addAction(ImageAction(title: "Cancel2", style: .Cancel))
        
        expect(self.imageController.actions.filter { $0.style == .Cancel }.count).to(equal(1))
    }
    
    func testDisplayOfAddedActions() {
        let actions: [(String, ImageActionStyle)] = [("Action1", .Default),
                                                     ("Action2", .Default),
                                                     ("Cancel", .Cancel)]
        
        for (title, style) in actions {
            imageController.addAction(ImageAction(title: title, style: style))
        }
        
        presentImagePickerSheetController()
        
        for (title, _) in actions {
            self.tester().waitForViewWithAccessibilityLabel(title)
        }
    }
    
    func testAdaptionOfActionTitles() {
        presentImagePickerSheetController()
        tester().waitForViewWithAccessibilityIdentifier(imageControllerViewIdentifier)
        
        imageController.addAction(ImageAction(title: "Action", secondaryTitle: { "Secondary \($0)" }))
        
        let indexPath = NSIndexPath(forItem: 0, inSection: 0)
        tester().tapImagePreviewAtIndexPath(indexPath, inCollectionViewWithAccessibilityIdentifier: imageControllerPreviewIdentifier)
        
        tester().waitForViewWithAccessibilityLabel("Secondary 1")
    }
    
    // MARK: - Action Handling
    
    var defaultAction: ImageAction!
    var cancelAction: ImageAction!
    
    var defaultActionCalled: Int!
    var cancelActionCalled: Int!
    
    func beforeEachActionHandlingTest() {
        defaultActionCalled = 0
        cancelActionCalled = 0
        
        defaultAction = ImageAction(title: "Action", handler: { _ in
            self.defaultActionCalled = self.defaultActionCalled+1
        })
        imageController.addAction(defaultAction)
        
        cancelAction = ImageAction(title: "Cancel", style: .Cancel, handler: { _ in
            self.cancelActionCalled = self.cancelActionCalled+1
        })
        imageController.addAction(cancelAction)
        
        presentImagePickerSheetController()
    }
    
    func testDefaultActionHandling() {
        beforeEachActionHandlingTest()
        
        tester().tapViewWithAccessibilityLabel(defaultAction.title)
        
        expect(self.defaultActionCalled).to(equal(1))
        expect(self.cancelActionCalled).to(equal(0))
    }
    
    func testCancelActionHandlingWhenTappingAction() {
        beforeEachActionHandlingTest()
        
        tester().tapViewWithAccessibilityLabel(cancelAction.title)
        
        expect(self.defaultActionCalled).to(equal(0))
        expect(self.cancelActionCalled).to(equal(1))
    }
    
    func testCancelActionHandlingWhenTappingBackground() {
        beforeEachActionHandlingTest()
        
        self.tester().tapViewWithAccessibilityIdentifier(imageControllerBackgroundViewIdentifier)
        
        expect(self.defaultActionCalled).to(equal(0))
        expect(self.cancelActionCalled).to(equal(1))
    }
    
    // MARK: - Images
    
    let result: PHFetchResult = {
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        
        return PHAsset.fetchAssetsWithMediaType(.Image, options: options)
    }()
    
    func beforeEachImageTest() {
        presentImagePickerSheetController()
    }
    
    func beforeEachImageWithoutLimitTest(count: Int) {
        for i in 0 ..< count {
            let indexPath = NSIndexPath(forItem: 0, inSection: i)
            tester().tapImagePreviewAtIndexPath(indexPath, inCollectionViewWithAccessibilityIdentifier: imageControllerPreviewIdentifier)
        }
        
        expect(self.imageController.numberOfSelectedImages).to(equal(count))
        expect(self.imageController.selectedImageAssets.count).to(equal(count))
    }
    
    func testImageSelectionWithoutLimit() {
        beforeEachImageTest()
        beforeEachImageWithoutLimitTest(3)
        
        let selectedAssets = imageController.selectedImageAssets
        result.enumerateObjectsUsingBlock { obj, idx, _ in
            if let asset = obj as? PHAsset where idx < 3 {
                expect(asset.localIdentifier).to(equal(selectedAssets[idx].localIdentifier))
            }
        }
    }
    
    func testImageDeselectionWithoutLimit() {
        beforeEachImageTest()
        beforeEachImageWithoutLimitTest(3)
        
        let indexPath = NSIndexPath(forItem: 0, inSection: 0)
        tester().tapImagePreviewAtIndexPath(indexPath, inCollectionViewWithAccessibilityIdentifier: imageControllerPreviewIdentifier)
        
        expect(self.imageController.numberOfSelectedImages).to(equal(2))
        expect(self.imageController.selectedImageAssets.count).to(equal(2))
        
        let selectedAssets = imageController.selectedImageAssets
        result.enumerateObjectsUsingBlock { obj, idx, _ in
            if let asset = obj as? PHAsset where idx < 3 && idx > 0 {
                expect(asset.localIdentifier).to(equal(selectedAssets[idx-1].localIdentifier))
            }
        }
    }
    
    func testImageSelectionWithLimit() {
        beforeEachImageTest()
        
        let maxSelection = 2
        imageController.maximumSelection = maxSelection
        
        for i in 0 ..< 3 {
            let indexPath = NSIndexPath(forItem: 0, inSection: i)
            tester().tapImagePreviewAtIndexPath(indexPath, inCollectionViewWithAccessibilityIdentifier: imageControllerPreviewIdentifier)
        }
        
        expect(self.imageController.numberOfSelectedImages).to(equal(maxSelection))
        expect(self.imageController.selectedImageAssets.count).to(equal(maxSelection))
        
        let selectedAssets = imageController.selectedImageAssets
        result.enumerateObjectsUsingBlock { obj, idx, _ in
            if let asset = obj as? PHAsset where idx < 3 && idx > 0 {
                expect(asset.localIdentifier).to(equal(selectedAssets[idx-1].localIdentifier))
            }
        }
    }
    
    // MARK: - Utilities
    
    func presentImagePickerSheetController() {
        rootViewController.presentViewController(imageController, animated: false, completion: nil)
        tester().waitForViewWithAccessibilityIdentifier(imageControllerViewIdentifier)
    }
    
}
