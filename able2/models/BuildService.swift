//
//  BuildService.swift
//  able2
//
//  Created by Bill Snook on 6/11/16.
//  Copyright © 2016 William Snook. All rights reserved.
//

import UIKit
import CoreData
import CoreBluetooth


class BuildService {
	
	var service: Service?
	var name: String?
	var uuid: String?
	var primary = true
    var buildCharacteristics: Array<BuildCharacteristic>
	
	init( fromService: Service? ) {
		
		if fromService != nil {
			service = fromService
			name = service!.name
			uuid = service!.uuid
            DLog.debug("Existing Service managed object named: \(name)")
            if let storedPrimary = service!.primary?.boolValue {
                primary = storedPrimary
            } else {
                primary = true
            }
            let characteristics = service!.characteristics
            buildCharacteristics = []
            for characteristic in characteristics! {
                let buildCharacteristic = BuildCharacteristic( fromCharacteristic: characteristic as? Characteristic)
                buildCharacteristics.append( buildCharacteristic )
            }
        } else {
            DLog.debug("With nil Service managed object")
			service = nil
			name = ""
			uuid = ""
			primary = true
			buildCharacteristics = []
		}
	}
    
    func prepareToSave() {

        DLog.debug("")

        if service == nil {
            let appDelegate = UIApplication.shared.delegate as! AppDelegate
            let managedObjectContext = appDelegate.managedObjectContext
            let serviceEntity = NSEntityDescription.entity(forEntityName: "Service", in: managedObjectContext)
            if serviceEntity != nil {
                if let newService = NSManagedObject(entity: serviceEntity!, insertInto: managedObjectContext) as? Service {
                    DLog.debug("  Made new Service managed object")
                    service = newService
                }
            }
        }
        if service != nil {
            service!.name = name
            service!.uuid = uuid
            service!.primary = primary as NSNumber?
            let newSet = NSMutableOrderedSet( capacity: buildCharacteristics.count  )
            for buildCharacteristic in buildCharacteristics {
                DLog.debug("  Found existing Characteristic managed object")
                buildCharacteristic.prepareToSave()
                newSet.add( buildCharacteristic.characteristic! )
            }
            service!.characteristics = newSet
        }
    }
    
    func appendCharacteristic( _ buildCharacteristic: BuildCharacteristic ) {
        
        for bCharacteristic in buildCharacteristics {
            if bCharacteristic.characteristic == buildCharacteristic.characteristic {
                return
            }
        }
        buildCharacteristics.append( buildCharacteristic )
        
    }

    
//    func toBluetooth() -> CBMutableService {
//        
//        let mutableService = CBMutableService( type: CBUUID(string: uuid!), primary: primary )
//        var mutableCharacteristics = [CBMutableCharacteristic]()
//        for buildCharacteristic in buildCharacteristics {
//
//            let mutableCharacteristic = CBMutableCharacteristic( type: CBUUID(string: buildCharacteristic.uuid!), properties: buildCharacteristic.properties!, value: buildCharacteristic.value, permissions: buildCharacteristic.permissions! )
//            mutableCharacteristics.append( mutableCharacteristic )
//        }
//        mutableService.characteristics = mutableCharacteristics
//        return mutableService
//    }
    
    func removeCharacteristicAtIndex( _ row: Int ) {
        
        buildCharacteristics.remove( at: row )
    }
    
    func isValid() -> Bool {        // Valid indicates ready to be saved
        
        guard name != nil && !name!.isEmpty else { return false }
        guard uuid != nil && !uuid!.isEmpty else { return false }
        for buildCharacteristic in buildCharacteristics {
            if !buildCharacteristic.isValid() { return false }
        }
        
        return true
    }
    
    func hasChanged() -> Bool {     // Changed means data does not match service
        
        guard service != nil else { return true }
        guard service!.name == name else { return true }
        guard service!.uuid == uuid else { return true }
        guard service!.primary?.boolValue == primary else { return true }
        guard service!.characteristics?.count == buildCharacteristics.count else { return true }
        for buildCharacteristic in buildCharacteristics {
            if buildCharacteristic.hasChanged() { return true }
        }
        
        return false
    }
    
}
