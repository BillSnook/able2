//
//  ServicesCollectionViewCell.swift
//  able2
//
//  Created by William Snook on 5/29/16.
//  Copyright © 2016 William Snook. All rights reserved.
//

import UIKit


protocol ServicesCVCDelegate {
    
    func deleteCellAt( indexPath: NSIndexPath )
    
}

class ServicesCollectionViewCell: UICollectionViewCell, UITextViewDelegate {
	
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var primaryLabel: UILabel!
    @IBOutlet weak var uuidLabel: UILabel!

    @IBOutlet weak var characteristicsLabel: UILabel!
    @IBOutlet weak var subservicesLabel: UILabel!
    @IBOutlet weak var deleteLabel: UILabel!
    
    @IBOutlet weak var deleteButton: UIButton!
    
    var indexPath: NSIndexPath?
    var delegate: ServicesCVCDelegate?
    
    
    @IBAction func deleteAction(sender: AnyObject) {
        
        if delegate != nil && indexPath != nil {
            delegate!.deleteCellAt( indexPath! )
        }
    }

}
