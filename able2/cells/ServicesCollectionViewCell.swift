//
//  ServicesCollectionViewCell.swift
//  able2
//
//  Created by William Snook on 6/22/16.
//  Copyright © 2016 William Snook. All rights reserved.
//

import UIKit



class ServicesCollectionViewCell: UICollectionViewCell, UITextViewDelegate {
		
// isNotifying		Boolean		True if notifications/indications are enabled
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var primarySwitch: UISwitch!
    @IBOutlet weak var primaryLabel: UILabel!
    @IBOutlet weak var uuidField: UITextField!
    @IBOutlet weak var uuidButton: UIButton!

	
    var delegate: CellStateChangeProtocol?
    
	var displayState = DisplayState.Neutral

	
	@IBAction func makeNewUUIDAction(sender: UIButton) {

		let uuid = NSUUID.init()
		uuidField.text = uuid.UUIDString
		uuidField.enabled = true    // Allows selection
        textFieldBorderSetup( uuidField )
        stateDidChange()
	}
	
    @IBAction func primaryAction(sender: UISwitch) {
        
        stateDidChange()
    }
    
    func stateDidChange() {
        
//        if delegate != nil {
//            delegate?.stateDidChange( forCell: self )
//        }
    }
    
    func cellIsValid() -> Bool {

        // Also verify switch combinations
        var valid = textFieldNotEmpty( uuidField )
        valid = valid && textFieldNotEmpty( nameField )
        return valid
    }
    
	func setStateEnabled( enabled: (Bool) ) {
		
        nameField.enabled = enabled
		uuidField.enabled = enabled
		uuidButton.enabled = enabled
		primarySwitch.enabled = enabled
		
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
    
    // MARK: - UITextFieldDelegate - UUID - make it unchangeable via user touches; Name - normal, delayed notice to let text stabilize
    
    func textField(textField: UITextField, shouldChangeCharactersInRange: NSRange, replacementString: NSString) -> Bool {
    
        if textField == uuidField {
            stateDidChange()
            return false
        } else {
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.1 * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), {
                self.stateDidChange()
            })
            return true
        }
    }
    
	func textViewDidEndEditing(textView: UITextView) {
        
        stateDidChange()
	}

}
