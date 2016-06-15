//
//  AbleCollectionViewCell.swift
//  able2
//
//  Created by Bill Snook on 6/5/16.
//  Copyright © 2016 William Snook. All rights reserved.
//

import UIKit


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
}
