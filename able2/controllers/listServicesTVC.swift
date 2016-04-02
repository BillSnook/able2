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


class ListServicesTVC: UITableViewController, CBCentralManagerDelegate, CBPeripheralDelegate {
    
    var perp: Peripheral?
    
    var centralManager: CBCentralManager?
    var scanner: Scanner?
    
    var services: [Peripheral]?
    
    
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
            return
        }
        // The state must be CBCentralManagerStatePoweredOn...
        // ... so start scanning
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
        
//        let managedContext = appDelegate.managedObjectContext
//        // See of joke (with id) already exists
//        let fetch = NSFetchRequest( entityName: "Peripheral" )
//        let predicate = NSPredicate( format: "mainUUID == '\(peripheral.identifier.UUIDString)'" )
//        fetch.predicate = predicate
//        
//        do {
//            let results = try managedContext.executeFetchRequest( fetch )
//            if results.isEmpty {
//                storeEntry( peripheral, advertisementData: advertisementData, RSSI: RSSI )
//            } else {        // We matched an existing entry
//                let entry = results[0] as! Peripheral
//                updateEntry( entry, peripheral: peripheral, advertisementData: advertisementData, RSSI: RSSI )
//                //                print( "    Existing entry found" )
//            }
//        } catch let error as NSError {
//            print("Could not fetch \(error), \(error.userInfo)")
//        }
        
    }
    
//  MARK - CBPeripheral Delegate methods
    
    // Services were discovered
    func peripheral( peripheral: CBPeripheral, didDiscoverServices error: NSError? ) {
    
        if error != nil {
            print( "Error discovering services: \(error!.localizedDescription)" )
//        [self cleanup];
            return
        }
    
    // Discover any included services and characteristics
        print( "Peripheral services discovered: \(peripheral.services)" )
    
    // Loop through the newly filled peripheral.services array, just in case there's more than one.
        services!.removeAll()
        for service in peripheral.services! {
//            print( "Service discovered: \(service.UUID.uuid2string)" )
//            abService *abServ = [[abService alloc] initWithName: advertName andID: [service.UUID uuid2string] andService: service];
//            [services addObject: abServ];
//            [peripheral discoverIncludedServices: nil forService: service];
////        [peripheral discoverCharacteristics: nil forService: service];
        }
        tableView.reloadData()
    }
    
    
    func peripheral(peripheral: CBPeripheral, didModifyServices invalidatedServices: [CBService]) {
        print( "didModifyServices" );
    
        for serv in invalidatedServices {
            print( "Invalidated service: \(serv)" )
        }
    }
    
    
    func peripheral(peripheral: CBPeripheral, didDiscoverIncludedServicesForService service: CBService, error: NSError?) {
        print("didDiscoverIncludedServicesForService")
    
        if (error != nil) {
            print( "Error discovering included services: \(error!.localizedDescription)" )
//		[self cleanup];
            return
        }
    
        print("Included Services discovered: \(service.includedServices)" )
        // Loop through the newly filled peripheral.services array, just in case there's more than one.
        for serv in services! {
//            if ( service.UUID.isEqual( serv.service.UUID ) ) {
//                serv.subservices = service.includedServices
//            }
        }
        self.tableView.reloadData()
    
    }
    
    
    func peripheral(peripheral: CBPeripheral, didDiscoverCharacteristicsForService service: CBService, error: NSError?) {
        print("didDiscoverCharacteristicsForService")
    
        if error != nil {
            print( "Error discovering characteristics: \(error!.localizedDescription)" )
    //		[self cleanup];
            return
        }
    
        print( "Characteristics discovered: \(service.characteristics)" )
        // Loop through the newly filled peripheral.services array, just in case there's more than one.
        for serv in services! {
//            if ( service.isEqual( serv.service ) ) {
//                serv.characteristics = [NSMutableArray arrayWithArray: service.characteristics];
//            }
        }
        self.tableView.reloadData()
    
    }
    

    
}