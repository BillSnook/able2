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
        
//        DLog.debug("")
        let fetch: NSFetchRequest<Device> = NSFetchRequest( entityName: "Device" )
        do {
            let results = try managedObjectContext.fetch( fetch )
            var buildDevices = [BuildDevice]()
            for device in results {
                let buildDevice = BuildDevice( fromDevice: device )
                buildDevices.append( buildDevice )
            }
            return buildDevices
            
        } catch let error as NSError {
            DLog.error("Could not fetch \(error), \(error.userInfo)")
        }
        catch {
            DLog.error("Could not fetch \(error)")
        }
        return nil
    }

    fileprivate func save() {
        
        guard buildState != .saved else { return }
        do {
            try managedObjectContext.save()
            buildState = .saved
        } catch let error as NSError {
            DLog.error("Could not save \(error), \(error.userInfo)")
        }
        catch {
            DLog.error("Could not save \(error)")
        }

    }
    
    func saveDevice() {
        
        DLog.debug("currentDevice name: \(currentDevice!.name)")
        guard currentDevice != nil else { return }
        currentDevice!.prepareToSave()
        save()
        
    }
    
    func saveService( _ buildService: BuildService ) {
        
        DLog.debug("buildService name: \(buildService.name)")
        guard currentDevice != nil else { return }
        currentDevice!.appendService( buildService )
        saveDevice()
        
    }
    
    func saveCharacteristic( _ buildCharacteristic: BuildCharacteristic ) {
        
        DLog.debug("buildCharacteristic uuid: \(buildCharacteristic.uuid)")
        guard currentService != nil else { return }
        currentService!.appendCharacteristic( buildCharacteristic )
        saveService( currentService! )
        
    }
    
    func deleteDevice( _ buildDevice: BuildDevice ) {
        
        DLog.debug("")
        guard buildDevice.device != nil else { return }
        managedObjectContext.delete( buildDevice.device! )
        save()
        buildDevice.device = nil
    }
    
    func deleteService( _ buildService: BuildService ) {
        
        DLog.debug("")
        guard buildService.service != nil else { return }
        managedObjectContext.delete( buildService.service! )
        save()
        buildService.service = nil
    }
    
    
}
