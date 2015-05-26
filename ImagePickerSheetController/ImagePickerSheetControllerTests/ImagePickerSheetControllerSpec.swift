//
//  ImagePickerSheetControllerTests.swift
//  ImagePickerSheetControllerTests
//
//  Created by Laurin Brandner on 26/05/15.
//  Copyright (c) 2015 Laurin Brandner. All rights reserved.
//

import UIKit
import XCTest
import Quick
import Nimble
import ImagePickerSheetController

class ImagePickerSheetControllerSpec: QuickSpec {
    
    override func spec() {
        var controller: ImagePickerSheetController!
        
        beforeEach {
            controller = ImagePickerSheetController()
        }
        
        it("should not add two cancel actions") {
            controller.addAction(ImageAction(title: "Cancel1", style: .Cancel))
            expect {
                controller.addAction(ImageAction(title: "Cancel2", style: .Cancel))
            }.to(raiseException())
        }
    }
    
}
