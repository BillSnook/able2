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


class Scanner : NSObject, CBCentralManagerDelegate {
    
    static let sharedInstance = Scanner()
    
    
    var cbManager: CBCentralManager
    var scanRunning = false
    
//    var delegate: ScannerDelegate?
//    var masterList = [abPeripheral]()

    var appDelegate: AppDelegate
    var managedObjectContext: NSManagedObjectContext


    required override init() {
        cbManager = CBCentralManager( delegate: nil, queue: nil )
        appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        managedObjectContext = appDelegate.managedObjectContext
        
        super.init()
        
        cbManager.delegate = self

        print( "Scanner init" )

}

// Mark peripheralScan methods
    
    func resetScanList() {
//        masterList.removeAll()
    }
    
    func centralManagerDidUpdateState(central: CBCentralManager) {
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
        print( "Bluetooth central state: \(state)" )
        
        if (central.state != .PoweredOn) {		// In a real app, you'd deal with all the states correctly
            resetScanList()
            return
        }
        // The state must be CBCentralManagerStatePoweredOn...
        // ... so start scanning
        self.startScan()
    }
    
    func centralManager(central: CBCentralManager, didDiscoverPeripheral peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber) {
   
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
        
        let managedContext = appDelegate.managedObjectContext
        // See of joke (with id) already exists
        let fetch = NSFetchRequest( entityName: "Peripheral" )
        let predicate = NSPredicate( format: "mainUUID == '\(peripheral.identifier.UUIDString)'" )
        fetch.predicate = predicate
        
        do {
            let results = try managedContext.executeFetchRequest( fetch )
            if results.isEmpty {
                storeEntry( peripheral, advertisementData: advertisementData, RSSI: RSSI )
            } else {        // We matched an existing entry
                let entry = results[0] as! Peripheral
                updateEntry( entry, peripheral: peripheral, advertisementData: advertisementData, RSSI: RSSI )
//                print( "    Existing entry found" )
            }
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }

    }
    
    func storeEntry( peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber ) {
        let managedContext = appDelegate.managedObjectContext
        let peripheralEntity =  NSEntityDescription.entityForName("Peripheral", inManagedObjectContext: managedContext)
        if let entry = NSManagedObject(entity: peripheralEntity!, insertIntoManagedObjectContext: managedContext) as? Peripheral {
            entry.mainUUID = peripheral.identifier.UUIDString
            if let name = peripheral.name {
                if name.isEmpty {
                    entry.name = "~ Empty name ~"
                } else {
                    entry.name = peripheral.name
                }
            } else {
                entry.name = "~ Nil name ~"
            }
            if let connectable = advertisementData[ "kCBAdvDataIsConnectable" ] as? NSNumber {
                entry.connectable = connectable.boolValue
            } else {
                entry.connectable = false
            }
            entry.rssi = RSSI.shortValue   // Deprecated

            let sightingEntity = NSEntityDescription.entityForName("Sighting", inManagedObjectContext: managedContext)
            if let newSighting = NSManagedObject(entity: sightingEntity!, insertIntoManagedObjectContext: managedContext) as? Sighting {
                newSighting.date = NSDate().timeIntervalSince1970
                newSighting.rssi = RSSI.shortValue
                entry.sightings = NSSet( object: newSighting )
            }
        }
        
        do {
            try managedContext.save()
//            print("storeEntry After Try")
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        }
//        print("storeEntry After do-loop")
    }
    
    func updateEntry( entry: Peripheral, peripheral: CBPeripheral, advertisementData: [String : AnyObject], RSSI: NSNumber ) {
        let managedContext = appDelegate.managedObjectContext
        let sightingEntity = NSEntityDescription.entityForName("Sighting", inManagedObjectContext: managedContext)
        if let newSighting = NSManagedObject(entity: sightingEntity!, insertIntoManagedObjectContext: managedContext) as? Sighting {
            newSighting.date = NSDate().timeIntervalSince1970
            newSighting.rssi = RSSI.shortValue
            let sightings = entry.mutableSetValueForKey( "sightings" )
            sightings.addObject( newSighting )
        }

        do {
            try appDelegate.managedObjectContext.save()
//            print("updateEntry After Try")
        } catch let error as NSError  {
            print("Could not save \(error), \(error.userInfo)")
        }
//        print("updateEntry After do-loop")
    }

    func startScan() {
    
    // We may want to get duplicates
    //	NSDictionary *options = [NSDictionary dictionaryWithObjectsAndKeys:[NSNumber numberWithBool: NO], CBCentralManagerScanOptionAllowDuplicatesKey, nil]
        if ( .PoweredOn == cbManager.state ) && !scanRunning {
            cbManager.stopScan()
            print( "Starting scanning" )
            resetScanList()
            scanRunning = true
            cbManager.scanForPeripheralsWithServices( nil, options: nil )	// Search for any service - power usage higher
        } else {
            print( "Scan requested but state wrong: \(cbManager.state)" )
        }
    }
    
    func stopScan() {
    
        if ( .PoweredOn == cbManager.state ) {
            print( "Stopping scanning" )
            cbManager.stopScan()
            scanRunning = false
        }
    }
    
//  MARK: connection methods
    
    
}
