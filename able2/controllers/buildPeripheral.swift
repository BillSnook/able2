//
//  buildPeripheral.swift
//  able2
//
//  Created by William Snook on 5/25/16.
//  Copyright © 2016 William Snook. All rights reserved.
//

import UIKit

let sampleUUID = "180D"

class buildPeripheral: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var advertiseButton: UIButton!
    
    var advertising = false
    
//--    ----    ----    ----
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.Plain, target:nil, action:nil)

        advertiseButton.layer.borderColor = UIColor.blackColor().CGColor
        advertiseButton.layer.borderWidth = 1.0
        advertiseButton.layer.cornerRadius = 6.0
        advertiseButton.setTitle( "Advertise", forState: .Normal )
}
    
//    override func viewDidAppear(animated: Bool) {
//        super.viewDidAppear( animated )
//        
//    }
//    
//    override func didReceiveMemoryWarning() {
//        super.didReceiveMemoryWarning()
//        // Dispose of any resources that can be recreated.
//    }
    
    
    @IBAction func saveAction(sender: AnyObject) {

        // Gather and save data from fields and create service
        // Dismiss page
        self.navigationController?.popViewControllerAnimated( true )
    }

    @IBAction func advertiseChange(sender: AnyObject) {
        
        let adButton = sender as! UIButton
        let indexPath = NSIndexPath(forItem: adButton.tag, inSection: 0 )
        let cell = collectionView.cellForItemAtIndexPath( indexPath ) as! ServicesCollectionViewCell
        if !advertising {           // If we were not advertising, now we want to start
			if cell.verifyTextReady() {
				cell.setStateEnabled( false )
                adButton.setTitle( "Stop Advertising", forState: .Normal )
                advertising = true
                // Start advertising
            } else {
                // Say why we failed
            }
        } else {
//            cell.serviceNameField.layer.borderColor = UIColor.lightGrayColor().CGColor
//            cell.uuidField.layer.borderColor = UIColor.lightGrayColor().CGColor
            adButton.setTitle( "Advertise", forState: .Normal )
			cell.setStateEnabled( true )
            advertising = false
            // Stop advertising
        }
    }
    
    // MARK: - Collection View

    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        
        return 1
    }
    
    func collectionView( collectionView: UICollectionView, numberOfItemsInSection: NSInteger ) -> NSInteger {
    
        return 1
    }
    
    func collectionView( collectionView: UICollectionView,
                          cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if indexPath.section == 0 { // For advertised service setup
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier( "ServiceView", forIndexPath: indexPath ) as! ServicesCollectionViewCell
            
            cell.serviceNameField.text = ""
            cell.serviceNameField.layer.cornerRadius = 6.0
            cell.serviceNameField.layer.borderWidth = 0.5
            cell.serviceNameField.layer.borderColor = UIColor.lightGrayColor().CGColor
			cell.serviceNameField.delegate = cell
            cell.uuidField.text = ""
            cell.uuidField.layer.cornerRadius = 6.0
            cell.uuidField.layer.borderWidth = 0.5
            cell.uuidField.layer.borderColor = UIColor.lightGrayColor().CGColor
            cell.uuidField.inputView = UIView.init( frame: CGRectZero );    // No keyboard
			cell.uuidField.delegate = cell
            cell.tag = indexPath.item
			cell.verifyTextReady()
            return cell
        } else {
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier( "ServiceView", forIndexPath: indexPath ) as! ServicesCollectionViewCell
            return cell
        }
    }
    
    func collectionView(collectionView: UICollectionView, layout: UICollectionViewLayout, sizeForItemAtIndexPath: NSIndexPath) -> CGSize {
        
        let size = CGSizeMake( collectionView.frame.size.width, 100 )
        return size
    }

}