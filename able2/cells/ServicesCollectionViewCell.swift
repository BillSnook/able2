//
//  ServicesCollectionViewCell.swift
//  able2
//
//  Created by William Snook on 5/29/16.
//  Copyright © 2016 William Snook. All rights reserved.
//

import UIKit


class ServicesCollectionViewCell: UICollectionViewCell, UITextViewDelegate {
	
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var primaryLabel: UILabel!
    @IBOutlet weak var uuidLabel: UILabel!

    @IBOutlet weak var characteristicsLabel: UILabel!
    @IBOutlet weak var subservicesLabel: UILabel!
    
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
