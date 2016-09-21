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
    
    let result: PHFetchResult = { () -> PHFetchResult<PHAsset> in 
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        
        return PHAsset.fetchAssets(with: .image, options: options)
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
            let indexPath = IndexPath(item: 0, section: i)
            tester().tapImagePreviewAtIndexPath(indexPath, inCollectionViewWithAccessibilityIdentifier: imageControllerPreviewIdentifier)
        }
        
        expect(self.imageController.selectedAssets.count) == count
    }
    
    func testImageSelection() {
        let selectedAssets = imageController.selectedAssets
        result.enumerateObjects { obj, idx, _ in
            if let asset = obj as? PHAsset , idx < 3 {
                expect(asset.localIdentifier) == selectedAssets[idx].localIdentifier
            }
        }
    }
    
    func testImageDeselection() {
        let indexPath = IndexPath(item: 0, section: 0)
        tester().tapImagePreviewAtIndexPath(indexPath, inCollectionViewWithAccessibilityIdentifier: imageControllerPreviewIdentifier)
        
        expect(self.imageController.selectedAssets.count) == count - 1
        
        let selectedAssets = imageController.selectedAssets
        result.enumerateObjects { obj, idx, _ in
            if let asset = obj as? PHAsset , idx < self.count && idx > 0 {
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
            let indexPath = IndexPath(item: 0, section: i)
            tester().tapImagePreviewAtIndexPath(indexPath, inCollectionViewWithAccessibilityIdentifier: imageControllerPreviewIdentifier)
        }
        
        expect(self.imageController.selectedAssets.count) == maxSelection
        
        let selectedAssets = imageController.selectedAssets
        result.enumerateObjects { obj, idx, _ in
            if let asset = obj as? PHAsset , idx < maxSelection && idx > 0 {
                expect(asset.localIdentifier) == selectedAssets[idx-1].localIdentifier
            }
        }
    }
    
}
