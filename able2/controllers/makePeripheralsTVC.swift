//
//  makePeripheralsTVC.swift
//  able2
//
//  Created by William Snook on 3/28/16.
//  Copyright © 2016 William Snook. All rights reserved.
//

import Foundation
import UIKit


class makePeripheralsTVC : UITableViewController {

    let builder = Builder.sharedBuilder
    
    var devices: [BuildDevice]?

    
//--    ----    ----    ----
    
    // MARK: - Lifecycle events
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Log.debug("")

        clearsSelectionOnViewWillAppear = false
        
        // This back button is the one that will appear on the next (build) page
//        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)

    }
    
    override func viewWillAppear(animated: Bool) {

        super.viewWillAppear( animated )
        
        Log.debug("")

        navigationItem.title = "List Devices"

        builder.buildState = .Unknown
        builder.currentDevice = nil
        devices = builder.getDeviceList()
        
        tableView.reloadData()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        navigationItem.title = "List"   // Back button title for next page - buildPeripheral
        let dest = segue.destinationViewController as! buildPeripheralCVC
        if segue.identifier == "toNewPeripheral" {
            builder.buildState = .Unsaved
            dest.buildDevice = nil
            Log.debug("dest.buildDevice = nil")
        } else if segue.identifier == "toShowPeripheral" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                builder.buildState = .Saved
                dest.buildDevice = devices![indexPath.row]
                Log.debug("dest.buildDevice is existing BuildDevice instance: \(dest.buildDevice?.name)")
            }
        }
    }

    
    //--    ----    ----    ----
    
    // MARK: - Table datasource events
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard devices != nil else { return 0 }
        return devices!.count
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier( "serviceView" )
        cell?.textLabel!.text = devices![indexPath.row].name
        cell?.detailTextLabel!.text = devices![indexPath.row].uuid
        return cell!
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            builder.deleteDevice( devices![indexPath.row] )
            devices!.removeAtIndex( indexPath.row )
//            devices = builder!.getDeviceList()
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Automatic)
        }
    }
    

}