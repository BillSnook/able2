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
    
    var services: [Service]?
    
    var uuid: String?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        clearsSelectionOnViewWillAppear = false
//        navigationItem.title = "Create Peripheral"
        
        // This back button is the one that will appear on the next (build) page
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)

        builder = Builder.sharedBuilder
//        print( "getList[0] with name: \(services![0].name)" )

    }
    
    override func viewWillAppear(animated: Bool) {

        super.viewWillAppear( animated )
        
        services = builder?.getList()
        tableView.reloadData()
    }
    
    
//    override func viewWillDisappear(animated: Bool) {
//
//        super.viewWillDisappear( animated )
//        
//    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "toBuild" {
            let dest = segue.destinationViewController as! buildPeripheral
            dest.builder = builder
            dest.service = nil
        } else if segue.identifier == "toShow" {
            let dest = segue.destinationViewController as! buildPeripheral
            dest.builder = builder
            if let indexPath = self.tableView.indexPathForSelectedRow {
                dest.service = services![indexPath.row]
            }
        }

        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }

    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        guard services != nil else { return 0 }
        return services!.count
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier( "serviceView" )
        print( "cellForRowAtIndexPath name: \(services![indexPath.row].name)" )
        cell?.textLabel!.text = services![indexPath.row].name
        cell?.detailTextLabel!.text = services![indexPath.row].uuid
        return cell!
    }
    

}