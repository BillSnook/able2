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

    override func viewDidLoad() {
        super.viewDidLoad()
        
        clearsSelectionOnViewWillAppear = false
//        navigationItem.title = "Create Peripheral"
        
        // This back button is the one that will appear on the next (build) page
        navigationItem.backBarButtonItem = UIBarButtonItem(title: "", style: .Plain, target: nil, action: nil)
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear( animated )
        
    }
    
    
    override func viewWillDisappear(animated: Bool) {

        super.viewWillDisappear( animated )
        
    }
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "toBuild" {
            
        }
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }

}