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
        
        let imageControllerViewIdentifier = "ImagePickerSheet"
        let imageControllerBackgroundViewIdentifier = "ImagePickerSheetBackground"
        let imageControllerPreviewIdentifier = "ImagePickerSheetPreview"
        
        beforeEach {
            imageController = ImagePickerSheetController()
        }
        
        afterEach {
            rootViewController.dismissViewControllerAnimated(false, completion: nil)
        }
        
        describe("presentation") {
            it("should present") {
                rootViewController.presentViewController(imageController, animated: true, completion: nil)
                self.tester().waitForViewWithAccessibilityIdentifier(imageControllerViewIdentifier)
            }
        }
        
        describe("dismissal") {
            let actionTitle = "Action"
            
            beforeEach {
                imageController.addAction(ImageAction(title: actionTitle))
                rootViewController.presentViewController(imageController, animated: false, completion: nil)
            }
            
            it("should dismiss when tapping action") {
                self.tester().tapViewWithAccessibilityLabel(actionTitle)
                self.tester().waitForAbsenceOfViewWithAccessibilityIdentifier(imageControllerViewIdentifier)
            }
            
            it("should dismiss when tapping background") {
                self.tester().tapViewWithAccessibilityIdentifier(imageControllerBackgroundViewIdentifier)
                self.tester().waitForAbsenceOfViewWithAccessibilityIdentifier(imageControllerViewIdentifier)
            }
        }
        
        describe("actions") {
            it("should not add two cancel actions") {
                imageController.addAction(ImageAction(title: "Cancel1", style: .Cancel))
                expect {
                    imageController.addAction(ImageAction(title: "Cancel2", style: .Cancel))
                }.to(raiseException())
            }
            
            it("should add actions") {
                let actions: [(String, ImageActionStyle)] = [("Action1", .Default),
                                                             ("Action2", .Default),
                                                             ("Cancel", .Cancel)]
                
                for (title, style) in actions {
                    imageController.addAction(ImageAction(title: title, style: style))
                }
                
                rootViewController.presentViewController(imageController, animated: false, completion: nil)
                
                for (title, _) in actions {
                    self.tester().waitForViewWithAccessibilityLabel(title)
                }
            }
        }
        
        describe("handlers") {
            var defaultAction: ImageAction!
            var cancelAction: ImageAction!
            
            var defaultActionCalled: Int!
            var cancelActionCalled: Int!
            
            beforeEach {
                defaultActionCalled = 0
                cancelActionCalled = 0
                
                defaultAction = ImageAction(title: "Action", handler: { _ in
                    defaultActionCalled = defaultActionCalled+1
                })
                imageController.addAction(defaultAction)
                
                cancelAction = ImageAction(title: "Cancel", style: .Cancel, handler: { _ in
                    cancelActionCalled = cancelActionCalled+1
                })
                imageController.addAction(cancelAction)
                
                rootViewController.presentViewController(imageController, animated: false, completion: nil)
            }
            
            it("should call default handler once") {
                self.tester().tapViewWithAccessibilityLabel(defaultAction.title)
                
                expect(defaultActionCalled).to(equal(1))
                expect(cancelActionCalled).to(equal(0))
            }
            
            it("should call cancel handler once when tapping action") {
                self.tester().tapViewWithAccessibilityLabel(cancelAction.title)
                
                expect(defaultActionCalled).to(equal(0))
                expect(cancelActionCalled).to(equal(1))
            }
            
            it("should call cancel handler once when tapping background") {
                self.tester().tapViewWithAccessibilityIdentifier(imageControllerBackgroundViewIdentifier)
                
                expect(defaultActionCalled).to(equal(0))
                expect(cancelActionCalled).to(equal(1))
            }
        }
        
        describe("images") {
            
            it("should display images") {
                
            }
            
            it("should select images") {
                let selection = 3
                
                for i in 0..<selection {
                    let indexPath = NSIndexPath(forItem: 0, inSection: i)
                    self.tester().tapItemAtIndexPath(indexPath, inCollectionViewWithAccessibilityIdentifier: imageControllerPreviewIdentifier)
                }
                
                expect(imageController.numberOfSelectedImages).to(equal(selection))
            }
            
        }
    }
    
}
