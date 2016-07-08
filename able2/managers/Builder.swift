//
//  Builder.swift
//  able2
//
//  Created by William Snook on 6/7/16.
//  Copyright © 2016 William Snook. All rights reserved.
//

import UIKit
import CoreData


enum BuildState {
    case Empty
    case Unsaved
    case Saved
    case Advertising
}


class Builder {
    
    static let sharedBuilder = Builder()

    let managedObjectContext: NSManagedObjectContext
    
    var currentDevice: BuildDevice?

    var buildState = BuildState.Empty
    
    
    
    init() {
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        managedObjectContext = appDelegate.managedObjectContext
    }

    func getDeviceList() -> [BuildDevice]? {
        
        Log.debug("Builder getDeviceList")
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

    private func save() {
        
        guard buildState != .Saved else { return }
        do {
            try managedObjectContext.save()
            buildState = .Saved
        } catch let error as NSError {
            Log.error("Could not fetch \(error), \(error.userInfo)")
        }
        catch {
            Log.error("Could not fetch \(error)")
        }

    }
    
    func saveDevice( buildDevice: BuildDevice ) {
        
        Log.debug("Builder saveDevice: \(buildDevice.name)")
        buildDevice.save( managedObjectContext )
        save()
        
    }
    
    func saveService( buildService: BuildService ) {
        
        Log.debug("Builder saveService: \(buildService.name)")
        guard currentDevice != nil else { return }
        currentDevice!.appendService( buildService )
        currentDevice!.save( managedObjectContext )
        save()
        
    }
    
    func deleteDevice( buildDevice: BuildDevice ) {
        
        Log.debug("Builder deleteDevice")
        guard buildDevice.device != nil else { return }
        managedObjectContext.deleteObject( buildDevice.device! )
        save()
        buildDevice.device = nil
    }
    
    func deleteService( buildService: BuildService ) {
        
        Log.debug("Builder deleteService")
        guard buildService.service != nil else { return }
        managedObjectContext.deleteObject( buildService.service! )
        save()
        buildService.service = nil
    }
    
    
}