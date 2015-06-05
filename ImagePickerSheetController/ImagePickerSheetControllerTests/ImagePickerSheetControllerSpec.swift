//
//  ImagePickerSheetControllerSpec.swift
//  ImagePickerSheetControllerSpec
//
//  Created by Laurin Brandner on 26/05/15.
//  Copyright (c) 2015 Laurin Brandner. All rights reserved.
//

import UIKit
import XCTest
import KIF
import Quick
import Nimble
import ImagePickerSheetController

class ImagePickerSheetControllerSpec: QuickSpec {
    
    override func spec() {
        let rootViewController = (UIApplication.sharedApplication().windows.first as! UIWindow).rootViewController!
        var imageController: ImagePickerSheetController!
        
        beforeEach {
            imageController = ImagePickerSheetController()
        }
        
        describe("presentation") {
            
            it("should present") {
                rootViewController.presentViewController(imageController, animated: true, completion: nil)
                let sheet = self.tester().waitForViewWithAccessibilityIdentifier("controller")
                
                expect(sheet).notTo(beNil())
            }
            
        }
        
        describe("actions") {
            it("should not add two cancel actions") {
                imageController.addAction(ImageAction(title: "Cancel1", style: .Cancel))
                expect {
                    imageController.addAction(ImageAction(title: "Cancel2", style: .Cancel))
                }.to(raiseException())
            }
        }
    }
    
}
