//
//  AppDelegate.swift
//  Example
//
//  Created by Laurin Brandner on 26/05/15.
//  Copyright (c) 2015 Laurin Brandner. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow? = {
        let window = UIWindow(frame: UIScreen.main.bounds)

        #if swift(>=5.1)
        if #available(iOS 13.0, *) {
          window.backgroundColor = .systemBackground
        } else {
          window.backgroundColor = .white
        }
        #else
        window.backgroundColor = .white
        #endif
        
        return window
    }()
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        window?.rootViewController = ViewController()
        window?.makeKeyAndVisible()
        
        return true
    }
    
}
