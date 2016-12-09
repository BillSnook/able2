//
//  Scanner.swift
//  able
//
//  Created by William Snook on 3/6/16.
//  Copyright © 2016 Bill Snook. All rights reserved.
//

import Foundation
import UIKit
import CoreBluetooth
import CoreData


protocol CBPeripheralProtocol {
    var name: String? { get }
    var identifier: UUID { get }
}

extension CBPeripheral: CBPeripheralProtocol {
    
}

class Scanner: NSObject, CBCentralManagerDelegate {
    
    static let sharedScanner = Scanner()
//    private override init() { } //This prevents others from using the default '()' initializer for this class.

    
    var cbManager: CBCentralManager
    var scanRunning = false
    
    var managedObjectContext: NSManagedObjectContext?


    required override init() {
        cbManager = CBCentralManager( delegate: nil, queue: nil )
        
        super.init()
        
        cbManager.delegate = self

        Log.trace( "Scanner init" )

}

// Mark peripheralScan methods
    
    func resetScanList() {
//        masterList.removeAll()
    }
    
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        var state = ""
        switch ( central.state ) {
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
            case .unknown:
                state = "Currently in an unknown state."
        }
        Log.info( "Bluetooth central state: \(state)" )
        
        if (central.state != .poweredOn) {		// In a real app, you'd deal with all the states correctly
            resetScanList()
            return
        }
        // The state must be CBCentralManagerStatePoweredOn...
        // ... so start scanning
        self.startScan()
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {
   
//        print( "Peripheral UUID: \(peripheral.identifier.UUIDString)" )

//
//        guard RSSI.integerValue < -15 else {    // Reject any where the signal strength is above reasonable range
//            print( "Too Strong: \(RSSI.integerValue)" )
//            return
//        }
//        guard RSSI.integerValue > -90 else {    // Reject if the signal strength is too low to be close enough (Close is around -22dB)
//            print( "Too Weak: \(RSSI.integerValue)" )
//            return
//        }
//
//        if let name = peripheral.name {
//            print( "Signal strength for \(name): \(RSSI)" )
//        } else {
//            print( "Signal strength for unnamed device: \(RSSI)" )
//        }
//        print( "Advertised Data:\n\( advertisementData.description )" )

/*
    29:19.632 abListPeriph:  288 [60b] centralManager:didDiscoverPeriph  Discovered (null) at -62
    29:19.636 abListPeriph:  289 [60b] centralManager:didDiscoverPeriph  advertisementData: {
    kCBAdvDataChannel = 39
    kCBAdvDataIsConnectable = 1
    kCBAdvDataLocalName = HeartBeat
    kCBAdvDataServiceUUIDs =     (
    "Unknown (<e20a39f4 73f54bc4 a12f17d1 ad07a961>)"
    )
    }
*/
        
        // See of peripheral (with id) already exists
        let fetch: NSFetchRequest<Peripheral> = NSFetchRequest( entityName: "Peripheral" )
        let predicate = NSPredicate( format: "mainUUID == '\(peripheral.identifier.uuidString)'" )
        fetch.predicate = predicate
        
        do {
            let results = try managedObjectContext!.fetch( fetch )
            if results.count > 1 {
                Log.error( "\n\nError - results.count: \(results.count)\n" )
            }
            if results.isEmpty {
                storeEntry( peripheral, advertisementData: advertisementData as [String : AnyObject], RSSI: RSSI, managedContext: managedObjectContext! )
            } else {        // We matched an existing entry
                let entry = results[0]
                updateEntry( entry, peripheral: peripheral, advertisementData: advertisementData as [String : AnyObject], RSSI: RSSI, managedContext: managedObjectContext! )
//                print( "    Existing entry found" )
            }
        } catch let error as NSError {
            Log.error("Could not fetch \(error), \(error.userInfo)")
        }

    }
   
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        
        Log.trace("\n\nScanner didDisconnectPeripheral, UUID: \(peripheral.identifier.uuidString)\n" )

    }
    

    func storeEntry( _ peripheral: CBPeripheralProtocol, advertisementData: [String : AnyObject], RSSI: NSNumber, managedContext: NSManagedObjectContext ) {
        let peripheralEntity = NSEntityDescription.entity(forEntityName: "Peripheral", in: managedContext)
        guard peripheralEntity != nil else {
            return
        }
        if let entry = NSManagedObject(entity: peripheralEntity!, insertInto: managedContext) as? Peripheral {
            entry.mainUUID = peripheral.identifier.uuidString
            if let name = peripheral.name {
                if name.isEmpty {
                    entry.name = "~Blank name"
                } else {
                    if name.characters.count > 7 {
                        let checkRange = name[name.startIndex..<name.characters.index(name.startIndex, offsetBy: 8)]
//                        print("checkRange: \(checkRange)" )
                        if (Int(checkRange) != nil) {
                            entry.name = "~\(peripheral.name!)"
                        } else {
                            entry.name = peripheral.name
                        }
                    } else {
                        entry.name = peripheral.name
                    }
                }
            } else {
                entry.name = "~No name"
            }
            if let connectable = advertisementData[ "kCBAdvDataIsConnectable" ] as? NSNumber {
                entry.connectable = connectable.boolValue as NSNumber?
            } else {
                entry.connectable = false
            }
            entry.rssi = RSSI

            let sightingEntity = NSEntityDescription.entity(forEntityName: "Sighting", in: managedContext)
            if let newSighting = NSManagedObject(entity: sightingEntity!, insertInto: managedContext) as? Sighting {
                newSighting.date = Date()
                newSighting.rssi = RSSI
                entry.sightings = NSSet( object: newSighting )
            }
        }
        
        do {
            try managedContext.save()
//            print("storeEntry After Try")
        } catch let error as NSError  {
            Log.error("Could not save \(error), \(error.userInfo)")
        }
//        print("storeEntry After do-loop")
    }
    
    func updateEntry( _ entry: Peripheral, peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber, managedContext: NSManagedObjectContext ) {
        let sightingEntity = NSEntityDescription.entity(forEntityName: "Sighting", in: managedContext)
        if let newSighting = NSManagedObject(entity: sightingEntity!, insertInto: managedContext) as? Sighting {
            newSighting.date = Date()
            newSighting.rssi = RSSI
            let sightings = entry.mutableSetValue( forKey: "sightings" )
            sightings.add( newSighting )
        }

        do {
            try managedContext.save()
//            print("updateEntry After Try")
        } catch let error as NSError  {
            Log.error("Could not save \(error), \(error.userInfo)")
        }
//        print("updateEntry After do-loop")
    }

    //  MARK: - connection methods
    
	func startScan() {
		
		// We may want to get duplicates
		//	NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool: NO], CBCentralManagerScanOptionAllowDuplicatesKey, nil]
		if ( .poweredOn == cbManager.state ) && !scanRunning {
            if #available(iOS 9.0, *) {
                if cbManager.isScanning {
                    cbManager.stopScan()
                    resetScanList()
                }
            } else {
                cbManager.stopScan()
                resetScanList()
            }
            Log.info( "Scanner starting scanning" )
			scanRunning = true
			cbManager.scanForPeripherals( withServices: nil, options: nil )	// Search for any service - power usage higher
		} else {
			Log.warning( "Scan requested but state wrong: \(cbManager.state)" )
		}
	}
	
    func stopScan() {
		
        if ( .poweredOn == cbManager.state ) {
            if #available(iOS 9.0, *) {
                if cbManager.isScanning {
					Log.info( "Stopping scanning" )
                    cbManager.stopScan()
                }
            } else {
				Log.info( "Stopping scanning" )
                cbManager.stopScan()
            }
            scanRunning = false
        }
    }
    
}
