//
//  SheetController.swift
//  ImagePickerSheetController
//
//  Created by Laurin Brandner on 27/08/15.
//  Copyright © 2015 Laurin Brandner. All rights reserved.
//

import UIKit

private let defaultInset: CGFloat = 10

class SheetController: NSObject {
    
    var actions = [ImagePickerAction]() {
        didSet {
            reloadActionItems()
        }
    }
    
    var sheetCollectionView: UICollectionView
    var previewCollectionView: PreviewCollectionView
    
    var imagePreviewHeight: CGFloat = 0
    var numberOfSelectedImages = 0
    
    var preferredSheetHeight: CGFloat {
        return allIndexPaths().map { self.sizeForSheetItemAtIndexPath($0).height }
                              .reduce(0, combine: +)
    }
    
    var preferredSheetWidth: CGFloat {
        return sheetCollectionView.bounds.width - 2 * defaultInset
    }
    
    // MARK: - Initialization
    
    init(sheetCollectionView: UICollectionView, previewCollectionView: PreviewCollectionView) {
        self.sheetCollectionView = sheetCollectionView
        self.previewCollectionView = previewCollectionView
        
        super.init()
    }
    
    // MARK: - Data Source
    // These methods are necessary so that no call cycles happen when calculating the row attributes
    
    private func numberOfSections() -> Int {
        return 2
    }
    
    private func numberOfItemsInSection(section: Int) -> Int {
        if section == 0 {
            return 1
        }
        
        return actions.count
    }
    
    private func allIndexPaths() -> [NSIndexPath] {
        let s = numberOfSections()
        return (0 ..< s).map { (self.numberOfItemsInSection($0), $0) }
                        .flatMap { numberOfRows, section in
                            (0 ..< numberOfRows).map { NSIndexPath(forRow: $0, inSection: section) }
                        }
    }
    
    private func sizeForSheetItemAtIndexPath(indexPath: NSIndexPath) -> CGSize {
        let height: CGFloat = {
            if indexPath.section == 0 {
                return imagePreviewHeight
            }
            
            let actionRowHeight: CGFloat
            
            if #available(iOS 9, *) {
                actionRowHeight = 57
            }
            else {
                actionRowHeight = 50
            }
            
            let insets = attributesForRowAtIndexPath(indexPath).backgroundInsets
            return actionRowHeight + insets.top + insets.bottom
        }()
        
        return CGSize(width: sheetCollectionView.bounds.width, height: height)
    }
    
    // MARK: - Design
    
    private func attributesForRowAtIndexPath(indexPath: NSIndexPath) -> (corners: RoundedCorner, backgroundInsets: UIEdgeInsets) {
        guard #available(iOS 9, *) else {
            return (.None, UIEdgeInsets())
        }
        
        let cornerRadius: CGFloat = 13
        let innerInset: CGFloat = 4
        var indexPaths = allIndexPaths()
        
        guard indexPaths.first != indexPath else {
            return (.Top(cornerRadius), UIEdgeInsets(top: 0, left: defaultInset, bottom: 0, right: defaultInset))
        }
        
        let cancelIndexPath = actions.indexOf { $0.style == ImagePickerActionStyle.Cancel }
                                     .map { NSIndexPath(forRow: $0, inSection: 1) }
        
        
        if let cancelIndexPath = cancelIndexPath {
            if cancelIndexPath == indexPath {
                return (.All(cornerRadius), UIEdgeInsets(top: innerInset, left: defaultInset, bottom: defaultInset, right: defaultInset))
            }
            
            indexPaths.removeLast()
            
            if indexPath == indexPaths.last {
                return (.Bottom(cornerRadius), UIEdgeInsets(top: 0, left: defaultInset, bottom: innerInset, right: defaultInset))
            }
        }
        else if indexPath == indexPaths.last {
            return (.Bottom(cornerRadius), UIEdgeInsets(top: 0, left: defaultInset, bottom: defaultInset, right: defaultInset))
        }
        
        return (.None, UIEdgeInsets(top: 0, left: defaultInset, bottom: 0, right: defaultInset))
    }
    
    private func fontForAction(action: ImagePickerAction) -> UIFont {
        guard #available(iOS 9, *), action.style == .Cancel else {
            return UIFont.systemFontOfSize(21)
        }
        
        return UIFont.boldSystemFontOfSize(21)
    }
    
    // MARK: - Actions
    
    func addAction(action: ImagePickerAction) {
        if action.style == .Cancel {
            actions = actions.filter { $0.style != .Cancel }
        }
        
        actions.append(action)
        
        if let index = actions.indexOf({ $0.style == .Cancel }) {
            let cancelAction = actions.removeAtIndex(index)
            actions.append(cancelAction)
        }
    }
    
    func reloadActionItems() {
        sheetCollectionView.reloadSections(NSIndexSet(index: 1))
    }
    
}

extension SheetController: UICollectionViewDataSource {
    
    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return numberOfSections()
    }
    
    func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return numberOfItemsInSection(section)
    }
    
    func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell: SheetCollectionViewCell
        
        if indexPath.section == 0 {
            let previewCell = collectionView.dequeueReusableCellWithReuseIdentifier(NSStringFromClass(SheetPreviewCollectionViewCell.self), forIndexPath: indexPath) as! SheetPreviewCollectionViewCell
            previewCell.collectionView = previewCollectionView
            
            cell = previewCell
        }
        else {
            let action = actions[indexPath.row]
            let actionCell = collectionView.dequeueReusableCellWithReuseIdentifier(NSStringFromClass(SheetActionCollectionViewCell.self), forIndexPath: indexPath) as! SheetActionCollectionViewCell
            actionCell.textLabel.font = fontForAction(action)
            actionCell.textLabel.text = numberOfSelectedImages > 0 ? action.secondaryTitle(numberOfSelectedImages) : action.title
            
            cell = actionCell
        }
        
        cell.separatorVisible = (indexPath.section == 1)
        
        // iOS specific design
        (cell.roundedCorners, cell.backgroundInsets) = attributesForRowAtIndexPath(indexPath)
        if #available(iOS 9, *) {
            cell.backgroundColor = UIColor(white: 0.97, alpha: 1)
            cell.separatorColor = UIColor(white: 0.84, alpha: 1)
        }
        else {
            cell.backgroundColor = .whiteColor()
            cell.separatorColor = UIColor(white: 0.784, alpha: 1)
        }
        
        return cell
    }
    
}

extension SheetController: UICollectionViewDelegate {
    
    func collectionView(collectionView: UICollectionView, shouldHighlightItemAtIndexPath indexPath: NSIndexPath) -> Bool {
        return indexPath.section != 0
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        collectionView.deselectItemAtIndexPath(indexPath, animated: true)
        
        //presentingViewController?.dismissViewControllerAnimated(true, completion: nil)
        
        actions[indexPath.row].handle(numberOfSelectedImages)
    }
    
}

extension SheetController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(collectionView: UICollectionView, layout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return sizeForSheetItemAtIndexPath(indexPath)
    }
    
}
