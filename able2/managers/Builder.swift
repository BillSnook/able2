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
    case unknown        // Not known, no device selected
    case invalid        // Device has been selected but not all data is present or valid
    case unsaved        // Data is valid and saveable but not saved
    case saved          // Data is currently saved and usable
    case advertising    // Data is curently being advertised
}


class Builder {
    
    static let sharedBuilder = Builder()

    let managedObjectContext: NSManagedObjectContext
    
    var currentDevice: BuildDevice?
    
    var currentService: BuildService?
    
    var buildState = BuildState.unknown
    
    
    
    init() {
        
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        managedObjectContext = appDelegate.managedObjectContext
    }

    func getDeviceList() -> [BuildDevice]? {
        
//        Log.debug("")
        let fetch = NSFetchRequest<NSFetchRequestResult>( entityName: "Device" )
        do {
            let results = try managedObjectContext.fetch( fetch )
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

    fileprivate func save() {
        
        guard buildState != .saved else { return }
        do {
            try managedObjectContext.save()
            buildState = .saved
        } catch let error as NSError {
            Log.error("Could not save \(error), \(error.userInfo)")
        }
        catch {
            Log.error("Could not save \(error)")
        }

    }
    
    func saveDevice() {
        
        Log.debug("currentDevice name: \(currentDevice!.name)")
        guard currentDevice != nil else { return }
        currentDevice!.prepareToSave( managedObjectContext )
        save()
        
    }
    
    func saveService( _ buildService: BuildService ) {
        
        Log.debug("buildService name: \(buildService.name)")
        guard currentDevice != nil else { return }
        currentDevice!.appendService( buildService )
        saveDevice()
//        currentDevice!.save( managedObjectContext )
//        save()
        
    }
    
    func saveCharacteristic( _ buildCharacteristic: BuildCharacteristic ) {
        
        Log.debug("buildCharacteristic uuid: \(buildCharacteristic.uuid)")
        guard currentService != nil else { return }
        currentService!.appendCharacteristic( buildCharacteristic )
        saveService( currentService! )
//        currentDevice!.save( managedObjectContext )
//        save()
        
    }
    
    func deleteDevice( _ buildDevice: BuildDevice ) {
        
        Log.debug("")
        guard buildDevice.device != nil else { return }
        managedObjectContext.delete( buildDevice.device! )
        save()
        buildDevice.device = nil
    }
    
    func deleteService( _ buildService: BuildService ) {
        
        Log.debug("")
        guard buildService.service != nil else { return }
        managedObjectContext.delete( buildService.service! )
        save()
        buildService.service = nil
    }
    
    
}
