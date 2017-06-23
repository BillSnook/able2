//
//  BuildDevice.swift
//  able2
//
//  Created by Bill Snook on 6/11/16.
//  Copyright © 2016 William Snook. All rights reserved.
//

import UIKit
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
            DLog.debug("Init with existing Device managed object named: \(name!)")
            let services = device!.services
            buildServices = []
            for service in services! {
                let buildService = BuildService( fromService: service as? Service)
                buildServices.append( buildService )
            }
        } else {
            DLog.debug("Init with nil Device managed object")
			device = nil
			name = ""
			uuid = ""
			buildServices = []
		}
	}
    
    func prepareToSave() {
        
        DLog.debug("")

        if device == nil {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let managedObjectContext = appDelegate.managedObjectContext
            if let deviceEntity = NSEntityDescription.entity(forEntityName: "Device", in: managedObjectContext) {
                if let newDevice = NSManagedObject(entity: deviceEntity, insertInto: managedObjectContext) as? Device {
                    DLog.debug("  Made new Device managed object")
                    device = newDevice
                }
            }
        }
        if device != nil {
            device!.name = name
            device!.uuid = uuid
            let newSet = NSMutableOrderedSet( capacity: buildServices.count  )
            for buildService in buildServices {
                DLog.debug("  Found existing Service managed object")
                buildService.prepareToSave()
                newSet.add( buildService.service! )
            }
            device!.services = newSet
        }
    }
    
    func appendService( _ buildService: BuildService ) {
        
        for bService in buildServices {
            if bService.service == buildService.service {
                return
            }
        }
        buildServices.append( buildService )
        
    }
    
    func removeServiceAtIndex( _ row: Int ) {
        
        buildServices.remove( at: row )
    }
    
    
    func toBluetooth() -> CBMutableService? {

        guard buildServices.count > 0 else { return nil }
        let buildService = buildServices[0]
        let mutableService = CBMutableService( type: CBUUID(string: buildService.uuid!), primary: buildService.primary )
        var mutableCharacteristics = [CBMutableCharacteristic]()
        for buildCharacteristic in buildService.buildCharacteristics {

            let mutableCharacteristic = CBMutableCharacteristic( type: CBUUID(string: buildCharacteristic.uuid!), properties: buildCharacteristic.properties!, value: buildCharacteristic.value as Data?, permissions: buildCharacteristic.permissions! )
            mutableCharacteristics.append( mutableCharacteristic )
        }
        mutableService.characteristics = mutableCharacteristics
        return mutableService
    }
	
    func isValid() -> Bool {        // Valid indicates ready to be saved
        
        guard name != nil && !name!.isEmpty else { return false }
        guard uuid != nil && !uuid!.isEmpty else { return false }
        for buildService in buildServices {
            if !buildService.isValid() { return false }
        }
        
        return true
    }
    
    func hasDeviceChanged() -> Bool {     // Changed means device data does not match original
        
        guard device != nil else { return true }
        guard device!.name == name else { return true }
        guard device!.uuid == uuid else { return true }
        guard device!.services?.count == buildServices.count else { return true }
        
        return false
    }
    
    func hasChanged() -> Bool {         // Changed means data does not match in device and subservices
        
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
