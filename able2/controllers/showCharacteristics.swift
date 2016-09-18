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
    
    let fontStyle = UIFontTextStyle.headline

    
    //--	----	----	----	----	----	----	----
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        textLabel.font = UIFont.preferredFont(forTextStyle: fontStyle)
        textLabel.text = ""
		outputString = ""
        
        prepareCharacteristicsProperties()
        prepareDescriptorDescription()
        prepareValueDescription()
        
        NotificationCenter.default.addObserver(self, selector: #selector(preferredTextSizeChanged(_:)), name: NSNotification.Name.UIContentSizeCategoryDidChange, object: nil)

        characterizer.characteristicDelegate = self
        if ( CBCharacteristicProperties.read.rawValue & characteristic!.properties.rawValue ) != 0 {  // If characteristic is readable, start read operation
            characterizer.startCharacteristicEvaluation( characteristic!, forPeripheral: peripheral! )
        }

    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear( animated )
        
        textLabel.text = outputString
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        super.viewWillDisappear( animated )

        NotificationCenter.default.removeObserver( self )
        
    }

    func preferredTextSizeChanged(_ notification: Notification) {
        textLabel.font = UIFont.preferredFont(forTextStyle: fontStyle)
//        DLog.debug( "content size category changed" )
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
        if ( CBCharacteristicProperties.broadcast.rawValue & rawProperties ) != 0 {
            outputString += "  Broadcast"
			offset += 1
        }
		if ( CBCharacteristicProperties.notify.rawValue & rawProperties ) != 0 {
			outputString += "  Notify"
			offset += 1
		}
		if ( CBCharacteristicProperties.indicate.rawValue & rawProperties ) != 0 {
			outputString += "  Indicate"
			offset += 1
		}
		if offset > 0 {
			outputString += "\n"
			offset = 0
		}

		if ( CBCharacteristicProperties.read.rawValue & rawProperties ) != 0 {
            outputString += "  Read"
			offset += 1
        }
		if ( CBCharacteristicProperties.write.rawValue & rawProperties ) != 0 {
			outputString += "  Write"
			offset += 1
		}
        if ( CBCharacteristicProperties.writeWithoutResponse.rawValue & rawProperties ) != 0 {
            outputString += "  WriteWithoutResponse"
			offset += 1
        }
		if offset > 0 {
			outputString += "\n"
			offset = 0
		}

		if ( CBCharacteristicProperties.authenticatedSignedWrites.rawValue & rawProperties ) != 0 {
            outputString += "  AuthenticatedSignedWrites"
			offset += 1
        }
        if ( CBCharacteristicProperties.extendedProperties.rawValue & rawProperties ) != 0 {
            outputString += "  ExtendedProperties"
			offset += 1
       }
		if offset > 0 {
			outputString += "\n"
		}

        if ( CBCharacteristicProperties.read.rawValue & rawProperties ) != 0 {  // If characteristic is readable, start read operation
            
            
        }

    }
    
    func prepareDescriptorDescription() {

        guard characteristic != nil else { DLog.debug( "characteristic is nil" ); return }
        guard characteristic!.descriptors != nil else { DLog.debug( "descriptors is nil" ); return }
        let descs = characteristic!.descriptors!
        DLog.debug( "descriptor count: \(descs.count)" )
        if descs.count > 0 {
            outputString += "\n\(descs.count) Descriptors:\n"
            for desc in descs {
                DLog.info( "  Descriptor: \(desc.description)" )
            }
            outputString += "\n"
        } else {
            outputString += "\nNo Descriptors\n"
        }
        textLabel.text = outputString
    }
    
    func prepareValueDescription() {
        
        
        guard characteristic != nil else { DLog.debug( "characteristic is nil" ); return }
        guard characteristic!.value != nil else { DLog.debug( "value is nil" ); return }
        outputString += "\nCharacteristic Values:\n"
        if let dataString = String( data: characteristic!.value!, encoding: String.Encoding.utf8 ) {
            outputString += dataString + "\n"
        } else {
            outputString += "Non-string data\n"
        }
        textLabel.text = outputString
        DLog.info( "characteristic value: \(characteristic!.value!.description)" )
    }
    
    
    // MARK: - descriptor and characteristics protocol support
    
    func descriptorsRead( _ characteristic: CBCharacteristic ) {
        
//        outputString = textLabel.text!
        prepareDescriptorDescription()
        
    }
    
    func characteristicRead( _ characteristic: CBCharacteristic ) {
        
//        outputString = textLabel.text!
        prepareValueDescription()
        
    }
    
}
