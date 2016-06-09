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


class ShowCharacteristics: UIViewController, CharacteristicProtocol {

    var characterizer: Characterizer = Characterizer.sharedCharacterizer

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

        textLabel.font = UIFont.preferredFontForTextStyle(fontStyle)
        textLabel.text = ""
		outputString = ""
        
        prepareCharacteristicsProperties()
        prepareDescriptorDescription()
        prepareValueDescription()
        
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(preferredContentSizeChanged(_:)), name: UIContentSizeCategoryDidChangeNotification, object: nil)

        characterizer.characteristicDelegate = self
        if ( CBCharacteristicProperties.Read.rawValue & characteristic!.properties.rawValue ) != 0 {  // If characteristic is readable, start read operation
            characterizer.startCharacteristicEvaluation( characteristic!, forPeripheral: peripheral! )
        }

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
		var offset = 0
        if ( CBCharacteristicProperties.Broadcast.rawValue & rawProperties ) != 0 {
            outputString += "  Broadcast"
			offset += 1
        }
		if ( CBCharacteristicProperties.Notify.rawValue & rawProperties ) != 0 {
			outputString += "  Notify"
			offset += 1
		}
		if ( CBCharacteristicProperties.Indicate.rawValue & rawProperties ) != 0 {
			outputString += "  Indicate"
			offset += 1
		}
		if offset > 0 {
			outputString += "\n"
			offset = 0
		}

		if ( CBCharacteristicProperties.Read.rawValue & rawProperties ) != 0 {
            outputString += "  Read"
			offset += 1
        }
		if ( CBCharacteristicProperties.Write.rawValue & rawProperties ) != 0 {
			outputString += "  Write"
			offset += 1
		}
        if ( CBCharacteristicProperties.WriteWithoutResponse.rawValue & rawProperties ) != 0 {
            outputString += "  WriteWithoutResponse"
			offset += 1
        }
		if offset > 0 {
			outputString += "\n"
			offset = 0
		}

		if ( CBCharacteristicProperties.AuthenticatedSignedWrites.rawValue & rawProperties ) != 0 {
            outputString += "  AuthenticatedSignedWrites"
			offset += 1
        }
        if ( CBCharacteristicProperties.ExtendedProperties.rawValue & rawProperties ) != 0 {
            outputString += "  ExtendedProperties"
			offset += 1
       }
		if offset > 0 {
			outputString += "\n"
		}

        if ( CBCharacteristicProperties.Read.rawValue & rawProperties ) != 0 {  // If characteristic is readable, start read operation
            
            
        }

    }
    
    func prepareDescriptorDescription() {

        guard characteristic != nil else { Log.debug( "characteristic is nil" ); return }
        guard characteristic!.descriptors != nil else { Log.debug( "descriptors is nil" ); return }
        let descs = characteristic!.descriptors!
        Log.debug( "descriptor count: \(descs.count)" )
        if descs.count > 0 {
            outputString += "\n\(descs.count) Descriptors:\n"
            for desc in descs {
                Log.info( "  Descriptor: \(desc.description)" )
            }
            outputString += "\n"
        } else {
            outputString += "\nNo Descriptors\n"
        }
        textLabel.text = outputString
    }
    
    func prepareValueDescription() {
        
        
        guard characteristic != nil else { Log.debug( "characteristic is nil" ); return }
        guard characteristic!.value != nil else { Log.debug( "value is nil" ); return }
        outputString += "\nCharacteristic Values:\n"
        if let dataString = String( data: characteristic!.value!, encoding: NSUTF8StringEncoding ) {
            outputString += dataString + "\n"
        } else {
            outputString += "Non-string data\n"
        }
        textLabel.text = outputString
        Log.info( "characteristic value: \(characteristic!.value!.description)" )
    }
    
    
    // MARK: - descriptor and characteristics protocol support
    
    func descriptorsRead( characteristic: CBCharacteristic ) {
        
//        outputString = textLabel.text!
        prepareDescriptorDescription()
        
    }
    
    func characteristicRead( characteristic: CBCharacteristic ) {
        
//        outputString = textLabel.text!
        prepareValueDescription()
        
    }
    
}
