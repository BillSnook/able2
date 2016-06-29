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

    func getDeviceList() -> [BuildDevice]? {
        
        let fetch = NSFetchRequest( entityName: "Device" )
        do {
            let results = try managedObjectContext.executeFetchRequest( fetch )
            var buildDevices = [BuildDevice]()
            for device in results as! [Device] {
                let buildDevice = BuildDevice( fromDevice: device )
                buildDevices.append( buildDevice )
            }
            return buildDevices
            
        } catch let error as NSError {
            Log.error("Could not fetch \(error), \(error.userInfo)")
        }
        catch {
            Log.error("Could not fetch \(error)")
        }
        return nil
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
    
    func saveDevice( buildDevice: BuildDevice ) {
        
        buildDevice.save( managedObjectContext )
        
    }
    
    func save( buildService: BuildService ) {
        
        buildService.save( managedObjectContext )
        
    }
    
    func deleteDevice( buildDevice: BuildDevice ) {
        
        guard buildDevice.device != nil else { return }
        managedObjectContext.deleteObject( buildDevice.device! )
        do {
            try managedObjectContext.save()
        } catch let error as NSError {
            Log.error("Could not fetch \(error), \(error.userInfo)")
        }
        catch {
            Log.error("Could not fetch \(error)")
        }
        buildDevice.device = nil
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
    
}