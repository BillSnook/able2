//
//  ServicesCollectionViewCell.swift
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

class ServicesCollectionViewCell: UICollectionViewCell, UITextFieldDelegate {
    
	// MARK: - Control outlets
	
    @IBOutlet weak var serviceNameField: UITextField!
    @IBOutlet weak var uuidField: UITextField!
    @IBOutlet weak var primarySwitch: UISwitch!
    @IBOutlet weak var uuidButton: UIButton!
	
	var displayState = DisplayState.Neutral
	

	// MARK: - Control actions
	
    @IBAction func primaryAction(sender: AnyObject) {
        
    }
    
    @IBAction func makeNewUUIDAction(sender: AnyObject) {
        
        let uuid = NSUUID.init()
        uuidField.text = uuid.UUIDString
        uuidField.enabled = true    // Allows selection
		textFieldNotEmpty( uuidField )
		
    }
	
	// MARK: - UITextFieldDelegate
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
		
		guard textField != uuidField else { return false }	// false because uuidField should never allow changes to its text
		
		if string.isEmpty {
			setBorderOf( textField, toDisplayState: .Invalid )
		} else {
			setBorderOf( textField, toDisplayState: .Valid )
		}
        return true
    }
	
	func textFieldDidEndEditing(textField: (UITextField)) {
	
		textFieldNotEmpty( textField )
	}
	
	// MARK: - State management
	
	func setStateEnabled( enabled: (Bool) ) {
		
		serviceNameField.enabled = enabled
		uuidField.enabled = enabled
		uuidButton.enabled = enabled
		primarySwitch.enabled = enabled
		
	}

	func setBorderOf( textField: (UITextField), toDisplayState: (DisplayState) ) {

		switch toDisplayState {
		case .Neutral:
			textField.layer.borderColor = UIColor.lightGrayColor().CGColor
		case .Valid:
			textField.layer.borderColor = UIColor.greenColor().CGColor
		case .Invalid:
			textField.layer.borderColor = UIColor.redColor().CGColor
		}

	}
	
	// Verify data is valid for advertising
	func verifyTextReady() -> Bool {

		var textReady = textFieldNotEmpty( serviceNameField )
		textReady = textFieldNotEmpty( uuidField ) && textReady
		return textReady
	}
	
	func textFieldNotEmpty( textField: (UITextField) ) -> Bool {
		
		if let text = textField.text {
			if text.isEmpty {
				setBorderOf( textField, toDisplayState: .Invalid )
				return false
			} else {
				setBorderOf( textField, toDisplayState: .Valid )
				return true
			}
		} else {
			setBorderOf( textField, toDisplayState: .Invalid )
			return false
		}
	}
	

}
