//
//  ImageAction.swift
//  ImagePickerSheet
//
//  Created by Laurin Brandner on 24/05/15.
//  Copyright (c) 2015 Laurin Brandner. All rights reserved.
//

import Foundation

public enum ImageActionStyle {
    case Default
    case Cancel
}

public typealias Title = Int -> String

public class ImageAction {
    
    public typealias Handler = (ImageAction) -> ()
    public typealias SecondaryHandler = (ImageAction, Int) -> ()
    
    /// The title of the action's button.
    public let title: String
    
    /// The title of the action's button when more than one image is selected.
    public let secondaryTitle: Title
    
    /// The style of the action. This is used to call a cancel handler when dismissing the controller by tapping the background.
    public let style: ImageActionStyle
    
    let handler: Handler?
    let secondaryHandler: SecondaryHandler?
    
    /// Initializes a new ImageAction. The secondary title and handler are used when at least 1 image has been selected.
    /// Secondary title defaults to title if not specified.
    /// Secondary Handler defaults to handler if both, the secondary handler and secondary title are not specified.
    public convenience init(title: String, secondaryTitle: String? = nil, style: ImageActionStyle = .Default, handler: Handler? = nil, secondaryHandler: SecondaryHandler? = nil) {
        self.init(title: title, secondaryTitle: secondaryTitle.map { string in { _ in string }}, style: style, handler: handler, secondaryHandler: secondaryHandler)
    }
    
    /// Initializes a new ImageAction. The secondary title and handler are used when at least 1 image has been selected.
    /// Secondary title defaults to title if not specified. Use the closure to format a title according to the selection.
    /// Secondary Handler defaults to handler if both, the secondary handler and secondary title are not specified.
    public init(title: String, secondaryTitle: Title?, style: ImageActionStyle = .Default, handler: Handler? = nil, var secondaryHandler: SecondaryHandler? = nil) {
        if let handler = handler where secondaryTitle == nil && secondaryHandler == nil {
            secondaryHandler = { action, _ in
                handler(action)
            }
        }
        
        self.title = title
        self.secondaryTitle = secondaryTitle ?? { _ in title }
        self.style = style
        self.handler = handler
        self.secondaryHandler = secondaryHandler
    }
    
    func handle(numberOfImages: Int = 0) {
        if numberOfImages > 0 {
            secondaryHandler?(self, numberOfImages)
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
