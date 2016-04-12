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
	
    var services: [CBService]?
	
	var adverts: [String:String]?
	var advertServices: [String]?
	var advertName: String?
	
	
	@IBOutlet weak var connectionLabel: UILabel?
    @IBOutlet weak var connectionUUID: UILabel!
	@IBOutlet weak var activityIndicator: UIActivityIndicatorView?
	@IBOutlet weak var connectionIndicator: UIImageView?

	
//--	----	----	----	----	----	----	----
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		clearsSelectionOnViewWillAppear = false
		
		if let name = perp?.name {
			navigationItem.title = name
			connectionLabel!.text = "Connection to \(name)"
		}
        connectionUUID.text = perp?.mainUUID

        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        interrogator.managedObjectContext = appDelegate.managedObjectContext
        interrogator.delegate = self
	}

	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear( animated )
		
		activityIndicator!.stopAnimating()
		setIndicator( perp?.connectable?.boolValue )

        if let scanPerp = self.perp  {
            Log.info( "Start scan for \(scanPerp.mainUUID!)" )
            interrogator.startScan( forDevices: [CBUUID(string: scanPerp.mainUUID!)] )
        }
    }
	
	override func viewWillDisappear(animated: Bool) {
		
        interrogator.stopInterrogation()
        interrogator.stopScan()

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
        Log.trace( "connectableState: connectable: \(connectable)" )
        if ( connectable ) {
            activityIndicator!.startAnimating()
            connectionIndicator!.image = Indicator.yellow.image()
            interrogator.startInterrogation( forDevice: peripheral )
        } else {
            activityIndicator!.stopAnimating()
            connectionIndicator!.image = Indicator.red.image()
            Log.info( "Not Connectable" )
        }
    }
    
    func connectionStatus( connected: Bool, forPeripheral peripheral: CBPeripheral ) {
        Log.trace( "connectionStatus, connected: \(connected)" )
        activityIndicator!.stopAnimating()
//		interrogator.stopInterrogation() // ?? Is this needed ??
		if connected {
            connectionIndicator!.image = Indicator.green.image()
			updateConnection( peripheral )
        } else {
            connectionIndicator!.image = Indicator.yellow.image()
			disconnectConnection( peripheral )
        }
    }
    
    func servicesDiscovered( peripheral: CBPeripheral ) {
        
        Log.trace( "servicesDiscovered with \(peripheral.services?.count) services" )
        
        services = peripheral.services
        
        tableView.reloadData()
        
    }
    
//--    ----    ----    ----
	
	func updateConnection( peripheral: CBPeripheral ) {
		
		Log.trace( "updateConnection, peripheral; name: \(peripheral.name), state: \(peripheral.state.rawValue)" )

        interrogator.startServiceDiscovery( peripheral )
        
        
/*
		case Disconnected = 0
		case Connecting
		case Connected
		@available(iOS 9.0, *)
		case Disconnecting
*/
	}
	
	func disconnectConnection( peripheral: CBPeripheral ) {
		
		Log.trace( "disconnectConnection, peripheral; name: \(peripheral.name), state: \(peripheral.state.rawValue)" )
	}

    
    //  MARK: - UITableViewDelegate methods
    
    override func numberOfSectionsInTableView( tableView: UITableView ) -> Int {
        // Return the number of rows in the section.
        return 1
    }
    
    internal override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        switch section {
        case 0:
            return 22.0;
            
        case 1:
            return 22.0;
            
        case 2:
            return 22.0;
        default:
            return 0.0
        }
    }

    override func tableView( tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath ) -> CGFloat {
        return 66.0
    }
    
    
    //  MARK: - UITableViewSource methods

    override func tableView( tableView: UITableView, numberOfRowsInSection section: NSInteger ) -> NSInteger {
        // Return the number of rows in the section.
        switch section {
        case 0:
            if let srvcs = services {
                return srvcs.count
            } else {
                return 0
            }
        case 1:
            return 0
        case 2:
            return 0
        default:
            return 0
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath ) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier( "centralServiceCell", forIndexPath: indexPath ) as! ServiceCell
        
        switch indexPath.section {
        case 0:
            configureMainService( cell, atIndexPath: indexPath )
            return cell
        case 1:
            return cell
        case 2:
            return cell
        default:
            return cell
        }
    }

    func configureMainService( cell: ServiceCell, atIndexPath indexPath: NSIndexPath ) {
        let service = services![indexPath.row]
        let name = service.peripheral.name
        if ( ( name == nil ) || ( name!.characters.count == 0 ) ) {
            cell.nameField.text = name
        } else {
            let prefix = name![name!.startIndex]
            if prefix == "~" {
                cell.nameField.text = name!.substringFromIndex(name!.startIndex.successor())
            } else {
                cell.nameField.text = name
            }
        }
        cell.IDField.text = service.UUID.UUIDString
        cell.primaryIndicator.text = service.isPrimary ? "Primary" : "Secondary"
        let servicesCount = service.includedServices?.count
        if servicesCount > 0 {
            cell.servicesCount.text = "\(servicesCount) services"
        } else {
            cell.servicesCount.text = "No services"
        }
        let characteristicCount = service.characteristics?.count
        if characteristicCount > 0 {
            cell.characteristicsCount.text = "\(characteristicCount) characteristics"
        } else {
            cell.characteristicsCount.text = "No characteristics"
        }
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
    
    

}