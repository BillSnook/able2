//
//  BuildCharacteristic.swift
//  able2
//
//  Created by Bill Snook on 6/11/16.
//  Copyright © 2016 William Snook. All rights reserved.
//

import Foundation
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


class BuildCharacteristic: NSObject {

//    var characteristic: Characteristic?
    var value: NSData?
    var uuid: String?
    var properties: CBCharacteristicProperties?
    var permissions: CBAttributePermissions?
    var index = 0
    
//    var primary: Bool?
    
    init( fromCharacteristic: Characteristic? ) {
        
        if fromCharacteristic != nil {
//            characteristic = fromCharacteristic
            uuid = fromCharacteristic!.uuid
//            value = characteristic!.value
//            primary = characteristic!.primary?.boolValue
        } else {
//            characteristic = nil
            uuid = ""
            value = nil
            properties = CBCharacteristicProperties()
            permissions = CBAttributePermissions()
        }
    }

}
