//
//  ImageAction.swift
//  ImagePickerSheet
//
//  Created by Laurin Brandner on 24/05/15.
//  Copyright (c) 2015 Laurin Brandner. All rights reserved.
//

import Foundation

public struct ImageAction {
    
    typealias Title = Int -> String
    
    let title: Title
    let secondaryTitle: Title
    
    let handler: (ImageAction -> ())?
    
    init(title: Title, secondaryTitle: Title? = nil, handler: (ImageAction -> ())? = nil) {
        self.title = title
        self.secondaryTitle = title
        self.handler = handler
    }
    
}