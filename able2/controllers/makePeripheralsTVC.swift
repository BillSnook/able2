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
        
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear( animated )
        
    }
    
    
    override func viewWillDisappear(animated: Bool) {

        super.viewWillDisappear( animated )
        
    }
    

}