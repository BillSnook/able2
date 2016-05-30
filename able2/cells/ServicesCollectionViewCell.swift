//
//  ServicesCollectionViewCell.swift
//  able2
//
//  Created by William Snook on 5/29/16.
//  Copyright © 2016 William Snook. All rights reserved.
//

import UIKit

class ServicesCollectionViewCell: UICollectionViewCell {
    
    @IBOutlet weak var serviceNameField: UITextField!
    @IBOutlet weak var uuidField: UITextField!
    @IBOutlet weak var primarySwitch: UISwitch!
    @IBOutlet weak var uuidButton: UIButton!
    
    
    @IBAction func primaryAction(sender: AnyObject) {
        
    }
    
    @IBAction func makeNewUUIDAction(sender: AnyObject) {
        
        let uuid = NSUUID.init()
        uuidField.text = uuid.UUIDString
    }
}
