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

	func setStateEnabled( enabled: (Bool) ) {
		
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

	func verifyTextReady() -> Bool {
		
		return false
	}
	

	// Verify data is valid for advertising
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
