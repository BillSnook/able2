//
//  BuildDevice.swift
//  able2
//
//  Created by Bill Snook on 6/11/16.
//  Copyright © 2016 William Snook. All rights reserved.
//

import Foundation
import CoreData
import CoreBluetooth


class BuildDevice {
	
	var device: Device?
	var name: String?
	var uuid: String?
    var buildServices: Array<BuildService>
	
	init( fromDevice: Device? ) {
		
		if fromDevice != nil {
			device = fromDevice
			name = device!.name
			uuid = device!.uuid
            Log.debug("Init with existing Device managed object named: \(name)")
            let services = device!.services
            buildServices = []
            for service in services! {
                let buildService = BuildService( fromService: service as? Service)
                buildServices.append( buildService )
            }
            // WFS char setup
        } else {
            Log.debug("Init with nil Device managed object")
			device = nil
			name = ""
			uuid = ""
			buildServices = []
		}
	}
    
    func save( managedObjectContext: NSManagedObjectContext ) {
        
        Log.debug("")
        if device == nil {
            if let deviceEntity = NSEntityDescription.entityForName("Device", inManagedObjectContext: managedObjectContext) {
                if let newDevice = NSManagedObject(entity: deviceEntity, insertIntoManagedObjectContext: managedObjectContext) as? Device {
                    Log.debug("  Made new Device managed object")
                    device = newDevice
                }
            }
        }
        
        if device != nil {
            device!.name = name
            device!.uuid = uuid
            let newSet = NSMutableOrderedSet( capacity: buildServices.count  )
            for buildService in buildServices {
//                if buildService.service != nil {
                    Log.debug("  Found existing Service managed object")
                    buildService.save( managedObjectContext )
                    newSet.addObject( buildService.service! )
//                } else {
//                    let serviceEntity = NSEntityDescription.entityForName("Service", inManagedObjectContext: managedObjectContext)
//                    if let newService = NSManagedObject(entity: serviceEntity!, insertIntoManagedObjectContext: managedObjectContext) as? Service {
//                        Log.debug("  Made new Service managed object")
//                        buildService.save( managedObjectContext )
//                        newSet.addObject( newService )
//                    }
//                }
            }
            device!.services = newSet
        }
    }
    
    func appendService( buildService: BuildService ) {
        
        for bService in buildServices {
            if bService.service == buildService.service {
                return
            }
        }
        buildServices.append( buildService )
        
    }
    
    func removeServiceAtIndex( row: Int ) {
        
        buildServices.removeAtIndex( row )
    }
    
    
//    func toBluetooth() -> CBMutableService {
//        
//        let mutableService = CBMutableService( type: CBUUID(string: uuid!), primary: primary! )
//        var mutableCharacteristics = [CBMutableCharacteristic]()
//        for buildCharacteristic in buildCharacteristics {
//
//            let mutableCharacteristic = CBMutableCharacteristic( type: CBUUID(string: buildCharacteristic.uuid!), properties: buildCharacteristic.properties!, value: buildCharacteristic.value, permissions: buildCharacteristic.permissions! )
//            mutableCharacteristics.append( mutableCharacteristic )
//        }
//        mutableService.characteristics = mutableCharacteristics
//        return mutableService
//    }
	
    func isValid() -> Bool {        // Valid indicates ready to be saved
        
        guard name != nil && !name!.isEmpty else { return false }
        guard uuid != nil && !uuid!.isEmpty else { return false }
        for buildService in buildServices {
            if !buildService.isValid() { return false }
        }
        
        return true
    }
    
    func hasDeviceChanged() -> Bool {     // Changed means data does not match service
        
        guard device != nil else { return true }
        guard device!.name == name else { return true }
        guard device!.uuid == uuid else { return true }
        guard device!.services?.count == buildServices.count else { return true }
        
        return false
    }
    
    func hasChanged() -> Bool {     // Changed means data does not match service
        
        guard device != nil else { return true }
        guard device!.name == name else { return true }
        guard device!.uuid == uuid else { return true }
        guard device!.services?.count == buildServices.count else { return true }
        for buildService in buildServices {
            if buildService.hasChanged() { return true }
        }
        
        return false
    }
    
}
