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
    
    func characteristicRead( characteristic: CBCharacteristic )
    
    func descriptorsRead( characteristic: CBCharacteristic )
}


class Characterizer: Interrogator {
    
    static let sharedCharacterizer = Characterizer()

    var characteristicDelegate: CharacteristicProtocol?
    
    var connectedPeripheral: CBPeripheral?
    
    var connectedCharacteristic: CBCharacteristic?
    
    
    required init() {
        
        super.init()

        Log.trace( "Characterizer init" )
        
    }
    
    func startCharacteristicEvaluation( characteristic: CBCharacteristic, forPeripheral peripheral: CBPeripheral ) {
        Log.trace( "Characterizer startCharacteristicEvaluation" )
        
        peripheral.delegate = self
        if ( .PoweredOn == cbManager.state ) {
            peripheral.discoverDescriptorsForCharacteristic( characteristic )
//            peripheral.readValueForCharacteristic( characteristic )
            Log.info( "characteristic methods called" )
        } else {
            connectedPeripheral = peripheral
            connectedCharacteristic = characteristic
            Log.info( "characteristic methods deferred" )
        }
    }
    

    override func centralManagerDidUpdateState(central: CBCentralManager) {
        var state = ""
        switch ( central.state ) {
        case .Unknown:
            state = "Currently in an unknown state."
        case .Resetting:
            state = "Central Manager is resetting."
        case .Unsupported:
            state = "No support for Bluetooth Low Energy."
        case .Unauthorized:
            state = "Not authorized to use Bluetooth Low Energy."
        case .PoweredOff:
            state = "Currently powered off."
        case .PoweredOn:
            state = "Currently powered on."
        }
        Log.info( "Characterizer Bluetooth central state: \(state)" )
        
        if (central.state != .PoweredOn) {		// In a real app, you'd deal with all the states correctly
            //            resetScanList()
            return
        }
        // The state must be CBCentralManagerStatePoweredOn...
        // ... so start scanning
//        self.startScan( forDevices: deviceUUIDs! )
        if let characteristic = connectedCharacteristic {
            connectedPeripheral?.discoverDescriptorsForCharacteristic( characteristic )
            Log.info( "readCharacteristic called finally" )
        }
        
    }
    
    func peripheral(peripheral: CBPeripheral, didDiscoverDescriptorsForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        
        Log.info( "didDiscoverDescriptorsForCharacteristic" )
        characteristicDelegate?.descriptorsRead( characteristic )
        peripheral.readValueForCharacteristic( characteristic )
    }
    
    func peripheral(peripheral: CBPeripheral, didUpdateValueForCharacteristic characteristic: CBCharacteristic, error: NSError?) {
        
        Log.info( "didUpdateValueForCharacteristic" )
        characteristicDelegate?.characteristicRead( characteristic )
//        connectedCharacteristic = nil
//        connectedPeripheral = nil
    }
    
}