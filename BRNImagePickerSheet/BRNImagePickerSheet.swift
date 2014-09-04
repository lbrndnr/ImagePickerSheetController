//
//  BRNImagePickerSheet.swift
//  BRNImagePickerSheet
//
//  Created by Laurin Brandner on 04/09/14.
//  Copyright (c) 2014 Laurin Brandner. All rights reserved.
//

import UIKit

class BRNImagePickerSheet: UIView, UITableViewDelegate, UITableViewDataSource {
    
    var tableView: UITableView?
    
    // MARK: Initialization
    
    override init() {
        self.tableView = UITableView()
        
        super.init()
        
        self.tableView!.delegate = self
        self.tableView!.dataSource = self
    }
    
    // MARK: - UITableViewDataSource

    required init(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func numberOfSectionsInTableView(tableView: UITableView!) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView!, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(tableView: UITableView!, cellForRowAtIndexPath indexPath: NSIndexPath!) -> UITableViewCell! {
        return UITableViewCell()
    }
    
    // MARK: - UITableViewDelegate
    
    func tableView(tableView: UITableView!, didSelectRowAtIndexPath indexPath: NSIndexPath!) {
        
    }
}

