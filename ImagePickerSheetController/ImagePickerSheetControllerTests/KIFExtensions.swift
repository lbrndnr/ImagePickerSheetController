//
//  KIFExtensions.swift
//  ImagePickerSheetController
//
//  Created by Laurin Brandner on 05/06/15.
//  Copyright (c) 2015 Laurin Brandner. All rights reserved.
//

import UIKit
import KIF

extension XCTestCase {
    
    func tester(_ file : String = #file, _ line : Int = #line) -> KIFUITestActor {
        return KIFUITestActor(inFile: file, atLine: line, delegate: self)
    }
    
    func system(_ file : String = #file, _ line : Int = #line) -> KIFSystemTestActor {
        return KIFSystemTestActor(inFile: file, atLine: line, delegate: self)
    }
    
}

extension KIFTestActor {
    
    func tester(_ file : String = #file, _ line : Int = #line) -> KIFUITestActor {
        return KIFUITestActor(inFile: file, atLine: line, delegate: self)
    }
    
    func system(_ file : String = #file, _ line : Int = #line) -> KIFSystemTestActor {
        return KIFSystemTestActor(inFile: file, atLine: line, delegate: self)
    }
    
}

extension KIFUITestActor {
    
    // Needed because UICollectionView fails to select an item due to a reason I don't quite grasp
    func tapImagePreviewAtIndexPath(_ indexPath: IndexPath, inCollectionViewWithAccessibilityIdentifier collectionViewIdentifier: String) {
        let collectionView = waitForView(withAccessibilityIdentifier: collectionViewIdentifier) as! UICollectionView
        
        let cellAttributes = collectionView.layoutAttributesForItem(at: indexPath)
        let contentOffset = CGPoint(x: cellAttributes!.frame.minX-collectionView.contentInset.left, y: 0)
        
        collectionView.setContentOffset(contentOffset, animated: false)
        
        let newCellAttributes = collectionView.layoutAttributesForItem(at: indexPath)
        let cellCenter = collectionView.convert(newCellAttributes!.center, to: nil)
        
        // Tap it manually here, no UICollectionView selection
        tapScreen(at: cellCenter)
        
        // Wait so that a possible preview zooming animation can finish
        waitForAnimationsToFinish()
    }
    
}
