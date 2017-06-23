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
        
        DLog.debug("")

        clearsSelectionOnViewWillAppear = false
        
        // This back button is the one that will appear on the next (build) page
//        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)

    }
    
    override func viewWillAppear(_ animated: Bool) {

        super.viewWillAppear( animated )
        
        DLog.debug("")

        navigationItem.title = "List Devices"

        builder.buildState = .unknown
//        builder.currentDevice = nil
        devices = builder.getDeviceList()
        
        tableView.reloadData()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        navigationItem.title = "List"   // Back button title for next page - buildPeripheral
        let dest = segue.destination as! buildPeripheralCVC
        if segue.identifier == "toNewPeripheral" {
            builder.buildState = .unsaved
            dest.buildDevice = nil
            DLog.debug("dest.buildDevice = nil")
        } else if segue.identifier == "toShowPeripheral" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                builder.buildState = .saved
                dest.buildDevice = devices![indexPath.row]
                DLog.debug("dest.buildDevice is existing BuildDevice instance: \(dest.buildDevice?.name ?? "oops, no name!")")
            }
        }
    }

    
    //--    ----    ----    ----
    
    // MARK: - Table datasource events
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard devices != nil else { return 0 }
        return devices!.count
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell( withIdentifier: "serviceView" )
        cell?.textLabel!.text = devices![(indexPath as NSIndexPath).row].name
        cell?.detailTextLabel!.text = devices![(indexPath as NSIndexPath).row].uuid
        return cell!
    }
    
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            builder.deleteDevice( devices![(indexPath as NSIndexPath).row] )
            devices!.remove( at: (indexPath as NSIndexPath).row )
//            devices = builder!.getDeviceList()
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    

}
