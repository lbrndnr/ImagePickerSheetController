//
//  KIFExtensions.swift
//  ImagePickerSheetController
//
//  Created by Laurin Brandner on 05/06/15.
//  Copyright (c) 2015 Laurin Brandner. All rights reserved.
//

import Foundation
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
