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


protocol CellStateChangeProtocol {
    
    func stateDidChange( forCell cell: CharacteristicsCollectionViewCell? )
}


class BuildCharacteristic: NSObject, CellStateChangeProtocol, UITextViewDelegate {

//    var characteristic: Characteristic?
    var value: NSData?
    var uuid: String?
    var properties: CBCharacteristicProperties?
    var permissions: CBAttributePermissions?
    var index = 0
    
    var cell: CharacteristicsCollectionViewCell?
    
//    var primary: Bool?
    
    init( fromCharacteristic: Characteristic? ) {
        
        if fromCharacteristic != nil {
//            characteristic = fromCharacteristic
            uuid = fromCharacteristic!.uuid
            value = fromCharacteristic!.value
//            primary = fromCharacteristic!.primary?.boolValue
        } else {
//            characteristic = nil
            uuid = ""
            value = nil
            properties = CBCharacteristicProperties()
            permissions = CBAttributePermissions()
        }
    }

    func stateDidChange( forCell cell: CharacteristicsCollectionViewCell? ) {

        if cell != nil {
            uuid = cell!.uuidField.text
            let nsString = cell!.valueTextView.text as NSString
            value = nsString.dataUsingEncoding(NSUTF8StringEncoding)!
        }
        
//        modified = true

        NSNotificationCenter.defaultCenter().postNotificationName( kCharacteristicChangedKey, object: nil )
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
//            print( "\ntext: \(text), length: \(text.characters.count)" )
//            print( "range location: \(range.location), length: \(range.length)" )
//            print( "string: \(string), length: \(string.characters.count)" )
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
//        modified = true
    }
    
}
