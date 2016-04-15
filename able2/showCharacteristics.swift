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

    var peripheral: CBPeripheral?           // Three passed-in parameters to specify which
    var serviceIndex = 0                    // characteristic on which service
    var characteristicsIndex = 0            // on which CBPeripheral is specified
    
    var characteristic: CBCharacteristic?
    
    var outputString = ""
    
    @IBOutlet weak var textLabel: UILabel!
    
    let fontStyle = UIFontTextStyleHeadline

    
    //--	----	----	----	----	----	----	----
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        if let perp = peripheral {
//            if let name = perp.name {
//                let betterName = cleanName( name )
//                navigationItem.title = betterName
//            } else {
//                navigationItem.title = "Missing Name"
//            }
//        } else {
//            navigationItem.title = "Missing Peripheral"
//        }
        
//        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate

        textLabel.font = UIFont.preferredFontForTextStyle(fontStyle)
        textLabel.text = "" // "Test is test\nTest is test\nTest is test\nTest is test\nTest is test\nTest is test\nTest is test\nTest is test\nTest is test\nTest is test\nTest is test\nTest is test\nTest is test\nTest is test\nTest is test\nTest is test\nTest is test\nTest is test\nTest is test\nTest is test\nTest is test\nTest is test\nTest is test\nTest is test\nTest is test\nTest is test\nTest is test\nTest is test\nTest is test\nTest is test\nTest is test\nTest is test\n"
        
        outputString = ""
        
        prepareCharacteristicsProperties()
        prepareDescriptorDescription()
        prepareValueDescription()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(preferredContentSizeChanged(_:)), name: UIContentSizeCategoryDidChangeNotification, object: nil)

    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear( animated )
        
        textLabel.text = outputString
    }
    
    override func viewWillDisappear(animated: Bool) {
        
        super.viewWillDisappear( animated )

        NSNotificationCenter.defaultCenter().removeObserver( self )
        
    }

    func preferredContentSizeChanged(notification: NSNotification) {
        textLabel.font = UIFont.preferredFontForTextStyle(fontStyle)
//        Log.debug( "content size category changed" )
    }
    
    func prepareCharacteristicsProperties() {
        
        guard peripheral != nil else { return }
        guard peripheral!.services != nil else { return }
        let services = peripheral!.services!
        guard serviceIndex < services.count else { return }
        guard services[serviceIndex].characteristics != nil else { return }
        let characteristics = services[serviceIndex].characteristics!
        guard characteristicsIndex < characteristics.count else { return }
        characteristic = characteristics[characteristicsIndex]

        outputString += "\nProperties:\n"
        let properties = characteristic!.properties
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
    
    func prepareDescriptorDescription() {

        guard characteristic != nil else { Log.debug( "characteristic is nil" ); return }
        guard characteristic!.descriptors != nil else { Log.debug( "descriptors is nil" ); return }
        let descs = characteristic!.descriptors!
        if descs.count > 0 {
            outputString += "\n\(descs.count) Descriptors:\n"
            for desc in descs {
                Log.info( "Descriptor: \(desc.description)" )
            }
        } else {
            outputString += "\nNo Descriptors\n"
        }
        
    }
    
    func prepareValueDescription() {
        
        guard characteristic != nil else { Log.debug( "characteristic is nil" ); return }
        guard characteristic!.value != nil else { Log.debug( "value is nil" ); return }
        outputString += "\nValues:\n"
        Log.info( "characteristic!.value.description" )
    }
    
    
}
