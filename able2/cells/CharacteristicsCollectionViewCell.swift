//
//  CharacteristicsCollectionViewCell.swift
//  able2
//
//  Created by William Snook on 5/29/16.
//  Copyright © 2016 William Snook. All rights reserved.
//

import UIKit

class CharacteristicsCollectionViewCell: AbleCollectionViewCell, UITextViewDelegate {
	
	// UUID				CBUUID
	@IBOutlet weak var uuidField: UITextField!
	@IBOutlet weak var uuidButton: UIButton!
	
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
	@IBOutlet weak var valueTextView: UITextView!
	

	// isNotifying		Boolean		True if notifications/indications are enabled

	
	var displayState = DisplayState.Neutral

	
	@IBAction func makeNewUUIDAction(sender: UIButton) {

		let uuid = NSUUID.init()
		uuidField.text = uuid.UUIDString
		uuidField.enabled = true    // Allows selection
        textFieldBorderSetup( uuidField )
        stateDidChange()
	}
	
	override func setStateEnabled( enabled: (Bool) ) {
		
		uuidField.enabled = enabled
		uuidButton.enabled = enabled
//		primarySwitch.enabled = enabled
		
	}
	
    override func cellIsValid() -> Bool {

        // Also verify switch combinations
        return verifyTextFieldsReady()
    }
    
	override func verifyTextFieldsReady() -> Bool {
		
		return textFieldNotEmpty( uuidField )
	}
	
	// MARK: - UITextViewDelegate

	func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
	
		guard textView != uuidField else { return false }	// false because uuidField should never allow changes to its text
        stateDidChange()
		return true
	}

	func textViewDidEndEditing(textView: UITextView) {
        
        stateDidChange()
	}

}
