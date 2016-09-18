//
//  Characterizer.swift
//  able2
//
//  Created by William Snook on 4/15/16.
//  Copyright © 2016 William Snook. All rights reserved.
//

import UIKit
import CoreBluetooth


protocol CharacteristicProtocol {
    
    func characteristicRead( _ characteristic: CBCharacteristic )
    
    func descriptorsRead( _ characteristic: CBCharacteristic )
}


class Characterizer: Interrogator {
    
    static let sharedCharacterizer = Characterizer()

    var characteristicDelegate: CharacteristicProtocol?
    
    var connectedPeripheral: CBPeripheral?
    
    var connectedCharacteristic: CBCharacteristic?
    
    
    required init() {
        
        super.init()

        DLog.trace( "Characterizer init" )
        
    }
    
    func startCharacteristicEvaluation( _ characteristic: CBCharacteristic, forPeripheral peripheral: CBPeripheral ) {
        DLog.trace( "Characterizer startCharacteristicEvaluation" )
        
        peripheral.delegate = self
        if ( .poweredOn == cbManager.state ) {
            peripheral.discoverDescriptors( for: characteristic )
//            peripheral.readValueForCharacteristic( characteristic )
            DLog.info( "characteristic methods called" )
        } else {
            connectedPeripheral = peripheral
            connectedCharacteristic = characteristic
            DLog.info( "characteristic methods deferred" )
        }
    }
    

    override func centralManagerDidUpdateState(_ central: CBCentralManager) {
        var state = ""
        switch ( central.state ) {
        case .unknown:
            state = "Currently in an unknown state."
        case .resetting:
            state = "Central Manager is resetting."
        case .unsupported:
            state = "No support for Bluetooth Low Energy."
        case .unauthorized:
            state = "Not authorized to use Bluetooth Low Energy."
        case .poweredOff:
            state = "Currently powered off."
        case .poweredOn:
            state = "Currently powered on."
        }
        DLog.info( "Characterizer Bluetooth central state: \(state)" )
        
        if (central.state != .poweredOn) {		// In a real app, you'd deal with all the states correctly
            //            resetScanList()
            return
        }
        // The state must be CBCentralManagerStatePoweredOn...
        // ... so start scanning
//        self.startScan( forDevices: deviceUUIDs! )
        if let characteristic = connectedCharacteristic {
            connectedPeripheral?.discoverDescriptors( for: characteristic )
            DLog.info( "readCharacteristic called finally" )
        }
        
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverDescriptorsForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        
        DLog.info( "didDiscoverDescriptorsForCharacteristic" )
        characteristicDelegate?.descriptorsRead( characteristic )
        peripheral.readValue( for: characteristic )
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        
        DLog.info( "didUpdateValueForCharacteristic" )
        characteristicDelegate?.characteristicRead( characteristic )
//        connectedCharacteristic = nil
//        connectedPeripheral = nil
    }
    
}
