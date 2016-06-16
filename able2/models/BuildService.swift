//
//  BuildService.swift
//  able2
//
//  Created by Bill Snook on 6/11/16.
//  Copyright © 2016 William Snook. All rights reserved.
//

import Foundation
import CoreData

class BuildService {
	
	var service: Service?
	var name: String?
	var uuid: String?
	var primary: Bool?
//	var characteristics: Set<Characteristic>?
    var buildCharacteristics: Array<BuildCharacteristic>
	
	init( fromService: Service? ) {
		
		if fromService != nil {
			service = fromService
			name = service!.name
			uuid = service!.uuid
			primary = service!.primary?.boolValue

            print( "service name: \(name)" )

            let characteristics = service!.characteristics
            print( "characteristics count: \(characteristics?.count)" )
//        Log.trace("set count: \(characteristics!.count)" )
            buildCharacteristics = []
            for characteristic in characteristics! {
//                print( "characteristic: \(characteristic.description)" )
                let buildCharacteristic = BuildCharacteristic( fromCharacteristic: characteristic as? Characteristic)
                print( "buildCharacteristic: \(buildCharacteristic.description)" )
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
                    
                    // Characteristics
                }
            }
        }
        if service != nil {
            let newSet = NSMutableOrderedSet( capacity: buildCharacteristics.count  )
            for buildCharacteristic in buildCharacteristics {
                let characteristicEntity = NSEntityDescription.entityForName("Characteristic", inManagedObjectContext: managedObjectContext)
                if let newCharacteristic = NSManagedObject(entity: characteristicEntity!, insertIntoManagedObjectContext: managedObjectContext) as? Characteristic {
                    newCharacteristic.uuid = buildCharacteristic.uuid
                    newCharacteristic.value = buildCharacteristic.value
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
	
}
