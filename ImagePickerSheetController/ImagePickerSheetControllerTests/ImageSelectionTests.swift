//
//  ImageSelectionTests.swift
//  ImagePickerSheetController
//
//  Created by Laurin Brandner on 06/09/15.
//  Copyright © 2015 Laurin Brandner. All rights reserved.
//

import XCTest
import KIF
import Nimble
import Photos
import ImagePickerSheetController

class ImageSelectionTests: ImagePickerSheetControllerTests {
    
    let result: PHFetchResult = {
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        
        return PHAsset.fetchAssetsWithMediaType(.Image, options: options)
    }()
    
    let count = 3
    
    override func setUp() {
        super.setUp()
        
        presentImagePickerSheetController()
    }
    
}

class ImageSelectionWithoutLimitTests: ImageSelectionTests {
    
    override func setUp() {
        super.setUp()
        
        for i in 0 ..< count {
            let indexPath = NSIndexPath(forItem: 0, inSection: i)
            tester().tapImagePreviewAtIndexPath(indexPath, inCollectionViewWithAccessibilityIdentifier: imageControllerPreviewIdentifier)
        }
        
        expect(self.imageController.selectedImageAssets.count) == count
    }
    
    func testImageSelection() {
        let selectedAssets = imageController.selectedImageAssets
        result.enumerateObjectsUsingBlock { obj, idx, _ in
            if let asset = obj as? PHAsset where idx < 3 {
                expect(asset.localIdentifier) == selectedAssets[idx].localIdentifier
            }
        }
    }
    
    func testImageDeselection() {
        let indexPath = NSIndexPath(forItem: 0, inSection: 0)
        tester().tapImagePreviewAtIndexPath(indexPath, inCollectionViewWithAccessibilityIdentifier: imageControllerPreviewIdentifier)
        
        expect(self.imageController.selectedImageAssets.count) == count - 1
        
        let selectedAssets = imageController.selectedImageAssets
        result.enumerateObjectsUsingBlock { obj, idx, _ in
            if let asset = obj as? PHAsset where idx < self.count && idx > 0 {
                expect(asset.localIdentifier) == selectedAssets[idx-1].localIdentifier
            }
        }
    }
    
}

class ImageSelectionWithLimitTests: ImageSelectionTests {
    
    func testImageSelection() {
        let maxSelection = 2
        imageController.maximumSelection = maxSelection
        
        for i in 0 ..< count {
            let indexPath = NSIndexPath(forItem: 0, inSection: i)
            tester().tapImagePreviewAtIndexPath(indexPath, inCollectionViewWithAccessibilityIdentifier: imageControllerPreviewIdentifier)
        }
        
        expect(self.imageController.selectedImageAssets.count) == maxSelection
        
        let selectedAssets = imageController.selectedImageAssets
        result.enumerateObjectsUsingBlock { obj, idx, _ in
            if let asset = obj as? PHAsset where idx < maxSelection && idx > 0 {
                expect(asset.localIdentifier) == selectedAssets[idx-1].localIdentifier
            }
        }
    }
    
}
