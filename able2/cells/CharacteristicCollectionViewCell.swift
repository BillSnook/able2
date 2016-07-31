//
//  CharacteristicCollectionViewCell.swift
//  able2
//
//  Created by William Snook on 7/25/16.
//  Copyright © 2016 William Snook. All rights reserved.
//

import Foundation
import UIKit


enum DisplayState {
    case Neutral
    case Valid
    case Invalid
}

class CharacteristicCollectionViewCell: UICollectionViewCell { //, UITextViewDelegate {

    @IBOutlet weak var uuidLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var propertyLabel: UILabel!

    @IBOutlet weak var deleteButton: UIButton!
    
    var indexPath: NSIndexPath?
    var delegate: DeleteButtonDelegate?
    
    @IBAction func deleteAction(sender: AnyObject) {
        
        if delegate != nil && indexPath != nil {
            delegate!.deleteCellAt( indexPath! )
        }
    }
    
    func setupButton() {
        
        deleteButton.layer.borderColor = UIColor.blackColor().CGColor
        deleteButton.layer.borderWidth = 1.0
        deleteButton.layer.cornerRadius = 6.0
        
    }

}