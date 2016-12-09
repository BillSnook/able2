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
    let managedObjectModel = NSManagedObjectModel.mergedModel(from: [Bundle.main])!
//    let modelURL = NSBundle.mainBundle().URLForResource("able2", withExtension: "momd")!
//    let managedObjectModel =  NSManagedObjectModel(contentsOfURL: modelURL)!
    let persistentStoreCoordinator = NSPersistentStoreCoordinator(managedObjectModel: managedObjectModel)
    
    do {
        try persistentStoreCoordinator.addPersistentStore(ofType: NSInMemoryStoreType, configurationName: nil, at: nil, options: nil)
    } catch {
        Log.info("Adding in-memory persistent store failed")
    }
    
    let managedContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
    managedContext.persistentStoreCoordinator = persistentStoreCoordinator
    
    return managedContext
}

func deleteAllPeripherals( _ managedContext: NSManagedObjectContext ) {
    let perpRequest = NSFetchRequest()
    if let entity = NSEntityDescription.entity( forEntityName: "Peripheral", in: managedContext ) {
        perpRequest.entity = entity
        perpRequest.includesPropertyValues = false
        do {
            let perps: NSArray = try managedContext.fetch( perpRequest )
            for perp in perps as! [Peripheral] {
                managedContext.delete( perp )
            }
            try managedContext.save()
        } catch let error as NSError {
            Log.info( "Error while fetching or saving batch: \(error)" )
        }
    } else {
        Log.info( "Failed to get entity in deleteAllPeripherals" )
    }
}
