//
//  AbleCollectionViewCell.swift
//  able2
//
//  Created by Bill Snook on 6/5/16.
//  Copyright © 2016 William Snook. All rights reserved.
//

import UIKit


enum DisplayState {
	case Neutral
	case Valid
	case Invalid
}


class AbleCollectionViewCell: UICollectionViewCell {
    
    var delegate: CellStateChangeProtocol?
    
    func cellIsValid() -> Bool {
        
        return verifyTextFieldsReady()
    }
    
    func stateDidChange() {
        
        if delegate != nil {
            delegate?.stateDidChange()
        }
    }

	func setStateEnabled( enabled: (Bool) ) {
		
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

	func verifyTextFieldsReady() -> Bool {
		
		return false
	}
	

	// Verify data is valid for advertising
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
    
}
