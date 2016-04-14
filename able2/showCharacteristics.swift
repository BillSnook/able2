//
//  showCharacteristics.swift
//  able2
//
//  Created by William Snook on 4/13/16.
//  Copyright © 2016 William Snook. All rights reserved.
//

import Foundation
import UIKit
import CoreBluetooth


class ShowCharacteristics: UIViewController {
    
    
    var peripheral: CBPeripheral?
    var characteristic: CBCharacteristic?
    
    var serviceIndex = 0
    var characteristicsIndex = 0
    
    var outputString = ""
    
    @IBOutlet weak var textLabel: UILabel!
    
    
    //--	----	----	----	----	----	----	----
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let perp = peripheral {
            if let name = perp.name {
                let betterName = cleanName( name )
                navigationItem.title = betterName
            } else {
                navigationItem.title = "Missing Name"
            }
        } else {
            navigationItem.title = "Missing Peripheral"
        }
        
//        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate

        textLabel.text = "Test"
        
        outputString = ""
        
        if let perp = peripheral {
            if let services = perp.services {
                if serviceIndex < services.count  {
                    if let characteristics = services[serviceIndex].characteristics {
                        if characteristicsIndex < characteristics.count {
                            characteristic = characteristics[characteristicsIndex]
                            if let char = characteristic {
                                outputString += "Properties:\n"
                                let properties = char.properties
                                let rawProperties = properties.rawValue
                                if ( CBCharacteristicProperties.Broadcast.rawValue & rawProperties ) != 0 {
                                    outputString += "  Broadcast\n"
                                }
                                if ( CBCharacteristicProperties.Read.rawValue & rawProperties ) != 0 {
                                    outputString += "  Read\n"
                                }
                                if ( CBCharacteristicProperties.WriteWithoutResponse.rawValue & rawProperties ) != 0 {
                                    outputString += "  WriteWithoutResponse\n"
                                }
                                if ( CBCharacteristicProperties.Write.rawValue & rawProperties ) != 0 {
                                    outputString += "  Write\n"
                                }
                                if ( CBCharacteristicProperties.Notify.rawValue & rawProperties ) != 0 {
                                    outputString += "  Notify\n"
                                }
                                if ( CBCharacteristicProperties.Indicate.rawValue & rawProperties ) != 0 {
                                    outputString += "  Indicate\n"
                                }
                                if ( CBCharacteristicProperties.AuthenticatedSignedWrites.rawValue & rawProperties ) != 0 {
                                    outputString += "  AuthenticatedSignedWrites\n"
                                }
                                if ( CBCharacteristicProperties.ExtendedProperties.rawValue & rawProperties ) != 0 {
                                    outputString += "  ExtendedProperties\n"
                                }
                                
                            }

                            
                        }
                    }
                }
            }
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear( animated )
        
        textLabel.text = outputString
    }
    
    override func viewWillDisappear(animated: Bool) {
        
        super.viewWillDisappear( animated )
    }
    

    
    
    
}
