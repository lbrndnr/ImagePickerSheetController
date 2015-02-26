//
//  ViewController.swift
//  BRNImagePickerSheet
//
//  Created by Laurin Brandner on 04/09/14.
//  Copyright (c) 2014 Laurin Brandner. All rights reserved.
//

import UIKit
import Photos
import BRNImagePickerSheet

class ViewController: UIViewController, BRNImagePickerSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // MARK: View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: "presentImagePickerSheet:")
        self.view.addGestureRecognizer(tapRecognizer)
    }
    
    // MARK: Other Methods
    
    func presentImagePickerSheet(gestureRecognizer: UITapGestureRecognizer) {
        let authorization = PHPhotoLibrary.authorizationStatus()
        
        if authorization == .NotDetermined {
            PHPhotoLibrary.requestAuthorization({ (status) -> Void in
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.presentImagePickerSheet(gestureRecognizer)
                })
            })
            
            return
        }
        
        if authorization == .Authorized {
            var sheet = BRNImagePickerSheet()
            sheet.numberOfButtons = 3
            sheet.delegate = self
            sheet.showInView(self.view)
        }
        else {
            let alertView = UIAlertView(title: NSLocalizedString("An error occurred", comment: "An error occurred"), message: NSLocalizedString("BRNImagePickerSheet needs access to the camera roll", comment: "BRNImagePickerSheet needs access to the camera roll"), delegate: nil, cancelButtonTitle: NSLocalizedString("OK", comment: "OK"))
            alertView.show()
        }
    }
    
    // MARK: BRNImagePickerSheetDelegate
    
    func imagePickerSheet(imagePickerSheet: BRNImagePickerSheet, titleForButtonAtIndex buttonIndex: Int) -> String {
        let photosSelected = (imagePickerSheet.numberOfSelectedPhotos > 0)
        
        if (buttonIndex == 0) {
            if photosSelected {
                return NSLocalizedString("Add comment", comment: "Add comment")
            }
            else {
                return NSLocalizedString("Take Photo Or Video", comment: "Take Photo Or Video")
            }
        }
        else {
            if photosSelected {
                return NSString.localizedStringWithFormat(NSLocalizedString("BRNImagePickerSheet.button1.Send %lu Photo", comment: "The secondary title of the image picker sheet to send the photos"), imagePickerSheet.numberOfSelectedPhotos)
            }
            else {
                return NSLocalizedString("Photo Library", comment: "Photo Library")
            }
        }
    }
    
    func imagePickerSheet(imagePickerSheet: BRNImagePickerSheet, willDismissWithButtonIndex buttonIndex: Int) {
        if buttonIndex != imagePickerSheet.cancelButtonIndex {
            if imagePickerSheet.numberOfSelectedPhotos > 0 {
                imagePickerSheet.getSelectedImagesWithCompletion({ (images) -> Void in
                    println(images)
                })
            }
            else {
                let controller = UIImagePickerController()
                controller.delegate = self
                var sourceType: UIImagePickerControllerSourceType = (buttonIndex == 2) ? .PhotoLibrary : .Camera
                if (!UIImagePickerController.isSourceTypeAvailable(sourceType)) {
                    sourceType = .PhotoLibrary
                    println("Fallback to camera roll as a source since the simulator doesn't support taking pictures")
                }
                controller.sourceType = sourceType
                
                self.presentViewController(controller, animated: true, completion: nil)
            }
        }
    }
    
    // MARK: UIImagePickerControllerDelegate
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        self.dismissViewControllerAnimated(true, completion: nil)
    }
    
}
