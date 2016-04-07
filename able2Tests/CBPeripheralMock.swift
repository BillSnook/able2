//
//  CBPeripheralMock.swift
//  able2
//
//  Created by William Snook on 4/6/16.
//  Copyright © 2016 William Snook. All rights reserved.
//

import Foundation
import CoreBluetooth

@testable import able2


class CBPeripheralMock: CBPeripheralProtocol {
    
    private var n: String?
    private var i: NSUUID
    
    var name: String? {
        get {
            return self.n
        }
        set {
            self.n = newValue!
        }
    }
    
    var identifier: NSUUID {
        get {
            return self.i
        }
        set {
            self.i = newValue
        }
    }
    
    init( name: String, identifier: NSUUID ) {
//        super.init()
        self.n = name
        self.i = identifier
    }
}