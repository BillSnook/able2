//
//  Interrogator.swift
//  able2
//
//  Created by Bill Snook on 4/3/16.
//  Copyright © 2016 William Snook. All rights reserved.
//

import Foundation
import CoreBluetooth


protocol peripheralConnectionProtocol {
    
    func connectableState( connectable: Bool, forPeripheral: CBPeripheral )
    
    func connectionStatus( connected: Bool )
    
    func disconnectionStatus( connected: Bool )
    
}


class Interrogator: Scanner, CBPeripheralDelegate {
	
	static let sharedInterrogator = Interrogator()
    
    var delegate: peripheralConnectionProtocol?
    
    var connectable = false
    var connecting = false
    var connected = false
    
    var connectingPerp: CBPeripheral?
    var connectedPerp: CBPeripheral?
    
    var deviceUUIDs: [CBUUID]?


	required init() {

		super.init()
		
		cbManager.delegate = self
		
		print( "Interrogator init" )
		
	}
	
	func startScan( forDevices deviceList: [CBUUID]? ) {
		
        print( "Interrogator startScan for \(deviceList)" )
		// We may want to get duplicates
		//	NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool: NO], CBCentralManagerScanOptionAllowDuplicatesKey, nil]
        deviceUUIDs = deviceList
		if ( .PoweredOn == cbManager.state ) && !scanRunning {
            if #available(iOS 9.0, *) {
                if cbManager.isScanning {
                    cbManager.stopScan()
                    resetScanList()
                }
            } else {
                cbManager.stopScan()
                resetScanList()
            }
            print( "Interrogator starting scanning" )
			scanRunning = true
			cbManager.scanForPeripheralsWithServices( deviceList, options: nil )	// Search for specific services
		} else {
			print( "Interrogator scan requested but state wrong: \(cbManager.state)" )
		}
	}
	
	
	func startInterrogation( forDevice device: CBPeripheral ) {
        print( "Interrogator startInterrogation" )

        stopScan()
        connectingPerp = device
        connecting = true
        cbManager.connectPeripheral( device, options: nil )

	}
	
	
	func stopInterrogation() {
        print( "Interrogator stopInterrogation" )
		
		if ( .PoweredOn == cbManager.state ) {
            if let connecting = connectingPerp {
                print( "Stopping Connecting" )
                cbManager.cancelPeripheralConnection( connecting )
            }
			connecting = false
		}
	}
	
	
	//  MARK - CBCentral Delegate methods

    override func centralManagerDidUpdateState(central: CBCentralManager) {
        var state = ""
        switch ( central.state ) {
        case .Resetting:
            state = "Central Manager is resetting."
        case .Unsupported:
            state = "No support for Bluetooth Low Energy."
        case .Unauthorized:
            state = "Not authorized to use Bluetooth Low Energy."
        case .PoweredOff:
            state = "Currently powered off."
        case .PoweredOn:
            state = "Currently powered on."
        case .Unknown:
            state = "Currently in an unknown state."
        }
        print( "Interrogator Bluetooth central state: \(state)" )
        
        if (central.state != .PoweredOn) {		// In a real app, you'd deal with all the states correctly
//            resetScanList()
            return
        }
        // The state must be CBCentralManagerStatePoweredOn...
        // ... so start scanning
        self.startScan( forDevices: deviceUUIDs! )

    }
	
	override func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber) {
		
		print("\n\nInterrogator didDiscoverPeripheral, UUID: \(peripheral.identifier.UUIDString)\n\n" )
		
        var found = false
        for uuid in deviceUUIDs! {
            if uuid == peripheral.identifier.UUIDString {
                found = true
            }
        }
        if found {
            if let isConnectable = advertisementData[ "kCBAdvDataIsConnectable" ] as? NSNumber {
                connectable = isConnectable.boolValue
                delegate?.connectableState( connectable, forPeripheral: peripheral )
            } else {
                connectable = false
            }
        } else {
            print("Not the Peripheral we were looking for: \(connectedPerp?.identifier.UUIDString), got: \(peripheral.identifier.UUIDString)" )
        }
	}
	
	override func centralManager(central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: NSError?) {
		
		print("\n\nInterrogator didDisconnectPeripheral, UUID: \(peripheral.identifier.UUIDString)\n\n" )
        if connectedPerp == peripheral {
            connectedPerp = nil
            connecting = false
            delegate?.disconnectionStatus( false )
        }
	}
    
    func centralManager(central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
        
        print("\n\nInterrogator didConnectPeripheral, UUID: \(peripheral.identifier.UUIDString)\n\n" )
        connecting = false
        delegate?.connectionStatus( true )
    }
	
    func centralManager(central: CBCentralManager, didFailToConnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        
        print("\n\nInterrogator didFailToConnectPeripheral, UUID: \(peripheral.identifier.UUIDString)\n\n" )
        connecting = false
        delegate?.connectionStatus( false )
    }

	//  MARK - CBPeripheral Delegate methods
	
	// Services were discovered
	func peripheral( peripheral: CBPeripheral, didDiscoverServices error: NSError? ) {
		
		print("Interrogator didDiscoverServices" )
		if error != nil {
			print( "Error discovering services: \(error!.localizedDescription)" )
//			[self cleanup]
			return
		}
		
		// Discover any included services and characteristics
		print( "Peripheral services discovered: \(peripheral.services)" )
		
		// Loop through the newly filled peripheral.services array, just in case there's more than one.
//		services!.removeAll()
//		for service in peripheral.services! {
//            print( "Service discovered: \(service.UUID.uuid2string)" )
//            abService *abServ = [[abService alloc] initWithName: advertName andID: [service.UUID uuid2string] andService: service]
//            [services addObject: abServ]
//            [peripheral discoverIncludedServices: nil forService: service]
////        [peripheral discoverCharacteristics: nil forService: service]
//		}
//		tableView.reloadData()
	}
	
	
	func peripheral(peripheral: CBPeripheral, didModifyServices invalidatedServices: [CBService]) {
		print( "Interrogator didModifyServices" )
		
		for serv in invalidatedServices {
			print( "Invalidated service: \(serv)" )
		}
	}
	
	
	func peripheral(peripheral: CBPeripheral, didDiscoverIncludedServicesForService service: CBService, error: NSError?) {
		print("Interrogator didDiscoverIncludedServicesForService")
		
		if (error != nil) {
			print( "Error discovering included services: \(error!.localizedDescription)" )
//			[self cleanup]
			return
		}
		
		print("Included Services discovered: \(service.includedServices)" )
		// Loop through the newly filled peripheral.services array, just in case there's more than one.
//		for serv in services! {
////            if ( service.UUID.isEqual( serv.service.UUID ) ) {
////                serv.subservices = service.includedServices
////            }
//		}
//		self.tableView.reloadData()
		
	}
	
	
	func peripheral(peripheral: CBPeripheral, didDiscoverCharacteristicsForService service: CBService, error: NSError?) {
		print("Interrogator didDiscoverCharacteristicsForService")
		
		if error != nil {
			print( "Error discovering characteristics: \(error!.localizedDescription)" )
//			[self cleanup]
			return
		}
		
		print( "Characteristics discovered: \(service.characteristics)" )
		// Loop through the newly filled peripheral.services array, just in case there's more than one.
//		for serv in services! {
////            if ( service.isEqual( serv.service ) ) {
////                serv.characteristics = [NSMutableArray arrayWithArray: service.characteristics]
////            }
//		}
//		self.tableView.reloadData()
		
	}
	
	

}