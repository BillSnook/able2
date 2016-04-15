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
    var connectedPerp: CBPeripheral?
    
    var selectedService = -1
	
    var services: [CBService]?
	
	var adverts: [String:String]?
	var advertServices: [String]?
	var advertName: String?
	
	
	@IBOutlet weak var connectionLabel: UILabel?
    @IBOutlet weak var connectionUUID: UILabel!
	@IBOutlet weak var activityIndicator: UIActivityIndicatorView?
	@IBOutlet weak var connectionIndicator: UIImageView?
    @IBOutlet weak var connectButton: UIBarButtonItem!

	
//--	----	----	----	----	----	----	----
	
	
	override func viewDidLoad() {
		super.viewDidLoad()
		
		clearsSelectionOnViewWillAppear = true
		
		if let name = perp?.name {
            let betterName = cleanName( name )
			navigationItem.title = betterName
			connectionLabel!.text = "Connection to \(betterName)"
        } else {
            navigationItem.title = "Missing Name"
            connectionLabel!.text = "Connection to unnamed device"

        }
        connectionUUID.text = perp?.mainUUID

        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        interrogator.managedObjectContext = appDelegate.managedObjectContext
        interrogator.delegate = self

}

	override func viewWillAppear(animated: Bool) {
		super.viewWillAppear( animated )
		
//        selectedService = -1
		activityIndicator!.stopAnimating()
        connected = false
		setIndicator( false )

        if let scanPerp = self.perp  {
            if interrogator.connected {
                Log.info( "Already connected to \(scanPerp.mainUUID!)" )
            } else {
                Log.info( "Start scan for \(scanPerp.mainUUID!)" )
                activityIndicator!.startAnimating()
                interrogator.startScan( forDevices: [CBUUID(string: scanPerp.mainUUID!)] )
            }
        }
        
    }
	
	override func viewWillDisappear(animated: Bool) {
		
		super.viewWillDisappear( animated )
	}
    
    deinit {
        
        interrogator.stopInterrogation()
        interrogator.stopScan()
        
    }
	
    
	func setIndicator( isConnectable: Bool? ) {
		if let connectable = isConnectable {
			if connectable {
				if connected {
					connectionIndicator!.image = Indicator.green.image()
                    connectButton.enabled = false
				} else {
					connectionIndicator!.image = Indicator.yellow.image()
//                    Log.error( "Enabling connectButton" )
                    connectButton.enabled = true
				}
			} else {
				connectionIndicator!.image = Indicator.red.image()
                connectButton.enabled = false
			}
		} else {
			connectionIndicator!.image = Indicator.red.image()
            connectButton.enabled = false
		}
	}

    @IBAction func doConnect(sender: UIBarButtonItem) {
        Log.trace( "doConnect from bar button" )
        connectButton.enabled = false

        if let connectingPerp = connectedPerp {
            activityIndicator!.startAnimating()
            interrogator.startInterrogation( forDevice: connectingPerp )
        }
    }
    
    
    //  MARK: - peripheralConnectionProtocol delegate methods
    
    func foundPeripheral( peripheral: CBPeripheral, isConnectable connectable: Bool ) {
        Log.trace( "foundPeripheral: connectable: \(connectable), peripheral: \(peripheral.identifier.UUIDString)" )
        if ( connectable ) {
            activityIndicator!.startAnimating()
            self.connectedPerp = peripheral
            interrogator.startInterrogation( forDevice: peripheral )
        } else {
            activityIndicator!.stopAnimating()
            Log.info( "Not Connectable" )
        }
//        setIndicator( connectable )
    }
    
    func connectionStatus( connected: Bool, forPeripheral peripheral: CBPeripheral ) {
        Log.trace( "connectionStatus, connected: \(connected)" )
        activityIndicator!.stopAnimating()
//		interrogator.stopInterrogation() // ?? Is this needed ??
        self.connected = connected
        setIndicator( connected )
		if connected {
			updateConnection( peripheral )
        } else {
			disconnectConnection( peripheral )
        }
    }
    
    func servicesDiscovered( peripheral: CBPeripheral ) {
        
//        Log.trace( "servicesDiscovered with \(peripheral.services?.count) services" )
        
        services = peripheral.services
        
        tableView.reloadData()
        
    }
    
    func includedServicesDiscovered( peripheral: CBPeripheral, forService service: CBService ) {

//        Log.trace( "includedServicesDiscovered for \(service.UUID.UUIDString)" )
        
        services = peripheral.services
//        for index in 0..<services!.count {
//            Log.info( "includedServicesDiscovered, services UUID \(index): \(services![index].UUID.UUIDString) - \(services![index])" )
//        }
        
        tableView.reloadData()
        
    }
 
    func characteristicsDiscovered( peripheral: CBPeripheral, forService service: CBService ) {

//        Log.trace( "characteristicsDiscovered for \(service.UUID.UUIDString)" )
        
        services = peripheral.services
        
        tableView.reloadData()
        
    }
 
    
//--    ----    ----    ----
	
	func updateConnection( peripheral: CBPeripheral ) {
		
		Log.trace( "updateConnection, peripheral; name: \(peripheral.name), state: \(peripheral.state.rawValue)" )

        interrogator.startServiceDiscovery( peripheral )
        
	}
	
	func disconnectConnection( peripheral: CBPeripheral ) {
		
		Log.trace( "disconnectConnection, peripheral; name: \(peripheral.name), state: \(peripheral.state.rawValue)" )

        connected = false
        selectedService = -1
        setIndicator( true )
        
        services = nil
        
        tableView.reloadData()
	}

    
    // MARK: - Segues
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        guard selectedService >= 0 else { Log.info( "selectedService invalid" ); return }
        if segue.identifier == "toCharacteristics" {
            Log.info( "Segue to Characteristics" )
//            interrogator.stopScan()
            if let indexPath = self.tableView.indexPathForSelectedRow {
                Log.info( "selectedService: \(selectedService), indexPath.row: \(indexPath.row)" )
                let controller = segue.destinationViewController as! ShowCharacteristics
                controller.serviceIndex = selectedService
                controller.characteristicsIndex = indexPath.row
                controller.peripheral = connectedPerp
            }
        }
    }
    

    //  MARK: - UITableViewDelegate methods
    
    override func numberOfSectionsInTableView( tableView: UITableView ) -> Int {
        // Return the number of sections
        guard services != nil && selectedService < services!.count else {
            return 0
        }
        guard selectedService >= 0 else {
            return 1
        }
        if services![selectedService].includedServices != nil && services![selectedService].includedServices!.count > 0 {
            return 3
        } else {
            return 2
        }
    }
    
    internal override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 30.0;
    }

    override func tableView( tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath ) -> CGFloat {
        return 66.0
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        
        if indexPath.section == 0 {
            if connected {
                selectedService = indexPath.row
                tableView.reloadData()
            }
        }
    }

    
    //  MARK: - UITableViewSource methods

    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    
        switch section {
        case 0:
            return "Services"
        case 1:
            return "Characteristics"
        case 2:
            return "Included Services"
        default:
            return ""
        }

    }

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
            if selectedService >= 0 {
                let service = services![selectedService]
                if let characteristics = service.characteristics {
                    return characteristics.count
                }
                return 0
            } else {
                return 0
            }
        case 2:
            if selectedService >= 0 {
                let service = services![selectedService]
                if let included = service.includedServices {
                    return included.count
                }
                return 0
            } else {
                return 0
            }
        default:
            return 0
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath ) -> UITableViewCell {
        
        switch indexPath.section {
        case 0:
            return configureMainService( indexPath )
        case 1:
            return configureCharacteristics( indexPath )
        case 2:
            return configureMainService( indexPath )
        default:
            return configureMainService( indexPath )
        }
    }

    func configureMainService( indexPath: NSIndexPath ) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier( "centralServiceCell", forIndexPath: indexPath ) as! ServiceCell
        var service = services![indexPath.row]
        if indexPath.section != 0 {
            if let included = service.includedServices {
                if indexPath.row < included.count {
                    service = included[indexPath.row]
                }
            }
        }
    
        cell.nameField.text = cleanName( service.peripheral.name )
        cell.IDField.text = bluetoothUUID( service.UUID.UUIDString )
        cell.primaryIndicator.text = service.isPrimary ? "Primary" : "Secondary"
        let servicesCount = service.includedServices?.count
        if servicesCount > 0 {
            if servicesCount > 1 {
                cell.servicesCount.text = "\(servicesCount!) included services"
            } else {
                cell.servicesCount.text = "1 included service"
            }
        } else {
            cell.servicesCount.text = "No included services"
        }
        let characteristicCount = service.characteristics?.count
        if characteristicCount > 0 {
            if characteristicCount > 1 {
                cell.characteristicsCount.text = "\(characteristicCount!) characteristics"
            } else {
                cell.characteristicsCount.text = "1 characteristic"
            }
        } else {
            cell.characteristicsCount.text = "No characteristics"
        }
        return cell
    }
    
    func configureCharacteristics( indexPath: NSIndexPath ) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier( "centralDisplayCharacteristic", forIndexPath: indexPath ) as! CharacteristicCell
        let service = services![selectedService]
        if let characteristics = service.characteristics {
            Log.info( "indexPath.row: \(indexPath.row), characteristics.count = \(characteristics.count)" )
            cell.nameField.text = bluetoothUUID( characteristics[indexPath.row].UUID.UUIDString )
            let properties = characteristics[indexPath.row].properties
            Log.info( "properties: \(properties)" )
            let rawProperties = properties.rawValue
            var propString = ""
            if ( CBCharacteristicProperties.Broadcast.rawValue & rawProperties ) != 0 {
                propString += "Broadcast "
            }
            if ( CBCharacteristicProperties.Read.rawValue & rawProperties ) != 0 {
                propString += "Read "
            }
            if ( CBCharacteristicProperties.WriteWithoutResponse.rawValue & rawProperties ) != 0 {
                propString += "WriteWithoutResponse "
            }
            if ( CBCharacteristicProperties.Write.rawValue & rawProperties ) != 0 {
                propString += "Write "
            }
            if ( CBCharacteristicProperties.Notify.rawValue & rawProperties ) != 0 {
                propString += "Notify "
            }
            if ( CBCharacteristicProperties.Indicate.rawValue & rawProperties ) != 0 {
                propString += "Indicate "
            }
            if ( CBCharacteristicProperties.AuthenticatedSignedWrites.rawValue & rawProperties ) != 0 {
                propString += "AuthenticatedSignedWrites "
            }
            if ( CBCharacteristicProperties.ExtendedProperties.rawValue & rawProperties ) != 0 {
                propString += "ExtendedProperties "
            }
            cell.propertiesField.text = propString
        }
        
        return cell
    }
    
//    func checkProperty( bit: CBCharacteristicProperties, rawProperties: UInt ) {
//        if ( bit.rawValue & rawProperties ) == bit.rawValue {
//            propString += string + " "
//        } else {
//            
//        }}
//        
//    }
    
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