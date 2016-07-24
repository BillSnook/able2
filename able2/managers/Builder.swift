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
    case Unknown        // Not known, no device selected
    case Invalid        // Device has been selected but not all data is present or valid
    case Unsaved        // Data is valid and saveable but not saved
    case Saved          // Data is currently saved and usable
    case Advertising    // Data is curently being advertised
}


class Builder {
    
    static let sharedBuilder = Builder()

    let managedObjectContext: NSManagedObjectContext
    
    var currentDevice: BuildDevice?

    var buildState = BuildState.Unknown
    
    
    
    init() {
        
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        managedObjectContext = appDelegate.managedObjectContext
    }

    func getDeviceList() -> [BuildDevice]? {
        
//        Log.debug("")
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
    
    func saveDevice() {
        
        guard currentDevice != nil else { return }
        Log.debug("currentDevice name: \(currentDevice!.name)")
        currentDevice!.save( managedObjectContext )
        save()
        
    }
    
    func saveService( buildService: BuildService ) {
        
        Log.debug("buildService name: \(buildService.name)")
        guard currentDevice != nil else { return }
        currentDevice!.appendService( buildService )
        saveDevice()
//        currentDevice!.save( managedObjectContext )
//        save()
        
    }
    
    func deleteDevice( buildDevice: BuildDevice ) {
        
        Log.debug("")
        guard buildDevice.device != nil else { return }
        managedObjectContext.deleteObject( buildDevice.device! )
        save()
        buildDevice.device = nil
    }
    
    func deleteService( buildService: BuildService ) {
        
        Log.debug("")
        guard buildService.service != nil else { return }
        managedObjectContext.deleteObject( buildService.service! )
        save()
        buildService.service = nil
    }
    
    
}