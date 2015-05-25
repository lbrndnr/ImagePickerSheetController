//
//  ImageAction.swift
//  ImagePickerSheet
//
//  Created by Laurin Brandner on 24/05/15.
//  Copyright (c) 2015 Laurin Brandner. All rights reserved.
//

import Foundation

public typealias Title = Int -> String

public class ImageAction {
    
    public typealias Handler = (ImageAction) -> ()
    public typealias SecondaryHandler = (ImageAction, Int) -> ()
    
    let title: Title
    let secondaryTitle: Title
    
    let handler: Handler?
    let secondaryHandler: SecondaryHandler?
    
    // TODO: Less verbose by mapping the secondary handler to the primary one if secondary title not specified
    public convenience init(title: String, secondaryTitle: String? = nil, handler: Handler? = nil, secondaryHandler: SecondaryHandler? = nil) {
        self.init(title: { _ in title }, secondaryTitle: secondaryTitle.map { string in { _ in string }} ?? { _ in title }, handler: handler)
    }
    
    public convenience init(title: String, secondaryTitle: Title, handler: Handler? = nil, secondaryHandler: SecondaryHandler? = nil) {
        self.init(title: { _ in title }, secondaryTitle: secondaryTitle, handler: handler, secondaryHandler: secondaryHandler)
    }
    
    public convenience init(title: Title, secondaryTitle: String? = nil, handler: Handler? = nil, secondaryHandler: SecondaryHandler? = nil) {
        self.init(title: title, secondaryTitle: secondaryTitle.map { string in { _ in string }} ?? title, handler: handler, secondaryHandler: secondaryHandler)
    }
    
    public init(title: Title, secondaryTitle: Title, handler: Handler? = nil, secondaryHandler: SecondaryHandler? = nil) {
        self.title = title
        self.secondaryTitle = secondaryTitle
        self.handler = handler
        self.secondaryHandler = secondaryHandler
    }
    
    func handle(numberOfPhotos: Int = 0) {
        if numberOfPhotos > 0 {
            secondaryHandler?(self, numberOfPhotos)
        }
        else {
            handler?(self)
        }
    }
    
}

func ?? (left: Title?, right: Title) -> Title {
    if let left = left {
        return left
    }
    
    return right
}