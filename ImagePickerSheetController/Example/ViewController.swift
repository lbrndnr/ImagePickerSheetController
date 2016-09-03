//
//  ViewController.swift
//  Example
//
//  Created by Laurin Brandner on 26/05/15.
//  Copyright (c) 2015 Laurin Brandner. All rights reserved.
//

import UIKit
import Photos
import ImagePickerSheetController

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // MARK: View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tapRecognizer = UITapGestureRecognizer(target: self, action: #selector(ViewController.presentImagePickerSheet(_:)))
        view.addGestureRecognizer(tapRecognizer)
    }
    
    // MARK: Other Methods
    
    func presentImagePickerSheet(_ gestureRecognizer: UITapGestureRecognizer) {
        let presentImagePickerController: (UIImagePickerControllerSourceType) -> () = { source in
            let controller = UIImagePickerController()
            controller.delegate = self
            var sourceType = source
            if (!UIImagePickerController.isSourceTypeAvailable(sourceType)) {
                sourceType = .photoLibrary
                print("Fallback to camera roll as a source since the simulator doesn't support taking pictures")
            }
            controller.sourceType = sourceType
            
            self.present(controller, animated: true, completion: nil)
        }
        
        let controller = ImagePickerSheetController(mediaType: .imageAndVideo)
        controller.addAction(ImagePickerAction(title: NSLocalizedString("Take Photo Or Video", comment: "Action Title"), secondaryTitle: NSLocalizedString("Add comment", comment: "Action Title"), handler: { _ in
            presentImagePickerController(.camera)
        }, secondaryHandler: { _, numberOfPhotos in
            print("Comment \(numberOfPhotos) photos")
        }))
        controller.addAction(ImagePickerAction(title: NSLocalizedString("Photo Library", comment: "Action Title"), secondaryTitle: { NSString.localizedStringWithFormat(NSLocalizedString("ImagePickerSheet.button1.Send %lu Photo", comment: "Action Title") as NSString, $0) as String}, handler: { _ in
            presentImagePickerController(.photoLibrary)
        }, secondaryHandler: { _, numberOfPhotos in
            print("Send \(controller.selectedImageAssets)")
        }))
        controller.addAction(ImagePickerAction(cancelTitle: NSLocalizedString("Cancel", comment: "Action Title")))
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            controller.modalPresentationStyle = .popover
            controller.popoverPresentationController?.sourceView = view
            controller.popoverPresentationController?.sourceRect = CGRect(origin: view.center, size: CGSize())
        }
        
        present(controller, animated: true, completion: nil)
    }
    
    // MARK: UIImagePickerControllerDelegate
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
}
