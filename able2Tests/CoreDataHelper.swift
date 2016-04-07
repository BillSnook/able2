//
//  CoreDataHelper.swift
//  able2
//
//  Created by William Snook on 4/6/16.
//  Copyright © 2016 William Snook. All rights reserved.
//

import Foundation
import CoreData

@testable import able2


// To test CoreData, it helps to use the InMemoryStore type as it avoids some overhead from using SQLite as the store.
func setUpInMemoryManagedObjectContext() -> NSManagedObjectContext {
    let managedObjectModel = NSManagedObjectModel.mergedModelFromBundles([NSBundle.mainBundle()])!
    let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
    
    do {
        try persistentStoreCoordinator.addPersistentStoreWithType(NSInMemoryStoreType, configuration: nil, URL: nil, options: nil)
    } catch {
        print("Adding in-memory persistent store failed")
    }
    
    let managedContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
    managedContext.persistentStoreCoordinator = persistentStoreCoordinator
    
    return managedContext
}

func deleteAllPeripherals( managedContext: NSManagedObjectContext ) {
    let perpRequest = NSFetchRequest()
    if let entity = NSEntityDescription.entityForName( "Peripheral", inManagedObjectContext: managedContext ) {
        perpRequest.entity = entity
        perpRequest.includesPropertyValues = false
        do {
            let perps: NSArray = try managedContext.executeFetchRequest( perpRequest )
            for perp in perps as! [Peripheral] {
                managedContext.deleteObject( perp )
            }
            try managedContext.save()
        } catch let error as NSError {
            print( "Error while fetching or saving batch: \(error)" )
        }
    } else {
        print( "Failed to get entity in deleteAllPeripherals" )
    }
}
