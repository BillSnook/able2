//
//  BuildCharacteristic.swift
//  able2
//
//  Created by Bill Snook on 6/11/16.
//  Copyright © 2016 William Snook. All rights reserved.
//

import UIKit
import CoreData
import CoreBluetooth


class BuildCharacteristic: NSObject, UITextViewDelegate {

    var characteristic: Characteristic?
    var value: NSData?
    var uuid: String?
    var properties: CBCharacteristicProperties?
    var permissions: CBAttributePermissions?
    
    
    var valueString: String? {
        get {
            guard value != nil else { return nil }
            let vString = NSString(data: value!, encoding: NSUTF8StringEncoding )
            return vString as? String
        }
        set( newDataString ) {
            guard newDataString != nil else {
                value = nil;
                return
            }
            let valStr = newDataString!
            value = valStr.dataUsingEncoding( NSUTF8StringEncoding )
        }
    }
    
    
    init( fromCharacteristic: Characteristic? ) {
        
        if fromCharacteristic != nil {
            characteristic = fromCharacteristic
            uuid = fromCharacteristic!.uuid
            value = fromCharacteristic!.value
            permissions = CBAttributePermissions( rawValue: fromCharacteristic!.permissions!.unsignedIntegerValue )
            properties = CBCharacteristicProperties( rawValue: fromCharacteristic!.properties!.unsignedIntegerValue )
        } else {
            characteristic = nil
            uuid = ""
            value = nil
            permissions = CBAttributePermissions()
            properties = CBCharacteristicProperties()
        }
    }
    
    func prepareToSave( managedObjectContext: NSManagedObjectContext ) {
        
        Log.debug("")
        if characteristic == nil {
            let characteristicEntity = NSEntityDescription.entityForName("Characteristic", inManagedObjectContext: managedObjectContext)
            if characteristicEntity != nil {
                if let newCharacteristic = NSManagedObject(entity: characteristicEntity!, insertIntoManagedObjectContext: managedObjectContext) as? Characteristic {
                    Log.debug("  Made new Characteristic managed object")
                    characteristic = newCharacteristic
                }
            }
        }
        if characteristic != nil {
            characteristic!.uuid = uuid
            characteristic!.value = value
            characteristic!.permissions = NSNumber( unsignedInteger: permissions!.rawValue )
            characteristic!.properties = NSNumber( unsignedInteger: properties!.rawValue )
        }

    }

    func setupCell( cell : CharacteristicCollectionViewCell ) {

        cell.uuidLabel.text = uuid
        if let valueData = value {
            let nsString = NSString(data: valueData, encoding: NSUTF8StringEncoding)!
            cell.valueLabel.text = nsString as String
        } else {
            cell.valueLabel.text = ""
        }
        
        cell.setupButton()
    }
    
    func isValid() -> Bool {        // Valid indicates ready to be saved
        
        guard uuid != nil && !uuid!.isEmpty else { return false }
//        guard value != nil && value!.length > 0 else { return false }
        guard properties != nil else { return false }
        guard permissions != nil else { return false }
        
        return true
    }
    
    func hasChanged() -> Bool {     // Changed means data does not match characteristic
        
//        guard isValid() else { return true }
        guard characteristic != nil else { return true }
        guard characteristic!.uuid == uuid else { return true }
        guard characteristic!.value == value else { return true }
        guard characteristic!.properties!.unsignedIntegerValue == properties!.rawValue else { Log.info("properties mismatch"); return true }
        guard characteristic!.permissions!.unsignedIntegerValue == permissions!.rawValue else { Log.info("permissions mismatch"); return true }
       
        return false
    }
    
}
