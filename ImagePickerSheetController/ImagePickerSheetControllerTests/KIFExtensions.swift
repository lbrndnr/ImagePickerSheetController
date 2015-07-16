//
//  KIFExtensions.swift
//  ImagePickerSheetController
//
//  Created by Laurin Brandner on 05/06/15.
//  Copyright (c) 2015 Laurin Brandner. All rights reserved.
//

import UIKit
import KIF
import Quick
import Nimble

extension XCTestCase {
    
    func tester(_ file : String = __FILE__, _ line : Int = __LINE__) -> KIFUITestActor {
        return KIFUITestActor(inFile: file, atLine: line, delegate: self)
    }
    
    func system(_ file : String = __FILE__, _ line : Int = __LINE__) -> KIFSystemTestActor {
        return KIFSystemTestActor(inFile: file, atLine: line, delegate: self)
    }
    
}

extension KIFTestActor {
    
    func tester(_ file : String = __FILE__, _ line : Int = __LINE__) -> KIFUITestActor {
        return KIFUITestActor(inFile: file, atLine: line, delegate: self)
    }
    
    func system(_ file : String = __FILE__, _ line : Int = __LINE__) -> KIFSystemTestActor {
        return KIFSystemTestActor(inFile: file, atLine: line, delegate: self)
    }
    
}

extension KIFUITestActor {
    
    // Needed because UICollectionView fails to select an item due to a reason I don't quite grasp
    func tapImagePreviewAtIndexPath(indexPath: NSIndexPath, inCollectionViewWithAccessibilityIdentifier collectionViewIdentifier: String) {
        let collectionView = waitForViewWithAccessibilityIdentifier(collectionViewIdentifier) as! UICollectionView
        let cellAttributes = collectionView.layoutAttributesForItemAtIndexPath(indexPath)
        let contentOffset = CGPoint(x: cellAttributes!.frame.minX-collectionView.contentInset.left, y: 0)
        
        collectionView.setContentOffset(contentOffset, animated: false)
        
        let newCellAttributes = collectionView.layoutAttributesForItemAtIndexPath(indexPath)
        let cellCenter = collectionView.convertPoint(newCellAttributes!.center, toView: nil)
        
        // Tap it manually here, no UICollectionView selection
        tapScreenAtPoint(cellCenter)
        
        // Wait so that a possible preview zooming animation can finish
        waitForAnimationsToFinish()
    }
    
}

extension QuickSpec: KIFTestActorDelegate {
    
    public override func failWithException(exception: NSException!, stopTest stop: Bool) {
        if stop {
            fail(exception.description)
        }
    }
    
    public override func failWithExceptions(exceptions: [AnyObject]!, stopTest stop: Bool) {
        if let exceptions = exceptions as? [NSException] {
            for exception in exceptions {
                failWithException(exception, stopTest: stop)
            }
        }
    }
    
}
