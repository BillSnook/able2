//
//  CharacteristicsCollectionViewCell.swift
//  able2
//
//  Created by William Snook on 5/29/16.
//  Copyright © 2016 William Snook. All rights reserved.
//

import UIKit


enum DisplayState {
    case Neutral
    case Valid
    case Invalid
}

protocol CellStateChangeProtocol {
    
    func stateDidChange()
}



class CharacteristicsCollectionViewCell: UICollectionViewCell, UITextViewDelegate {
	
	// UUID				CBUUID
	@IBOutlet weak var uuidField: UITextField!
	@IBOutlet weak var uuidButton: UIButton!
	
	@IBOutlet weak var valueTextView: UITextView!
	
	// Permissions		CBAttributePermissions	Read, Write, and encryption permissions for value
/*
	typedef enum {
		CBAttributePermissionsReadable = 0x01,
		CBAttributePermissionsWriteable = 0x02,
		CBAttributePermissionsReadEncryptionRequired = 0x04,
		CBAttributePermissionsWriteEncryptionRequired = 0x08,
	} CBAttributePermissions;
*/
	@IBOutlet weak var permReadSwitch: UISwitch!
	@IBOutlet weak var permWriteSwitch: UISwitch!
	@IBOutlet weak var permReadWithEncryptionSwitch: UISwitch!
	@IBOutlet weak var permWriteWithEncryptionSwitch: UISwitch!

	
	// Descriptors		[CBDescriptor]?	Describe value format and in human-readable form
	// Properties		CBCharacteristicProperties	How to use and access values and descriptors
	@IBOutlet weak var propReadSwitch: UISwitch!
	@IBOutlet weak var propWriteSwitch: UISwitch!
	@IBOutlet weak var propAuthenticateSwitch: UISwitch!
	@IBOutlet weak var propWriteWithResponseSwitch: UISwitch!
	
	@IBOutlet weak var propNotifySwitch: UISwitch!
	@IBOutlet weak var propIndicateSwitch: UISwitch!
	@IBOutlet weak var propNotifyWithEncryptionSwitch: UISwitch!
	@IBOutlet weak var propIndicateWithEncryptionSwitch: UISwitch!
	
/*
	struct CBCharacteristicProperties : OptionSetType {
		init(rawValue rawValue: UInt)
		static var Broadcast: CBCharacteristicProperties { get }
		static var Read: CBCharacteristicProperties { get }
		static var WriteWithoutResponse: CBCharacteristicProperties { get }
		static var Write: CBCharacteristicProperties { get }
		static var Notify: CBCharacteristicProperties { get }
		static var Indicate: CBCharacteristicProperties { get }
		static var AuthenticatedSignedWrites: CBCharacteristicProperties { get }
		static var ExtendedProperties: CBCharacteristicProperties { get }
		static var NotifyEncryptionRequired: CBCharacteristicProperties { get }
		static var IndicateEncryptionRequired: CBCharacteristicProperties { get }
	}
*/
	// Value			NSData?
    
	// isNotifying		Boolean		True if notifications/indications are enabled

	
    var delegate: CellStateChangeProtocol?
    
	var displayState = DisplayState.Neutral

	
	@IBAction func makeNewUUIDAction(sender: UIButton) {

		let uuid = NSUUID.init()
		uuidField.text = uuid.UUIDString
		uuidField.enabled = true    // Allows selection
        textFieldBorderSetup( uuidField )
        stateDidChange()
	}
	
    func stateDidChange() {
        
        if delegate != nil {
            delegate?.stateDidChange()
        }
    }
    
    func cellIsValid() -> Bool {

        // Also verify switch combinations
        let valid = textFieldNotEmpty( uuidField )
        return valid
    }
    
	func setStateEnabled( enabled: (Bool) ) {
		
		uuidField.enabled = enabled
		uuidButton.enabled = enabled
//		primarySwitch.enabled = enabled
		
	}
	
    func setBorderOf( textField: (UITextField), toDisplayState: (DisplayState) ) {
        
        textField.layer.borderWidth = 0.5
        textField.layer.cornerRadius = 6.0
        switch toDisplayState {
        case .Neutral:
            textField.layer.borderColor = UIColor.lightGrayColor().CGColor
        case .Valid:
            textField.layer.borderColor = UIColor.greenColor().CGColor
        case .Invalid:
            textField.layer.borderColor = UIColor.redColor().CGColor
        }
        
    }
    
    func textFieldNotEmpty( textField: (UITextField) ) -> Bool {
        
        if let text = textField.text {
            if text.isEmpty {
                return false
            } else {
                return true
            }
        } else {
            return false
        }
    }
    
    func textFieldBorderSetup( textField: (UITextField) ) {
        
        if let text = textField.text {
            if text.isEmpty {
                setBorderOf( textField, toDisplayState: .Invalid )
            } else {
                setBorderOf( textField, toDisplayState: .Valid )
            }
        } else {
            setBorderOf( textField, toDisplayState: .Neutral )
        }
    }
    
    // MARK: - UITextFieldDelegate - UUID - make it unchangeable via user touches
    
    func textField(textField: UITextField, shouldChangeCharactersInRange: NSRange, replacementString: NSString) -> Bool {
    
        stateDidChange()
        return false
    }
    
    // MARK: - UITextViewDelegate - Value field
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.1 * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), {
            self.stateDidChange()
        })
        return true
    }
    
	func textViewDidEndEditing(textView: UITextView) {
        
        stateDidChange()
	}

    @IBAction func permissionControl(sender: UISwitch) {

        stateDidChange()
    }
    
    @IBAction func propertiesChanged(sender: UISwitch) {

        stateDidChange()
    }
    
    
}
