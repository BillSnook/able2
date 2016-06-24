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
	var primary: Bool?
//	var characteristics: Set<Characteristic>?
    var buildCharacteristics: Array<BuildCharacteristic>
	
    weak var cell: ServicesCollectionViewCell?
    
	init( fromService: Service? ) {
		
		if fromService != nil {
			service = fromService
			name = service!.name
			uuid = service!.uuid
			primary = service!.primary?.boolValue
            let characteristics = service!.characteristics
            buildCharacteristics = []
            for characteristic in characteristics! {
                let buildCharacteristic = BuildCharacteristic( fromCharacteristic: characteristic as? Characteristic)
                buildCharacteristics.append( buildCharacteristic )
            }
        } else {
			service = nil
			name = ""
			uuid = ""
			primary = true
			buildCharacteristics = []
		}
    }
    
//    func save( toService service: Service? ) {
//        
//        if service != nil {
//            service?.name = name
//            service?.uuid = uuid
//            service?.primary = primary
//        } else {
//            
//        }
//    }
    
    func save( managedObjectContext: NSManagedObjectContext ) {
        
        if service != nil {
            service!.name = name
            service!.uuid = uuid
            service!.primary = primary
        } else {
            let serviceEntity = NSEntityDescription.entityForName("Service", inManagedObjectContext: managedObjectContext)
            if serviceEntity != nil {
                if let newService = NSManagedObject(entity: serviceEntity!, insertIntoManagedObjectContext: managedObjectContext) as? Service {
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
            } catch let error as NSError {
                Log.error("Could not fetch \(error), \(error.userInfo)")
            }
            catch {
                Log.error("Could not fetch \(error)")
            }
        }
    }
    
    func toBluetooth() -> CBMutableService {
        
        let mutableService = CBMutableService( type: CBUUID(string: uuid!), primary: primary! )
        var mutableCharacteristics = [CBMutableCharacteristic]()
        for buildCharacteristic in buildCharacteristics {

            let mutableCharacteristic = CBMutableCharacteristic( type: CBUUID(string: buildCharacteristic.uuid!), properties: buildCharacteristic.properties!, value: buildCharacteristic.value, permissions: buildCharacteristic.permissions! )
            mutableCharacteristics.append( mutableCharacteristic )
        }
        mutableService.characteristics = mutableCharacteristics
        return mutableService
    }
	
    func enabled( enabled: Bool ) {
        
        if let safeCell = cell {
            safeCell.nameField.enabled = enabled
            safeCell.uuidField.enabled = enabled
            safeCell.uuidButton.enabled = enabled
            safeCell.primarySwitch.enabled = enabled
            
        }
        for buildCharacteristic in buildCharacteristics {
            buildCharacteristic.enabled( enabled )
        }
    }

}
