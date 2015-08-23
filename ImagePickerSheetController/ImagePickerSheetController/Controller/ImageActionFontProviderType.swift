//
//  ImageActionFontProviderType.swift
//  ImageActionFontProviderType
//
//  Created by Laurin Brandner on 23/08/15.
//  Copyright © 2015 Laurin Brandner. All rights reserved.
//

import UIKit

protocol ImageActionFontProviderType {
    
    func fontForAction(action: ImageAction) -> UIFont
    
}

extension ImageActionFontProviderType {
    
    func fontForAction(action: ImageAction) -> UIFont {
        guard #available(iOS 9, *) else {
            return UIFont.systemFontOfSize(21)
        }
        
        guard action.style == .Cancel else {
            return UIFont.systemFontOfSize(21)
        }
        
        return UIFont.boldSystemFontOfSize(21)
    }
    
}
