//
//  BRNImagePickerSheet.swift
//  BRNImagePickerSheet
//
//  Created by Laurin Brandner on 04/09/14.
//  Copyright (c) 2014 Laurin Brandner. All rights reserved.
//

import UIKit
import AssetsLibrary

@objc protocol BRNImagePickerSheetDelegate {
    optional func imagePickerSheet(imagePickerSheet: BRNImagePickerSheet, clickedButtonAtIndex buttonIndex: Int)
    optional func imagePickerSheetCancel(imagePickerSheet: BRNImagePickerSheet)
    
    optional func willPresentImagePickerSheet(imagePickerSheet: BRNImagePickerSheet)
    optional func didPresentImagePickerSheet(imagePickerSheet: BRNImagePickerSheet)
    
    optional func imagePickerSheet(imagePickerSheet: BRNImagePickerSheet, willDismissWithButtonIndex buttonIndex: Int)
    optional func imagePickerSheet(imagePickerSheet: BRNImagePickerSheet, didDismissWithButtonIndex buttonIndex: Int)
}

class BRNImagePickerSheet: UIView, UITableViewDataSource, UITableViewDelegate {
    
    var delegate: BRNImagePickerSheetDelegate?
    
    private let overlayView = UIView()
    private let tableView = UITableView()
    
    private var photos = [UIImage]()
    private var selectedPhotos = [UIImage]()
    private var previewsPhotos: Bool {
        return (self.photos.count > 0)
    }
    
    var cancelButtonIndex: Int {
        return self.tableView.numberOfRowsInSection(0) - 1
    }
    
    private var titles: [NSString] {
        return ["Photo Library", "Take Photo or Video", "Cancel"]
    }
    
    private class var animationDuration: Double {
        return 0.3
    }
    
    // MARK: Initialization
    
    override init() {
        super.init(frame: CGRectZero)
        
        let tapRecognizer = UITapGestureRecognizer()
        tapRecognizer.addTarget(self, action: "overlayViewWasTapped:")
        self.overlayView.addGestureRecognizer(tapRecognizer)
        self.overlayView.backgroundColor = UIColor(white: 0.0, alpha: 0.3)
        self.addSubview(self.overlayView)
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
        self.tableView.alwaysBounceVertical = false
        self.addSubview(self.tableView)
        
        let library = ALAssetsLibrary()
        library.enumerateGroupsWithTypes((1 << 4), usingBlock: { (group: ALAssetsGroup!, stop: UnsafeMutablePointer<ObjCBool>) -> Void in
            if group != nil {
                group.setAssetsFilter(ALAssetsFilter.allPhotos())
                group.enumerateAssetsUsingBlock({ (asset: ALAsset!, index: Int, stop: UnsafeMutablePointer<ObjCBool>) -> Void in
                    if asset != nil {
//                        let representation: ALAssetRepresentation = asset.defaultRepresentation()
//                        let photo = UIImage(CGImage: representation.fullResolutionImage())
//                        self.photos.append(photo)
                    }
                })
                
                self.tableView.reloadData()
            }
        }, failureBlock:nil)
    }
    
    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - UITableViewDataSource
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let numberOfTitles = self.titles.count
        if self.previewsPhotos {
            return numberOfTitles + 1
        }
        
        return numberOfTitles
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if indexPath.row == 0 && self.previewsPhotos {
            let cell = BRNImagePreviewCell(style: UITableViewCellStyle.Default , reuseIdentifier: "Cell")
            cell.photos = self.photos
            
            return cell
        }
        
        var titleIndex = indexPath.row
        if self.previewsPhotos {
            --titleIndex
        }
        
        let cell = UITableViewCell(style: UITableViewCellStyle.Default , reuseIdentifier: "Cell")
        cell.textLabel!.textAlignment = .Center
        cell.textLabel!.textColor = self.tintColor
        cell.textLabel!.text = self.titles[titleIndex]
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(tableView: UITableView, shouldHighlightRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return !(self.previewsPhotos && indexPath.row == 0)
    }
    
    func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        var dismiss = true
        if self.previewsPhotos {
            dismiss = (indexPath.row != 0)
        }
        
        if dismiss {
            self.dismissWithClickedButtonIndex(indexPath.row, animated: true)
        }
    }
    
    // MARK: - Presentation
    
    func showInView(view: UIView) {
        self.frame = view.bounds
        view.addSubview(self)
    
        let originalTableViewOffset = CGRectGetMinY(self.tableView.frame)
        self.tableView.frame.origin.y = CGRectGetHeight(self.bounds)
        self.overlayView.alpha = 0.0
        
        self.delegate?.willPresentImagePickerSheet?(self)

        UIView.animateWithDuration(BRNImagePickerSheet.animationDuration, animations: { () -> Void in
            self.tableView.frame.origin.y = originalTableViewOffset
            self.overlayView.alpha = 1.0
            }, completion: { (finished: Bool) -> Void in
                self.delegate?.didPresentImagePickerSheet?(self)
            println("finished")
        })
    }
    
    func dismissWithClickedButtonIndex(buttonIndex: Int, animated: Bool) {
        self.delegate?.imagePickerSheet?(self, willDismissWithButtonIndex: buttonIndex)
        
        let duration = (animated) ? BRNImagePickerSheet.animationDuration : 0.0
        UIView.animateWithDuration(duration, animations: { () -> Void in
            self.overlayView.alpha = 0.0
            self.tableView.frame.origin.y += CGRectGetHeight(self.tableView.frame)
            }, completion: { (finished: Bool) -> Void in
                self.delegate?.imagePickerSheet?(self, didDismissWithButtonIndex: buttonIndex)
                self.removeFromSuperview()
                println("finished")
        })
    }
    
    // MARK: - Other Methods
    
    func overlayViewWasTapped(gestureRecognizer: UITapGestureRecognizer) {
        self.dismissWithClickedButtonIndex(self.cancelButtonIndex, animated: true)
    }
    
    // MARK: - Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        var bounds = self.bounds
        
        self.overlayView.frame = bounds
        
        self.tableView.frame.size = CGSizeMake(CGRectGetWidth(bounds), self.tableView.contentSize.height)
        self.tableView.frame.origin.y = CGRectGetMaxY(bounds)-CGRectGetHeight(self.tableView.frame)
    }
    
}

@objc protocol BRNImagePreviewCellDelegate {
    
    optional func imagePreviewCell(imagePreviewCell: BRNImagePreviewCell, didSelectImageAtIndex imageIndex: Int)
    
    optional func imagePreviewCell(imagePreviewCell: BRNImagePreviewCell, didDeselectImageAtIndex imageIndex: Int)

}

class BRNImagePreviewCell : UITableViewCell, UITableViewDataSource, UITableViewDelegate {
    
    var photos = [UIImage]()
    
    private let tableView = UITableView()
    
    var delegate: BRNImagePreviewCellDelegate?
    
    // MARK: Initialization
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        self.tableView.dataSource = self
        self.tableView.delegate = self
    }

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UITableViewDataSource
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.photos.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCellStyle.Default , reuseIdentifier: "Cell")
        cell.imageView!.image = self.photos[indexPath.row]
        
        return cell
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
        self.delegate?.imagePreviewCell?(self, didSelectImageAtIndex: indexPath.row)
    }
    
    func tableView(tableView: UITableView, didDeselectRowAtIndexPath indexPath: NSIndexPath) {
        self.delegate?.imagePreviewCell?(self, didDeselectImageAtIndex: indexPath.row)
    }

    // MARK: - Layout
    
    override func layoutSubviews() {
        self.tableView.frame = self.bounds
    }

}
