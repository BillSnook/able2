//
//  listServicesTVC.swift
//  able2
//
//  Created by William Snook on 4/1/16.
//  Copyright © 2016 William Snook. All rights reserved.
//

import Foundation
import UIKit
import CoreBluetooth
import CoreData


class ListServicesTVC: UITableViewController, peripheralConnectionProtocol {
    
    var perp: Peripheral?				// This gets passed in as identifier to represent selected device
    
    var centralManager: CBCentralManager?
	var interrogator: Interrogator = Interrogator.sharedInterrogator
	
	var connected = false
	
    var services: [Peripheral]?
	
	var adverts: [String:String]?
	var advertServices: [String]?
	var advertName: String?
	
	
	@IBOutlet var connectionLabel: UILabel?
	@IBOutlet var activityIndicator: UIActivityIndicatorView?
	@IBOutlet var connectionIndicator: UIImageView?

	
//--	----	----	----	----	----	----	----
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		clearsSelectionOnViewWillAppear = false
		
		if let name = perp?.name {
			navigationItem.title = name
			connectionLabel!.text = "Connection to \(name)"
		}

        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        interrogator.managedObjectContext = appDelegate.managedObjectContext
        interrogator.delegate = self
	}

	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear( animated )
		
		activityIndicator!.stopAnimating()
		setIndicator( perp?.connectable?.boolValue )

        if let scanPerp = self.perp  {
            print( "Start scan for \(scanPerp.mainUUID!)" )
            interrogator.startScan( forDevices: [CBUUID(string: scanPerp.mainUUID!)] )
        }
    }
	
	
	override func viewWillDisappear(animated: Bool) {
		
		interrogator.stopInterrogation()

		super.viewWillDisappear( animated )
		
	}
	
	func setIndicator( isConnectable: Bool? ) {
		if let connectable = isConnectable {
			if connectable {
				if connected {
					connectionIndicator!.image = UIImage( named: "button_round_green_small.jpg" )
				} else {
					connectionIndicator!.image = UIImage( named: "button_round_yellow_small.jpg" )
				}
			} else {
				connectionIndicator!.image = UIImage( named: "button_round_red_small.jpg" )
			}
		} else {
			connectionIndicator!.image = UIImage( named: "button_round_red_small.jpg" )
		}
	}

    func connectableState( connectable: Bool, forPeripheral peripheral: CBPeripheral ) {
        print( "connectableState: connectable: \(connectable)" )
        if ( connectable ) {
            activityIndicator!.startAnimating()
            connectionIndicator!.image = UIImage( named: "button_round_yellow_small.jpg" )
            interrogator.startInterrogation( forDevice: peripheral )
        } else {
            activityIndicator!.stopAnimating()
            connectionIndicator!.image = UIImage( named: "button_round_red_small.jpg" )
            print( "Not Connectable" )
        }
    }
    
    func connectionStatus( connected: Bool ) {
        print( "connectionStatus, connected: \(connected)" )
        activityIndicator!.stopAnimating()
        if connected {
            connectionIndicator!.image = UIImage( named: "button_round_green_small.jpg" )
        } else {
            connectionIndicator!.image = UIImage( named: "button_round_red_small.jpg" )
        }
    }

    func disconnectionStatus( connected: Bool ) {
        print( "disconnectionStatus, connected: \(connected)" )
        activityIndicator!.stopAnimating()
        if connected {
            connectionIndicator!.image = UIImage( named: "button_round_yellow_small.jpg" )
        } else {
            connectionIndicator!.image = UIImage( named: "button_round_red_small.jpg" )
        }
    }
    

}