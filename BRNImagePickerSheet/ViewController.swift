//
//  ViewController.swift
//  BRNImagePickerSheet
//
//  Created by Laurin Brandner on 04/09/14.
//  Copyright (c) 2014 Laurin Brandner. All rights reserved.
//

import UIKit

class ViewController: UIViewController, BRNImagePickerSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // MARK: View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: "presentImagePickerSheet:")
        self.view.addGestureRecognizer(tapRecognizer)
    }
    
    // MARK: Other Methods
    
    func presentImagePickerSheet(gestureRecognizer: UITapGestureRecognizer) {
        var sheet = BRNImagePickerSheet()
        sheet.numberOfButtons = 3
        sheet.delegate = self
        sheet.showInView(self.view)
    }
    
    // MARK: BRNImagePickerSheetDelegate
    
    func imagePickerSheet(imagePickerSheet: BRNImagePickerSheet, titleForButtonAtIndex buttonIndex: Int) -> String {
        let photosSelected = (imagePickerSheet.selectedPhotos.count > 0)
        
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
                println(imagePickerSheet.selectedPhotos.count)
                return NSString.localizedStringWithFormat(NSLocalizedString("BRNImagePickerSheet.button1.Send %lu Photo", comment: "The secondary title of the image picker sheet to send the photos"), imagePickerSheet.selectedPhotos.count)
            }
            else {
                return NSLocalizedString("Photo Library", comment: "Photo Library")
            }
        }
    }
    
    func imagePickerSheet(imagePickerSheet: BRNImagePickerSheet, willDismissWithButtonIndex buttonIndex: Int) {
        if buttonIndex != imagePickerSheet.cancelButtonIndex {
            if imagePickerSheet.selectedPhotos.count > 0 {
                println(imagePickerSheet.selectedPhotos)
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
