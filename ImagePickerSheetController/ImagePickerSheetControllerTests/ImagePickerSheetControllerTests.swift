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
        presentImagePickerSheetController(true)
        tester().acknowledgeSystemAlert()
        tester().waitForViewWithAccessibilityIdentifier(imageControllerViewIdentifier)
    }
    
    // MARK: - Dismissal
    
    let actionTitle = "Action"
    
    func beforeEachDismissalTest(actionTitle: String, style: ImagePickerActionStyle) {
        imageController.addAction(ImagePickerAction(title: actionTitle, style: style))
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
        imageController.addAction(ImagePickerAction(title: "Cancel1", style: .Cancel))
        imageController.addAction(ImagePickerAction(title: "Cancel2", style: .Cancel))
        
        expect(self.imageController.actions.filter { $0.style == .Cancel }.count) == 1
    }
    
    func testDisplayOfAddedActions() {
        let actions: [(String, ImagePickerActionStyle)] = [("Action1", .Default),
                                                     ("Action2", .Default),
                                                     ("Cancel", .Cancel)]
        
        for (title, style) in actions {
            imageController.addAction(ImagePickerAction(title: title, style: style))
        }
        
        presentImagePickerSheetController()
        
        for (title, _) in actions {
            tester().waitForViewWithAccessibilityLabel(title)
        }
    }
    
    func testActionOrdering() {
        let cancelActionTitle = "Cancel"
        let defaultActionTitle = "Action"
        
        imageController.addAction(ImagePickerAction(title: cancelActionTitle, style: .Cancel))
        imageController.addAction(ImagePickerAction(title: defaultActionTitle))
        
        expect(self.imageController.actions.map { $0.title }) == [defaultActionTitle, cancelActionTitle]
    }
    
    // MARK: - Action Handling
    
    var defaultAction: ImagePickerAction!
    var cancelAction: ImagePickerAction!
    
    var defaultActionCalled: Int!
    var cancelActionCalled: Int!
    
    func beforeEachActionHandlingTest() {
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
        
        presentImagePickerSheetController()
    }
    
    func testDefaultActionHandling() {
        beforeEachActionHandlingTest()
        
        tester().tapViewWithAccessibilityLabel(defaultAction.title)
        
        expect(self.defaultActionCalled) == 1
        expect(self.cancelActionCalled) == 0
    }
    
    func testCancelActionHandlingWhenTappingAction() {
        beforeEachActionHandlingTest()
        
        tester().tapViewWithAccessibilityLabel(cancelAction.title)
        
        expect(self.defaultActionCalled) == 0
        expect(self.cancelActionCalled) == 1
    }
    
    func testCancelActionHandlingWhenTappingBackground() {
        beforeEachActionHandlingTest()
        
        tester().tapViewWithAccessibilityIdentifier(imageControllerBackgroundViewIdentifier)
        
        expect(self.defaultActionCalled) == 0
        expect(self.cancelActionCalled) == 1
    }
    
    func testAdaptionOfActionTitles() {
        presentImagePickerSheetController()
        
        imageController.addAction(ImagePickerAction(title: "Action", secondaryTitle: { "Secondary \($0)" }))
        
        tester().waitForViewWithAccessibilityLabel("Action")
        
        let indexPath = NSIndexPath(forItem: 0, inSection: 0)
        tester().tapImagePreviewAtIndexPath(indexPath, inCollectionViewWithAccessibilityIdentifier: imageControllerPreviewIdentifier)
        
        tester().waitForViewWithAccessibilityLabel("Secondary 1")
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
        
        expect(self.imageController.selectedImageAssets.count) == count
    }
    
    func testImageSelectionWithoutLimit() {
        beforeEachImageTest()
        beforeEachImageWithoutLimitTest(3)
        
        let selectedAssets = imageController.selectedImageAssets
        result.enumerateObjectsUsingBlock { obj, idx, _ in
            if let asset = obj as? PHAsset where idx < 3 {
                expect(asset.localIdentifier) == selectedAssets[idx].localIdentifier
            }
        }
    }
    
    func testImageDeselectionWithoutLimit() {
        beforeEachImageTest()
        beforeEachImageWithoutLimitTest(3)
        
        let indexPath = NSIndexPath(forItem: 0, inSection: 0)
        tester().tapImagePreviewAtIndexPath(indexPath, inCollectionViewWithAccessibilityIdentifier: imageControllerPreviewIdentifier)
        
        expect(self.imageController.selectedImageAssets.count) == 2
        
        let selectedAssets = imageController.selectedImageAssets
        result.enumerateObjectsUsingBlock { obj, idx, _ in
            if let asset = obj as? PHAsset where idx < 3 && idx > 0 {
                expect(asset.localIdentifier) == selectedAssets[idx-1].localIdentifier
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
        
        expect(self.imageController.selectedImageAssets.count) == maxSelection
        
        let selectedAssets = imageController.selectedImageAssets
        result.enumerateObjectsUsingBlock { obj, idx, _ in
            if let asset = obj as? PHAsset where idx < 3 && idx > 0 {
                expect(asset.localIdentifier) == selectedAssets[idx-1].localIdentifier
            }
        }
    }
    
    // MARK: - Utilities
    
    func presentImagePickerSheetController(animated: Bool = false) {
        rootViewController.presentViewController(imageController, animated: animated, completion: nil)
        tester().waitForViewWithAccessibilityIdentifier(imageControllerViewIdentifier)
    }
    
}
