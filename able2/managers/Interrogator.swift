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
    
    func foundPeripheral( _ peripheral: CBPeripheral, isConnectable connectable: Bool )
    
    func connectionStatus( _ connected: Bool, forPeripheral peripheral: CBPeripheral )
    
    func servicesDiscovered( _ peripheral: CBPeripheral )

    func includedServicesDiscovered( _ peripheral: CBPeripheral, forService service: CBService )
    
    func characteristicsDiscovered( _ peripheral: CBPeripheral, forService service: CBService )

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
    
//    var scanUUID: CBUUID?


	required init() {

		super.init()
		
		cbManager.delegate = self
		
		Log.trace( "Interrogator init" )
		
	}
	
    //  MARK: - Operation control methods

    func startScan( forDevices deviceList: [CBUUID]? ) {
		
        Log.trace( "Interrogator startScan for \(deviceList!)" )
		// We may want to get duplicates
		//	NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool: NO], CBCentralManagerScanOptionAllowDuplicatesKey, nil]
        deviceUUIDs = deviceList
		if ( .poweredOn == cbManager.state ) {
            if scanRunning {
                if #available(iOS 9.0, *) {
                    if cbManager.isScanning {
                        cbManager.stopScan()
                        resetScanList()
                    }
                } else {
                    cbManager.stopScan()
                    resetScanList()
                }
            }
            Log.trace( "Interrogator starting scanning" )
			scanRunning = true
//            scanUUID = deviceList![0]
			cbManager.scanForPeripherals( withServices: nil, options: nil )	// Search for specific services
		} else {
            Log.warning( "Interrogator scan requested but state wrong: \(cbManager.state.rawValue)" )
		}
	}
	
	
	func startInterrogation( forDevice device: CBPeripheral ) {
        Log.trace( "Interrogator startInterrogation for \(device.identifier.uuidString)" )

        if ( .poweredOn == cbManager.state ) {
            stopScan()
            connectingPerp = device
            connecting = true
            cbManager.connect( device, options: nil )
        }
	}
	
	
	func stopInterrogation() {
        Log.trace( "Interrogator stopInterrogation" )
		
		if ( .poweredOn == cbManager.state ) {
            if connecting || connected {
                if connectingPerp != nil {
                    Log.info( "Stopping trying to connect" )
                    cbManager.cancelPeripheralConnection( connectingPerp! )
                    connectingPerp = nil
                } else if connectedPerp != nil {
                    Log.info( "Cancel connection" )
                    cbManager.cancelPeripheralConnection( connectedPerp! )
                    connectedPerp = nil
                }
                connected = false
                connecting = false
                
            }
		}
	}
    
    func startServiceDiscovery( _ peripheral: CBPeripheral ) {
        Log.trace( "Interrogator startServiceDiscovery" )

        peripheral.delegate = self
        peripheral.discoverServices( nil )	// Search for all

    }
	
	
    //  MARK: - CBCentralManagerDelegate methods

    override func centralManagerDidUpdateState(_ central: CBCentralManager) {
        var state = ""
        switch ( central.state ) {
        case .unknown:
            state = "Currently in an unknown state."
        case .resetting:
            state = "Central Manager is resetting."
        case .unsupported:
            state = "No support for Bluetooth Low Energy."
        case .unauthorized:
            state = "Not authorized to use Bluetooth Low Energy."
        case .poweredOff:
            state = "Currently powered off."
        case .poweredOn:
            state = "Currently powered on."
        }
        Log.info( "Interrogator Bluetooth central state: \(state)" )
        
        if (central.state != .poweredOn) {		// In a real app, you'd deal with all the states correctly
//            resetScanList()
            return
        }
        // The state must be CBCentralManagerStatePoweredOn...
        // ... so start scanning
        self.startScan( forDevices: deviceUUIDs! )

    }
	
    
	func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : AnyObject], rssi RSSI: NSNumber) {
    
//		Log.trace("\n\nInterrogator didDiscoverPeripheral, UUID: \(peripheral.identifier.UUIDString)\n" )
		
        var found = false
        for uuid in deviceUUIDs! {
//            Log.info("Checking for: \(uuid), got: \(peripheral.identifier.UUIDString)" )
            if uuid.uuidString == peripheral.identifier.uuidString {
                found = true
            }
        }
        if found {
            Log.trace("didDiscoverPeripheral, found UUID: \(peripheral.identifier.uuidString)" )
            if let isConnectable = advertisementData[ "kCBAdvDataIsConnectable" ] as? NSNumber {
                connectable = isConnectable.boolValue
            } else {
                connectable = false
            }
            connectingPerp = peripheral
			stopScan()		// Just find the one then stop
            delegate?.foundPeripheral( peripheral, isConnectable: connectable )
//        } else {
//            Log.info("Not the Peripheral we were looking for: \(scanUUID!.UUIDString), got: \(peripheral.identifier.UUIDString)" )
        }
	}
	
	override func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
		
		Log.trace("\n\nInterrogator didDisconnectPeripheral, UUID: \(peripheral.identifier.uuidString)\n" )
        if connectedPerp == peripheral {
            connectedPerp = nil
            connected = false
            connecting = false
            delegate?.connectionStatus( false, forPeripheral: peripheral )
        }
	}
    
   func centralManager(_ central: CBCentralManager, didConnectPeripheral peripheral: CBPeripheral) {
        
        Log.trace("\n\nInterrogator didConnectPeripheral, UUID: \(peripheral.identifier.uuidString)\n" )
        connecting = false
        connected = true
        connectingPerp = nil
        connectedPerp = peripheral
		delegate?.connectionStatus( true, forPeripheral: peripheral )
    }
	
    func centralManager(_ central: CBCentralManager, didFailToConnectPeripheral peripheral: CBPeripheral, error: NSError?) {
        
        Log.trace("\n\nInterrogator didFailToConnectPeripheral, UUID: \(peripheral.identifier.uuidString)\n" )
        connecting = false
        connected = false
        connectingPerp = nil
        connectedPerp = nil
        delegate?.connectionStatus( false, forPeripheral: peripheral )
    }

	//  MARK: - CBPeripheralDelegate methods
	
	// Services were discovered
	func peripheral( _ peripheral: CBPeripheral, didDiscoverServices error: Error? ) {
        Log.trace("Interrogator didDiscoverServices" )
		
		if error != nil {
			print( "Error discovering services: \(error!.localizedDescription)" )
//			[self cleanup]
			return
		}
		
		// Discover any included services and characteristics
		
        delegate?.servicesDiscovered( peripheral )
        
        for service in peripheral.services! {
//            Log.info( "Peripheral service discovered: \(service)" )
            peripheral.discoverIncludedServices( nil, for: service )
            peripheral.discoverCharacteristics( nil, for: service )
        }
        
	}
	
	
	func peripheral(_ peripheral: CBPeripheral, didModifyServices invalidatedServices: [CBService]) {
		Log.trace( "Interrogator didModifyServices" )
		
		for serv in invalidatedServices {
			Log.trace( "Invalidated service: \(serv)" )
		}
	}
	
	
	func peripheral(_ peripheral: CBPeripheral, didDiscoverIncludedServicesFor service: CBService, error: Error?) {
//      Log.trace("Interrogator didDiscoverIncludedServicesForService")
		
		if (error != nil) {
			Log.error( "Error discovering included services: \(error!.localizedDescription)" )
//			[self cleanup]
			return
		}
		
//		Log.info("Included Services discovered: \(service.includedServices)" )

        delegate?.includedServicesDiscovered( peripheral, forService: service )
        
	}
	
	
	func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
//		Log.trace("Interrogator didDiscoverCharacteristicsForService")
		
		if error != nil {
			Log.error( "Error discovering characteristics: \(error!.localizedDescription)" )
//			[self cleanup]
			return
		}
		
//		Log.info( "Characteristics discovered: \(service.characteristics)" )

        delegate?.characteristicsDiscovered( peripheral, forService: service )

	}
	
	

}
