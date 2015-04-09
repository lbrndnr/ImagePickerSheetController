//
//  AppDelegate.swift
//  BRNImagePickerSheet
//
//  Created by Laurin Brandner on 26/02/15.
//  Copyright (c) 2015 Laurin Brandner. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow? = {
        let window = UIWindow(frame: UIScreen.mainScreen().bounds)
        window.backgroundColor = UIColor.whiteColor()
        
        return window
    }()

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject : AnyObject]?) -> Bool {
        self.window?.rootViewController = ViewController()
        self.window?.makeKeyAndVisible()
        
        return true
    }

}

