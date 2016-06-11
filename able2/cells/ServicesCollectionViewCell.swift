//
//  ServicesCollectionViewCell.swift
//  able2
//
//  Created by William Snook on 5/29/16.
//  Copyright © 2016 William Snook. All rights reserved.
//

import UIKit

class ServicesCollectionViewCell: AbleCollectionViewCell, UITextFieldDelegate {
    
	// MARK: - Control outlets
	
    @IBOutlet weak var serviceNameField: UITextField!
    @IBOutlet weak var uuidField: UITextField!
    @IBOutlet weak var primarySwitch: UISwitch!
    @IBOutlet weak var uuidButton: UIButton!
	
	var displayState = DisplayState.Neutral
    var cellValid = false
	

	// MARK: - Control actions
	
    @IBAction func primaryAction(sender: AnyObject) {
        
        stateDidChange()
    }
    
    @IBAction func makeNewUUIDAction(sender: AnyObject) {
        
        let uuid = NSUUID.init()
        uuidField.text = uuid.UUIDString
        uuidField.enabled = true    // Allows selection
		textFieldBorderSetup( uuidField )
        stateDidChange()
		
    }
	
    // MARK: - State methods
    
	override func setStateEnabled( enabled: (Bool) ) {

		serviceNameField.enabled = enabled
		uuidField.enabled = enabled
		uuidButton.enabled = enabled
		primarySwitch.enabled = enabled

	}

    override func cellIsValid() -> Bool {
        
        var isValid = verifyTextFieldsReady()
        isValid = cellValid || isValid
        cellValid = false
        return isValid
    }
    
	override func verifyTextFieldsReady() -> Bool {   // True if all text fields have entries
		
		var textReady = textFieldNotEmpty( serviceNameField )
		textReady = textFieldNotEmpty( uuidField ) && textReady
		return textReady
	}
	
	// MARK: - UITextFieldDelegate
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {

//		if string.isEmpty {
//			setBorderOf( textField, toDisplayState: .Invalid )
//		} else {
//			setBorderOf( textField, toDisplayState: .Valid )
//		}
        if textField == uuidField {
            return false	// false because uuidField should never allow changes to its text
        }
        
        cellValid = false       // Set if cell will be
        var displayState = DisplayState.Invalid // .Neutral
        if let text = textField.text {
//            print( "\ntext: \(text), length: \(text.characters.count)" )
//            print( "range location: \(range.location), length: \(range.length)" )
//            print( "string: \(string), length: \(string.characters.count)" )
            let nonEmptyText = !text.isEmpty && ( range.length != text.characters.count )
            let nonEmptyReplacement = !string.isEmpty
            if nonEmptyReplacement || nonEmptyText {
                cellValid = true
                displayState = .Valid
            } else {
                displayState = .Invalid
            }
        }
        setBorderOf( textField, toDisplayState: displayState )
        stateDidChange()
        return true
    }
	
	func textFieldDidEndEditing(textField: (UITextField)) {
	
		textFieldBorderSetup( textField )
	}
	
	// MARK: - State management
	

}
