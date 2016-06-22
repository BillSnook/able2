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
    
    
    init() {
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        managedObjectContext = appDelegate.managedObjectContext
    }
    
    func getList() -> [BuildService]? {

        let fetch = NSFetchRequest( entityName: "Service" )
        do {
            let results = try managedObjectContext.executeFetchRequest( fetch )
            var buildServices = [BuildService]()
            for service in results as! [Service] {
                let buildService = BuildService( fromService: service )
                buildServices.append( buildService )
            }
            return buildServices
            
        } catch let error as NSError {
            Log.error("Could not fetch \(error), \(error.userInfo)")
        }
        catch {
            Log.error("Could not fetch \(error)")
        }
        return nil
    }
    
    func delete( buildService: BuildService ) {
        
        guard buildService.service != nil else { return }
        managedObjectContext.deleteObject( buildService.service! )
        do {
            try managedObjectContext.save()
        } catch let error as NSError {
            Log.error("Could not fetch \(error), \(error.userInfo)")
        }
        catch {
            Log.error("Could not fetch \(error)")
        }
        buildService.service = nil
    }
    
    func save( buildService: BuildService ) {
        
        buildService.save( managedObjectContext )

    }

}