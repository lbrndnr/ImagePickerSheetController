//
//  AddingActionTests.swift
//  ImagePickerSheetController
//
//  Created by Laurin Brandner on 06/09/15.
//  Copyright © 2015 Laurin Brandner. All rights reserved.
//

import XCTest
import KIF
import Nimble
import ImagePickerSheetController

class AddingActionTests: ImagePickerSheetControllerTests {

    func testAddingTwoCancelActions() {
        imageController.addAction(ImagePickerAction(title: "Cancel1", style: .Cancel, handler: { _ in }))
        imageController.addAction(ImagePickerAction(title: "Cancel2", style: .Cancel, handler: { _ in }))
        
        expect(self.imageController.actions.filter { $0.style == .Cancel }.count) == 1
    }
    
    func testDisplayOfAddedActions() {
        let actions: [(String, ImagePickerActionStyle)] = [("Action1", .Default),
                                                           ("Action2", .Default),
                                                           ("Cancel", .Cancel)]
        
        for (title, style) in actions {
            imageController.addAction(ImagePickerAction(title: title, style: style, handler: { _ in }))
        }
        
        presentImagePickerSheetController()
        
        for (title, _) in actions {
            tester().waitForViewWithAccessibilityLabel(title)
        }
    }
    
    func testActionOrdering() {
        imageController.addAction(ImagePickerAction(title: cancelActionTitle, style: .Cancel, handler: { _ in }))
        imageController.addAction(ImagePickerAction(title: defaultActionTitle, handler: { _ in }))
        
        expect(self.imageController.actions.map { $0.title }) == [defaultActionTitle, cancelActionTitle]
    }
    
    func testAddingActionAfterPresentation() {
        presentImagePickerSheetController()
        
        imageController.addAction(ImagePickerAction(title: defaultActionTitle, handler: { _ in }))
        tester().waitForViewWithAccessibilityLabel(defaultActionTitle)
    }
    
}
