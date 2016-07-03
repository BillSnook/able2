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
//	var characteristics: Set<Characteristic>?
    var buildCharacteristics: Array<BuildCharacteristic>
	
	init( fromService: Service? ) {
		
		if fromService != nil {
			service = fromService
			name = service!.name
			uuid = service!.uuid
            Log.debug("BuildService init from existing Service managed object: \(name)")
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
            Log.debug("BuildService init from nil")
			service = nil
			name = ""
			uuid = ""
			primary = true
			buildCharacteristics = []
		}
	}
    
    func save( managedObjectContext: NSManagedObjectContext ) {

        Log.debug("BuildService save method")
        if service != nil {
            service!.name = name
            service!.uuid = uuid
            service!.primary = primary
        } else {
            let serviceEntity = NSEntityDescription.entityForName("Service", inManagedObjectContext: managedObjectContext)
            if serviceEntity != nil {
                if let newService = NSManagedObject(entity: serviceEntity!, insertIntoManagedObjectContext: managedObjectContext) as? Service {
                    Log.debug("  Made new Service managed object")
                    service = newService
                    newService.name = name
                    newService.uuid = uuid
                    newService.primary = primary
                }
            }
        }
        if service != nil {
            let newSet = NSMutableOrderedSet( capacity: buildCharacteristics.count  )
            for buildCharacteristic in buildCharacteristics {
                let characteristicEntity = NSEntityDescription.entityForName("Characteristic", inManagedObjectContext: managedObjectContext)
                if let newCharacteristic = NSManagedObject(entity: characteristicEntity!, insertIntoManagedObjectContext: managedObjectContext) as? Characteristic {
                    Log.debug("  Made new Characteristic managed object")
                    buildCharacteristic.save( newCharacteristic )
                    // WFS Characteristic setup
                    newSet.addObject( newCharacteristic )
                }
            }
            service!.characteristics = newSet
        }
        if service != nil {
            do {
                try managedObjectContext.save()
                Log.debug("  Saved managed object(s)")
            } catch let error as NSError {
                Log.error("  Could not fetch \(error), \(error.userInfo)")
            }
            catch {
                Log.error("  Could not fetch \(error)")
            }
        }
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
    }
    
    func toBluetooth() -> CBMutableService {
        
        let mutableService = CBMutableService( type: CBUUID(string: uuid!), primary: primary )
        var mutableCharacteristics = [CBMutableCharacteristic]()
        for buildCharacteristic in buildCharacteristics {

            let mutableCharacteristic = CBMutableCharacteristic( type: CBUUID(string: buildCharacteristic.uuid!), properties: buildCharacteristic.properties!, value: buildCharacteristic.value, permissions: buildCharacteristic.permissions! )
            mutableCharacteristics.append( mutableCharacteristic )
        }
        mutableService.characteristics = mutableCharacteristics
        return mutableService
    }
	
}
