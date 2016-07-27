//
//  BuildService.swift
//  able2
//
//  Created by Bill Snook on 6/11/16.
//  Copyright © 2016 William Snook. All rights reserved.
//

import Foundation
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
            Log.debug("Existing Service managed object named: \(name)")
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
            // WFS char setup
        } else {
            Log.debug("With nil Service managed object")
			service = nil
			name = ""
			uuid = ""
			primary = true
			buildCharacteristics = []
		}
	}
    
    func prepareToSave( managedObjectContext: NSManagedObjectContext ) {

        Log.debug("")
        if service == nil {
            let serviceEntity = NSEntityDescription.entityForName("Service", inManagedObjectContext: managedObjectContext)
            if serviceEntity != nil {
                if let newService = NSManagedObject(entity: serviceEntity!, insertIntoManagedObjectContext: managedObjectContext) as? Service {
                    Log.debug("  Made new Service managed object")
                    service = newService
                }
            }
        }
        if service != nil {
            service!.name = name
            service!.uuid = uuid
            service!.primary = primary
            let newSet = NSMutableOrderedSet( capacity: buildCharacteristics.count  )
            for buildCharacteristic in buildCharacteristics {
//                if buildCharacteristic.characteristic != nil {
                    Log.debug("  Found existing Characteristic managed object")
                    buildCharacteristic.prepareToSave( managedObjectContext )
                    newSet.addObject( buildCharacteristic.characteristic! )
//                } else {
//                    let characteristicEntity = NSEntityDescription.entityForName("Characteristic", inManagedObjectContext: managedObjectContext)
//                    if let newCharacteristic = NSManagedObject(entity: characteristicEntity!, insertIntoManagedObjectContext: managedObjectContext) as? Characteristic {
//                        Log.debug("  Made new Characteristic managed object")
//                        buildCharacteristic.prepareToSave( newCharacteristic )
//                        newSet.addObject( newCharacteristic )
//                    }
//                }

                
//                if buildCharacteristic.characteristic != nil {
//                    buildCharacteristic.save( buildCharacteristic.characteristic! )
//                } else {
//                    let characteristicEntity = NSEntityDescription.entityForName("Characteristic", inManagedObjectContext: managedObjectContext)
//                    if let newCharacteristic = NSManagedObject(entity: characteristicEntity!, insertIntoManagedObjectContext: managedObjectContext) as? Characteristic {
//                        Log.debug("  Made new Characteristic managed object")
//                        buildCharacteristic.save( newCharacteristic )
//                        // WFS Characteristic setup
//                    }
//                }
//                newSet.addObject( buildCharacteristic )
            }
            service!.characteristics = newSet
        }
    }
    
    func appendCharacteristic( buildCharacteristic: BuildCharacteristic ) {
        
        for bCharacteristic in buildCharacteristics {
            if bCharacteristic.characteristic == buildCharacteristic.characteristic {
                return
            }
        }
        buildCharacteristics.append( buildCharacteristic )
        
    }

    func setupCell( cell: ServicesCollectionViewCell ) {
        
        cell.nameLabel.text = name
        cell.uuidLabel.text = uuid
        cell.primaryLabel.text = (primary ? "Primary" : "")
        switch ( buildCharacteristics.count ) {
        case 0:
            cell.characteristicsLabel.text = "No Characteristics"
        case 1:
            cell.characteristicsLabel.text = "1 Characteristic"
        default:
            cell.characteristicsLabel.text = "\(buildCharacteristics.count) Characteristics"
        }
        cell.subservicesLabel.text = "No Sub-Services"
        
        cell.setupButton()
        
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
    
    func removeCharacteristicAtIndex( row: Int ) {
        
        buildCharacteristics.removeAtIndex( row )
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
        guard service!.primary == primary else { return true }
        guard service!.characteristics?.count == buildCharacteristics.count else { return true }
        for buildCharacteristic in buildCharacteristics {
            if buildCharacteristic.hasChanged() { return true }
        }
        
        return false
    }
    
}
