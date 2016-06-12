//
//  Builder.swift
//  able2
//
//  Created by William Snook on 6/7/16.
//  Copyright © 2016 William Snook. All rights reserved.
//

import UIKit
import CoreData


class Builder {
    
    static let sharedBuilder = Builder()

    var managedObjectContext: NSManagedObjectContext
    
    var serviceEntity: NSEntityDescription?
    var service: Service?
    var characteristics = [Characteristic]()
	
	var buildService: BuildService?
    
    init() {
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        managedObjectContext = appDelegate.managedObjectContext
    }
    
    func getList() -> [Service]? {
        
        let fetch = NSFetchRequest( entityName: "Service" )
        do {
            let results = try managedObjectContext.executeFetchRequest( fetch )
            return results as? [Service]
        } catch let error as NSError {
            Log.error("Could not fetch \(error), \(error.userInfo)")
        }
        catch {
            Log.error("Could not fetch \(error)")
        }
        
        serviceEntity = NSEntityDescription.entityForName("Service", inManagedObjectContext: managedObjectContext)
        if serviceEntity != nil {
            service = NSManagedObject(entity: serviceEntity!, insertIntoManagedObjectContext: managedObjectContext) as? Service
            return [service!]
        }
        return []
    }
    
    func save() {
        
        guard buildService != nil else { return }
		serviceEntity = NSEntityDescription.entityForName("Service", inManagedObjectContext: managedObjectContext)
		if serviceEntity != nil {
			let service = NSManagedObject(entity: serviceEntity!, insertIntoManagedObjectContext: managedObjectContext) as? Service
			service?.primary = buildService?.primary
		}
        do {
            try managedObjectContext.save()
        } catch let error as NSError {
            Log.error("Could not fetch \(error), \(error.userInfo)")
        }
        catch {
            Log.error("Could not fetch \(error)")
        }
    }

    func setupFromService( editService: Service? )-> BuildService? {

		var buildService = BuildService( fromService: service )
//        if editService == nil {
//            serviceEntity = NSEntityDescription.entityForName("Service", inManagedObjectContext: managedObjectContext)
//            if serviceEntity != nil {
//                service = NSManagedObject(entity: serviceEntity!, insertIntoManagedObjectContext: managedObjectContext) as? Service
//                service?.primary = true
//            }
//        }
		return buildService
    }
    
}