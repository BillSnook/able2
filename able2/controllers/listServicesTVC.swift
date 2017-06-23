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
fileprivate func < <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l < r
  case (nil, _?):
    return true
  default:
    return false
  }
}

fileprivate func > <T : Comparable>(lhs: T?, rhs: T?) -> Bool {
  switch (lhs, rhs) {
  case let (l?, r?):
    return l > r
  default:
    return rhs < lhs
  }
}



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

        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        interrogator.managedObjectContext = appDelegate.managedObjectContext

}

	override func viewWillAppear(_ animated: Bool) {
		super.viewWillAppear( animated )
		
//        selectedService = -1
        interrogator.delegate = self

        if let scanPerp = self.perp  {
            if interrogator.connected {
                DLog.info( "Already connected to \(scanPerp.mainUUID!)" )
                connected = true
            } else {
                DLog.info( "Start scan for \(scanPerp.mainUUID!)" )
                connected = false
                activityIndicator!.startAnimating()
                interrogator.startScan( forDevices: [CBUUID(string: scanPerp.mainUUID!)] )
            }
            setIndicator( scanPerp.connectable?.boolValue, isConnecting: !connected )
        }
        
    }
	
	override func viewWillDisappear(_ animated: Bool) {
		super.viewWillDisappear( animated )
		
        activityIndicator!.stopAnimating()
	}
    
    deinit {
        
        interrogator.stopInterrogation()
        interrogator.stopScan()
        
    }
	
    
    func setIndicator( _ isConnectable: Bool?, isConnecting: Bool ) {
		if let connectable = isConnectable {
			if connectable {
				if connected {
					connectionIndicator!.image = Indicator.green.image()
                    connectButton.isEnabled = false
				} else {
					connectionIndicator!.image = Indicator.yellow.image()
//                    DLog.error( "Enabling connectButton" )
                    if isConnecting {
                        connectButton.isEnabled = false
                    } else {
                        connectButton.isEnabled = true
                    }
				}
			} else {
				connectionIndicator!.image = Indicator.red.image()
                connectButton.isEnabled = false
			}
		} else {
			connectionIndicator!.image = Indicator.red.image()
            connectButton.isEnabled = false
		}
	}

    @IBAction func doConnect(_ sender: UIBarButtonItem) {
        DLog.trace( "doConnect from bar button" )
        connectButton.isEnabled = false

        if let connectingPerp = connectedPerp {
            activityIndicator!.startAnimating()
            interrogator.startInterrogation( forDevice: connectingPerp )
        }
    }
    
    
    //  MARK: - peripheralConnectionProtocol delegate methods
    
    func foundPeripheral( _ peripheral: CBPeripheral, isConnectable connectable: Bool ) {
        DLog.trace( "foundPeripheral: connectable: \(connectable), peripheral: \(peripheral.identifier.uuidString)" )
        if ( connectable ) {
            activityIndicator!.startAnimating()
            self.connectedPerp = peripheral
            interrogator.startInterrogation( forDevice: peripheral )
        } else {
            activityIndicator!.stopAnimating()
            DLog.info( "Not Connectable" )
        }
//        setIndicator( connectable, isConnecting: false )
    }
    
    func connectionStatus( _ connected: Bool, forPeripheral peripheral: CBPeripheral ) {
        DLog.trace( "connectionStatus, connected: \(connected)" )
        activityIndicator!.stopAnimating()
//		interrogator.stopInterrogation() // ?? Is this needed ??
        self.connected = connected
        setIndicator( true, isConnecting: false )
		if connected {
			updateConnection( peripheral )
        } else {
			disconnectConnection( peripheral )
        }
    }
    
    func servicesDiscovered( _ peripheral: CBPeripheral ) {
        
//        DLog.trace( "servicesDiscovered with \(peripheral.services?.count) services" )
        
        services = peripheral.services
        
        tableView.reloadData()
        
    }
    
    func includedServicesDiscovered( _ peripheral: CBPeripheral, forService service: CBService ) {

//        DLog.trace( "includedServicesDiscovered for \(service.UUID.UUIDString)" )
        
        services = peripheral.services
//        for index in 0..<services!.count {
//            DLog.info( "includedServicesDiscovered, services UUID \(index): \(services![index].UUID.UUIDString) - \(services![index])" )
//        }
        
        tableView.reloadData()
        
    }
 
    func characteristicsDiscovered( _ peripheral: CBPeripheral, forService service: CBService ) {

//        DLog.trace( "characteristicsDiscovered for \(service.UUID.UUIDString)" )
        
        services = peripheral.services
        
        tableView.reloadData()
        
    }
 
    
//--    ----    ----    ----
	
	func updateConnection( _ peripheral: CBPeripheral ) {
		
		DLog.trace( "updateConnection, peripheral; name: \(peripheral.name ?? "?"), state: \(peripheral.state.rawValue)" )

        interrogator.startServiceDiscovery( peripheral )
        
	}
	
	func disconnectConnection( _ peripheral: CBPeripheral ) {
		
		DLog.trace( "disconnectConnection, peripheral; name: \(peripheral.name ?? "?"), state: \(peripheral.state.rawValue)" )

        connected = false
        selectedService = -1
        setIndicator( true, isConnecting: false )
        
        services = nil
        
        tableView.reloadData()
	}

    
    // MARK: - Segues
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        guard selectedService >= 0 else { DLog.info( "selectedService invalid" ); return }
        if segue.identifier == "toCharacteristics" {
            DLog.info( "Segue to Characteristics" )
//            interrogator.stopScan()
            if let indexPath = self.tableView.indexPathForSelectedRow {
                DLog.info( "selectedService: \(selectedService), indexPath.row: \((indexPath as NSIndexPath).row)" )
                let controller = segue.destination as! ShowCharacteristics
                controller.serviceIndex = selectedService
                controller.characteristicsIndex = (indexPath as NSIndexPath).row
                controller.peripheral = connectedPerp
            }
        }
    }
    

    //  MARK: - UITableViewDelegate methods
    
    override func numberOfSections( in tableView: UITableView ) -> Int {
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
    
    internal override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        
        return 30.0;
    }

    override func tableView( _ tableView: UITableView, heightForRowAt indexPath: IndexPath ) -> CGFloat {
        return 66.0
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if (indexPath as NSIndexPath).section == 0 {
            if connected {
                selectedService = (indexPath as NSIndexPath).row
                tableView.reloadData()
            }
        }
    }

    
    //  MARK: - UITableViewSource methods

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
    
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

    override func tableView( _ tableView: UITableView, numberOfRowsInSection section: NSInteger ) -> NSInteger {
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
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath ) -> UITableViewCell {
        
        switch (indexPath as NSIndexPath).section {
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

    func configureMainService( _ indexPath: IndexPath ) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell( withIdentifier: "centralServiceCell", for: indexPath ) as! ServiceCell
        var service = services![(indexPath as NSIndexPath).row]
        if (indexPath as NSIndexPath).section != 0 {
            if let included = service.includedServices {
                if (indexPath as NSIndexPath).row < included.count {
                    service = included[(indexPath as NSIndexPath).row]
                }
            }
        }
    
        cell.nameField.text = cleanName( service.peripheral.name )
        cell.IDField.text = bluetoothUUID( service.uuid.uuidString )
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
    
    func configureCharacteristics( _ indexPath: IndexPath ) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell( withIdentifier: "centralDisplayCharacteristic", for: indexPath ) as! CharacteristicCell
        let service = services![selectedService]
        if let characteristics = service.characteristics {
            DLog.info( "indexPath.row: \((indexPath as NSIndexPath).row), characteristics.count = \(characteristics.count)" )
            cell.nameField.text = bluetoothUUID( characteristics[(indexPath as NSIndexPath).row].uuid.uuidString )
            let properties = characteristics[(indexPath as NSIndexPath).row].properties
            DLog.info( "properties: \(properties)" )
            let rawProperties = properties.rawValue
            var propString = ""
            if ( CBCharacteristicProperties.broadcast.rawValue & rawProperties ) != 0 {
                propString += "Broadcast "
            }
            if ( CBCharacteristicProperties.read.rawValue & rawProperties ) != 0 {
                propString += "Read "
            }
            if ( CBCharacteristicProperties.writeWithoutResponse.rawValue & rawProperties ) != 0 {
                propString += "WriteWithoutResponse "
            }
            if ( CBCharacteristicProperties.write.rawValue & rawProperties ) != 0 {
                propString += "Write "
            }
            if ( CBCharacteristicProperties.notify.rawValue & rawProperties ) != 0 {
                propString += "Notify "
            }
            if ( CBCharacteristicProperties.indicate.rawValue & rawProperties ) != 0 {
                propString += "Indicate "
            }
            if ( CBCharacteristicProperties.authenticatedSignedWrites.rawValue & rawProperties ) != 0 {
                propString += "AuthenticatedSignedWrites "
            }
            if ( CBCharacteristicProperties.extendedProperties.rawValue & rawProperties ) != 0 {
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
