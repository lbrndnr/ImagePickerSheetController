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

class ViewController: UIViewController {
    
    // MARK: - View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let button = UIButton(type: .system)
        button.setTitle("Tap Me!", for: [])
        button.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(button)
        button.heightAnchor.constraint(equalToConstant: 40).isActive = true
        button.widthAnchor.constraint(equalToConstant: 150).isActive = true
        button.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        button.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
        button.addTarget(self, action: #selector(presentImagePickerSheet(gestureRecognizer:)), for: .touchUpInside)
    }
    
    // MARK: - Other Methods
    
    @objc func presentImagePickerSheet(gestureRecognizer: UITapGestureRecognizer) {
        let presentImagePickerController: (UIImagePickerController.SourceType) -> () = { source in
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
        controller.maximumSelection = 1
        controller.delegate = self
        
        controller.addAction(ImagePickerAction(title: NSLocalizedString("Take Photo Or Video", comment: "Action Title"), secondaryTitle: NSLocalizedString("Add comment", comment: "Action Title"), handler: { _ in
            presentImagePickerController(.camera)
        }, secondaryHandler: { _, numberOfPhotos in
            print("Comment \(numberOfPhotos) photos")
        }))
        controller.addAction(ImagePickerAction(title: NSLocalizedString("Photo Library", comment: "Action Title"), secondaryTitle: { NSString.localizedStringWithFormat(NSLocalizedString("ImagePickerSheet.button1.Send %lu Photo", comment: "Action Title") as NSString, $0) as String}, handler: { _ in
            presentImagePickerController(.photoLibrary)
        }, secondaryHandler: { _, numberOfPhotos in
            print("Send \(controller.selectedAssets)")
        }))
        controller.addAction(ImagePickerAction(cancelTitle: NSLocalizedString("Cancel", comment: "Action Title")))
        
        if UIDevice.current.userInterfaceIdiom == .pad {
            controller.modalPresentationStyle = .popover
            controller.popoverPresentationController?.sourceView = view
            controller.popoverPresentationController?.sourceRect = CGRect(origin: view.center, size: CGSize())
        }
        
        present(controller, animated: true, completion: nil)
    }
    
}

// MARK: - UIImagePickerControllerDelegate
extension ViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - ImagePickerSheetControllerDelegate
extension ViewController: ImagePickerSheetControllerDelegate {
    
    func controllerWillEnlargePreview(_ controller: ImagePickerSheetController) {
        print("Will enlarge the preview")
    }
    
    func controllerDidEnlargePreview(_ controller: ImagePickerSheetController) {
        print("Did enlarge the preview")
    }
    
    func controller(_ controller: ImagePickerSheetController, willSelectAsset asset: PHAsset) {
        print("Will select an asset")
    }
    
    func controller(_ controller: ImagePickerSheetController, didSelectAsset asset: PHAsset) {
        print("Did select an asset")
    }
    
    func controller(_ controller: ImagePickerSheetController, willDeselectAsset asset: PHAsset) {
        print("Will deselect an asset")
    }
    
    func controller(_ controller: ImagePickerSheetController, didDeselectAsset asset: PHAsset) {
        print("Did deselect an asset")
    }
    
}
