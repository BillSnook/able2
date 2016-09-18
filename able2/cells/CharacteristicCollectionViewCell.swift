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
    case neutral
    case valid
    case invalid
}

class CharacteristicCollectionViewCell: UICollectionViewCell { //, UITextViewDelegate {

    @IBOutlet weak var uuidLabel: UILabel!
    @IBOutlet weak var valueLabel: UILabel!
    @IBOutlet weak var propertyLabel: UILabel!

    @IBOutlet weak var deleteButton: UIButton!
    
    var indexPath: IndexPath?
    var delegate: DeleteButtonDelegate?
    
    @IBAction func deleteAction(_ sender: AnyObject) {
        
        if delegate != nil && indexPath != nil {
            delegate!.deleteCellAt( indexPath! )
        }
    }
    
    func setupButton() {
        
        deleteButton.layer.borderColor = UIColor.black.cgColor
        deleteButton.layer.borderWidth = 1.0
        deleteButton.layer.cornerRadius = 6.0
        
    }

}
