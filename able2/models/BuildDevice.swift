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
            let services = device!.services
            buildServices = []
            for service in services! {
                let buildService = BuildService( fromService: service as? Service)
                buildServices.append( buildService )
            }
            // WFS char setup
        } else {
			device = nil
			name = ""
			uuid = ""
			buildServices = []
		}
	}
    
    func save( managedObjectContext: NSManagedObjectContext ) {
        
        if device != nil {
            device!.name = name
            device!.uuid = uuid
        } else {
            let deviceEntity = NSEntityDescription.entityForName("Device", inManagedObjectContext: managedObjectContext)
            if deviceEntity != nil {
                if let newDevice = NSManagedObject(entity: deviceEntity!, insertIntoManagedObjectContext: managedObjectContext) as? Device {
                    device = newDevice
                    newDevice.name = name
                    newDevice.uuid = uuid
                }
            }
        }
        if device != nil {
            let newSet = NSMutableOrderedSet( capacity: buildServices.count  )
            for buildService in buildServices {
                let serviceEntity = NSEntityDescription.entityForName("Service", inManagedObjectContext: managedObjectContext)
                if let newService = NSManagedObject(entity: serviceEntity!, insertIntoManagedObjectContext: managedObjectContext) as? Service {
//                    buildService.save( newService )
                    newSet.addObject( newService )
                }
            }
            device!.services = newSet
        }
        if device != nil {
            do {
                try managedObjectContext.save()
            } catch let error as NSError {
                Log.error("Could not fetch \(error), \(error.userInfo)")
            }
            catch {
                Log.error("Could not fetch \(error)")
            }
        }
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
	
}
