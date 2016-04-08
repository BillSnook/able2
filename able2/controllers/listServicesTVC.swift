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


enum Indicator: String {
    case green = "button_round_green_small.jpg"
    case yellow = "button_round_yellow_small.jpg"
    case red = "button_round_red_small.jpg"
    
    func image() -> UIImage {
        return UIImage( named: self.rawValue )!
    }
}


class ListServicesTVC: UITableViewController, peripheralConnectionProtocol {
    
    var perp: Peripheral?	// This gets passed in as identifier to represent the selected device
    
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
					connectionIndicator!.image = Indicator.green.image()
				} else {
					connectionIndicator!.image = Indicator.yellow.image()
				}
			} else {
				connectionIndicator!.image = Indicator.red.image()
			}
		} else {
			connectionIndicator!.image = Indicator.red.image()
		}
	}

    //  MARK: - peripheralConnectionProtocol delegate methods
    
    func connectableState( connectable: Bool, forPeripheral peripheral: CBPeripheral ) {
        print( "connectableState: connectable: \(connectable)" )
        if ( connectable ) {
            activityIndicator!.startAnimating()
            connectionIndicator!.image = Indicator.yellow.image()
            interrogator.startInterrogation( forDevice: peripheral )
        } else {
            activityIndicator!.stopAnimating()
            connectionIndicator!.image = Indicator.red.image()
            print( "Not Connectable" )
        }
    }
    
    func connectionStatus( connected: Bool ) {
        print( "connectionStatus, connected: \(connected)" )
        activityIndicator!.stopAnimating()
        if connected {
            connectionIndicator!.image = Indicator.green.image()
        } else {
            connectionIndicator!.image = Indicator.red.image()
        }
    }

    func disconnectionStatus( connected: Bool ) {
        print( "disconnectionStatus, connected: \(connected)" )
        activityIndicator!.stopAnimating()
        if connected {
            connectionIndicator!.image = Indicator.yellow.image()
        } else {
            connectionIndicator!.image = Indicator.red.image()
        }
    }
    

    //  MARK: - UITableViewDelegate methods
    
    internal override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
//        switch section {
//        case 0:
//            return 22.0;
//            
//        case 1:
//            return 22.0;
//            
//        case 2:
//            return 22.0;
//            
//        }
        return 0.0;
    }

    
/*
    func testit() {
        
        enum Section : Int {
            case service = 0
            case subservice = 1
            case characteristics = 2
            
//            static let «allValues» = [Section.Dough, Section.Ingredients]
            
            func titles() -> String? {
                switch self {
                    case .service: return "Services"
                    case .subservice: return "SubServices"
                    case .characteristics: return "Characteristics"
                }
            }
            
            func caseForRow(row: Int) -> String? {
                switch self {
                case .service: return "Services"
                case .subservice: return "SubServices"
                case .characteristics: return "Characteristics"
                }
            }
            
            func headerHeight() -> CGFloat {
                switch self {
                case .service: return 22.0
                case .subservice: return 22.0
                case .characteristics: return 22.0
                }
                return CGFloat(22.0)
            }
            
//            func headerView(tableView: UITableView) -> UIView? {
//                let header = tableView.dequeueReusableHeaderFooterViewWithIdentifier(kTableHeaderIdentifier) as! TableHeaderView
//                if let sectionName = self.title() {
//                    header.lblTitle.text = sectionName
//                }
//                return header
//            }
        }
        
    }
*/
    
    
    //  MARK: - UITableViewSource methods
    
    
    

}