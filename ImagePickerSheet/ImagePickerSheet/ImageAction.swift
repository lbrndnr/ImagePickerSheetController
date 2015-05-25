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
    let title: Title
    let secondaryTitle: Title
    
    let handler: (ImageAction -> ())?
    let secondaryHandler: (ImageAction -> ())?
    
    public convenience init(title: String, secondaryTitle: String? = nil, handler: (ImageAction -> ())? = nil) {
        self.init(title: { _ in title }, secondaryTitle: secondaryTitle.map { string in { _ in string }} ?? { _ in title }, handler: handler)
    }
    
    public convenience init(title: String, secondaryTitle: Title, handler: (ImageAction -> ())? = nil) {
        self.init(title: { _ in title }, secondaryTitle: secondaryTitle, handler: handler)
    }
    
    public convenience init(title: Title, secondaryTitle: String? = nil, handler: (ImageAction -> ())? = nil) {
        self.init(title: title, secondaryTitle: secondaryTitle.map { string in { _ in string }} ?? title, handler: handler)
    }
    
    public init(title: Title, secondaryTitle: Title, handler: (ImageAction -> ())? = nil) {
        self.title = title
        self.secondaryTitle = secondaryTitle
        self.handler = handler
        self.secondaryHandler = nil
    }
    
    func callHandler() {
        handler?(self)
    }
    
    func callSecondaryHandler() {
        secondaryHandler?(self)
    }
    
}

func ?? (left: Title?, right: Title) -> Title {
    if let left = left {
        return left
    }
    
    return right
}