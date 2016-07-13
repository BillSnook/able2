//
//  BuildCharacteristic.swift
//  able2
//
//  Created by Bill Snook on 6/11/16.
//  Copyright © 2016 William Snook. All rights reserved.
//

import Foundation
import UIKit
import CoreBluetooth

/*
public struct CBCharacteristicProperties : OptionSetType {
    public init(rawValue: UInt)
    
    public static var Broadcast: CBCharacteristicProperties { get }
    public static var Read: CBCharacteristicProperties { get }
    public static var WriteWithoutResponse: CBCharacteristicProperties { get }
    public static var Write: CBCharacteristicProperties { get }
    public static var Notify: CBCharacteristicProperties { get }
    public static var Indicate: CBCharacteristicProperties { get }
    public static var AuthenticatedSignedWrites: CBCharacteristicProperties { get }
    public static var ExtendedProperties: CBCharacteristicProperties { get }
    @available(iOS 6.0, *)
    public static var NotifyEncryptionRequired: CBCharacteristicProperties { get }
    @available(iOS 6.0, *)
    public static var IndicateEncryptionRequired: CBCharacteristicProperties { get }
}
*/
/*
public struct CBAttributePermissions : OptionSetType {
    public init(rawValue: UInt)
    
    public static var Readable: CBAttributePermissions { get }
    public static var Writeable: CBAttributePermissions { get }
    public static var ReadEncryptionRequired: CBAttributePermissions { get }
    public static var WriteEncryptionRequired: CBAttributePermissions { get }
}
*/


class BuildCharacteristic: NSObject, UITextViewDelegate {

    var characteristic: Characteristic?
    var value: NSData?
    var uuid: String?
    var properties: CBCharacteristicProperties?
    var permissions: CBAttributePermissions?
    var index = 0
    
    weak var cell: CharacteristicsCollectionViewCell?
    
    
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
    
    func save( toCharacteristic: Characteristic? ) {
        
        if toCharacteristic != nil {
            characteristic = toCharacteristic
        }
        characteristic!.uuid = uuid
        characteristic!.value = value
        characteristic!.permissions = NSNumber( unsignedInteger: permissions!.rawValue )
        characteristic!.properties = NSNumber( unsignedInteger: properties!.rawValue )

    }
    
    func cellToPermissions() -> NSNumber? {
        
        permissions = CBAttributePermissions()
        if let safeCell = cell {
            if safeCell.permReadSwitch.on {
                permissions!.insert( .Readable )
            }
            if safeCell.permWriteSwitch.on {
                permissions!.insert( .Writeable )
            }
            if safeCell.permReadWithEncryptionSwitch.on {
                permissions!.insert( .ReadEncryptionRequired )
            }
            if safeCell.permWriteWithEncryptionSwitch.on {
                permissions!.insert( .WriteEncryptionRequired )
            }
            return NSNumber( unsignedInteger: permissions!.rawValue )
        } else {
            return nil
        }
    }

    func cellToProperties() -> NSNumber? {
        
        properties = CBCharacteristicProperties()
        if let safeCell = cell {
            if safeCell.propReadSwitch.on {
                properties!.insert( .Read )
            }
            if safeCell.propWriteSwitch.on {
                properties!.insert( .WriteWithoutResponse )
            }
            if safeCell.propAuthenticateSwitch.on {
                properties!.insert( .AuthenticatedSignedWrites )
            }
            if safeCell.propWriteWithResponseSwitch.on {
                properties!.insert( .Write )
            }
            if safeCell.propNotifySwitch.on {
                properties!.insert( .Notify )
            }
            if safeCell.propIndicateSwitch.on {
                properties!.insert( .Indicate )
            }
            if safeCell.propNotifyWithEncryptionSwitch.on {
                properties!.insert( .NotifyEncryptionRequired )
            }
            if safeCell.propIndicateWithEncryptionSwitch.on {
                properties!.insert( .IndicateEncryptionRequired )
            }
            return NSNumber( unsignedInteger: properties!.rawValue )
        } else {
            return nil
        }
    }
    
    func enabled( enabled: Bool ) {
        
        if let safeCell = cell {
            safeCell.uuidField.enabled = enabled
            safeCell.uuidButton.enabled = enabled
            safeCell.valueTextView.editable = enabled

            safeCell.permReadSwitch.enabled = enabled
            safeCell.permWriteSwitch.enabled = enabled
            safeCell.permReadWithEncryptionSwitch.enabled = enabled
            safeCell.permWriteWithEncryptionSwitch.enabled = enabled

            safeCell.propReadSwitch.enabled = enabled
            safeCell.propWriteSwitch.enabled = enabled
            safeCell.propAuthenticateSwitch.enabled = enabled
            safeCell.propWriteWithResponseSwitch.enabled = enabled
            safeCell.propNotifySwitch.enabled = enabled
            safeCell.propIndicateSwitch.enabled = enabled
            safeCell.propNotifyWithEncryptionSwitch.enabled = enabled
            safeCell.propIndicateWithEncryptionSwitch.enabled = enabled
        }
    }
    
    func stateDidChange( forCell cell: CharacteristicsCollectionViewCell? ) {

        if cell != nil {
            uuid = cell!.uuidField.text
            let nsString = cell!.valueTextView.text as NSString
            value = nsString.dataUsingEncoding(NSUTF8StringEncoding)!
            // WFS Characteristic setup
            if cell != nil {
                permissions = CBAttributePermissions( rawValue: cellToPermissions()!.unsignedIntegerValue )
                properties = CBCharacteristicProperties( rawValue: cellToProperties()!.unsignedIntegerValue )
            } else {
                Log.info( "cell is nil" )
            }
        }

    }
    
    func setupCell( cell : CharacteristicsCollectionViewCell ) {

        cell.uuidField.text = uuid
        cell.uuidField.inputView = UIView.init( frame: CGRectZero );    // No keyboard
        cell.textFieldBorderSetup(cell.uuidField)
        
        if let valueData = value {
            let nsString = NSString(data: valueData, encoding: NSUTF8StringEncoding)!
            cell.valueTextView.text = nsString as String
        } else {
            cell.valueTextView.text = ""
        }
        cell.valueTextView.delegate = self

        cell.permReadSwitch.on = permissions!.contains( .Readable )
        cell.permWriteSwitch.on = permissions!.contains( .Writeable )
        cell.permReadWithEncryptionSwitch.on = permissions!.contains( .ReadEncryptionRequired )
        cell.permWriteWithEncryptionSwitch.on = permissions!.contains( .WriteEncryptionRequired )
        
        cell.propReadSwitch.on = properties!.contains( .Read )
        cell.propWriteSwitch.on = properties!.contains( .WriteWithoutResponse )
        cell.propAuthenticateSwitch.on = properties!.contains( .AuthenticatedSignedWrites )
        cell.propWriteWithResponseSwitch.on = properties!.contains( .Write )
        cell.propNotifySwitch.on = properties!.contains( .Notify)
        cell.propIndicateSwitch.on = properties!.contains( .Indicate )
        cell.propNotifyWithEncryptionSwitch.on = properties!.contains( .NotifyEncryptionRequired )
        cell.propIndicateWithEncryptionSwitch.on = properties!.contains( .IndicateEncryptionRequired )
        
        if let displayValue = value {
            let nsString = NSString(data: displayValue, encoding: NSUTF8StringEncoding)!
            cell.valueTextView.text = nsString as String
        } else {
            cell.valueTextView.text = ""
        }
        cell.valueTextView.delegate = self
        self.cell = cell
        
//        cell.delegate = self
    }

    // MARK: - Text Input support
    
    func setBorderOf( textView: (UITextView), toDisplayState: (DisplayState) ) {
        
        textView.layer.borderWidth = 0.5
        textView.layer.cornerRadius = 6.0
        switch toDisplayState {
        case .Neutral:
            textView.layer.borderColor = UIColor.lightGrayColor().CGColor
        case .Valid:
            textView.layer.borderColor = UIColor.greenColor().CGColor
        case .Invalid:
            textView.layer.borderColor = UIColor.redColor().CGColor
        }
        
    }

    // MARK: - UITextViewDelegate - uuidField
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        
        var displayState = DisplayState.Neutral
        if let viewText = textView.text {
//            Log.info( "\ntext: \(text), length: \(text.characters.count)" )
//            Log.info( "range location: \(range.location), length: \(range.length)" )
//            Log.info( "string: \(string), length: \(string.characters.count)" )
            let nonEmptyText = !viewText.isEmpty && ( range.length != viewText.characters.count )
            let nonEmptyReplacement = !text.isEmpty
            if nonEmptyReplacement || nonEmptyText {
                displayState = .Valid
            }
        }
        setBorderOf( textView, toDisplayState: displayState )
//        performSelector( #selector( stateDidChange(_:)), withObject: cell, afterDelay: 0.1 )
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.1 * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), {
            self.stateDidChange( forCell: self.cell )
        })
        return true
    }
    
    func textViewDidEndEditing(textView: (UITextView)) {
        
//        textFieldBorderSetup( textField )
        let nsString = textView.text as NSString
        value = nsString.dataUsingEncoding(NSUTF8StringEncoding)!
        stateDidChange( forCell: cell )
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
        Log.info( "properties rawValue: \(properties?.rawValue), properties unsignedIntegerValue: \(characteristic!.properties!.unsignedIntegerValue)" )
        guard characteristic!.properties!.unsignedIntegerValue == properties!.rawValue else { Log.info("properties mismatch"); return true }
        guard characteristic!.permissions!.unsignedIntegerValue == permissions!.rawValue else { Log.info("permissions mismatch"); return true }
       
        return false
    }
    
}
