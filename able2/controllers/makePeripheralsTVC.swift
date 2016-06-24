//
//  makePeripheralsTVC.swift
//  able2
//
//  Created by William Snook on 3/28/16.
//  Copyright © 2016 William Snook. All rights reserved.
//

import Foundation
import UIKit


class makePeripheralsTVC : UITableViewController, SubstitutableDetailViewProtocol {

    var navigationPaneBarButtonItem: UIBarButtonItem?

    var builder: Builder?
    var services: [BuildService]?


    override func viewDidLoad() {
        super.viewDidLoad()
        
        clearsSelectionOnViewWillAppear = false
//        navigationItem.title = "Create Peripheral"
        
        // This back button is the one that will appear on the next (build) page
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)

        builder = Builder.sharedBuilder

    }
    
    override func viewWillAppear(animated: Bool) {

        super.viewWillAppear( animated )
        
        services = builder?.getList()
        tableView.reloadData()
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "toBuild" {
            let dest = segue.destinationViewController as! buildPeripheral
            builder!.indexPath = nil
            dest.builder = builder
        } else if segue.identifier == "toShow" {
            let dest = segue.destinationViewController as! buildPeripheral
            if let indexPath = self.tableView.indexPathForSelectedRow {
                builder!.indexPath = indexPath
                dest.builder = builder
//                dest.buildService = services![indexPath.row]
            }
        }
    }

    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard services != nil else { return 0 }
        return services!.count
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier( "serviceView" )
        cell?.textLabel!.text = services![indexPath.row].name
        cell?.detailTextLabel!.text = services![indexPath.row].uuid
        return cell!
    }
    
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            builder?.delete( services![indexPath.row] )
            services = builder?.getList()
            tableView.reloadData()
        }
    }
    

}