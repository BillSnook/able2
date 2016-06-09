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
    
    var builder: Builder?
    
    var service: Service?
    var characteristics: [Characteristic]?
    
//--    ----    ----    ----
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.Plain, target:nil, action:nil)

        advertiseButton.layer.borderColor = UIColor.blackColor().CGColor
        advertiseButton.layer.borderWidth = 1.0
        advertiseButton.layer.cornerRadius = 6.0
        advertiseButton.setTitle( "Advertise", forState: .Normal )
        
//        builder = Builder.sharedBuilder
        builder?.setupFromService( service )
        service = builder?.service
        characteristics = builder?.characteristics

    }

    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear( animated )
        
        service = builder?.service
        characteristics = builder?.characteristics
    }
    
    override func viewWillTransitionToSize(size: CGSize,
                                           withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        // Code here will execute before the rotation begins.
        // Equivalent to placing it in the deprecated method -[willRotateToInterfaceOrientation:duration:]
        coordinator.animateAlongsideTransition({ (context) -> Void in
            // Place code here to perform animations during the rotation.
            // You can pass nil for this closure if not necessary.
            },
           completion: { (context) -> Void in
            // Code here will execute after the rotation has finished.
            // Equivalent to placing it in the deprecated method -[didRotateFromInterfaceOrientation:]
            self.collectionView.reloadData()
        }) }

    @IBAction func saveAction(sender: AnyObject) {

        guard service != nil else { print( "save failed" ); return }
        // Gather and save data from fields and create service
        let indexPath = NSIndexPath(forItem: 0, inSection: 0 )
        let cell = collectionView.cellForItemAtIndexPath( indexPath ) as! ServicesCollectionViewCell
        service!.name = cell.serviceNameField.text
        service!.uuid = cell.uuidField.text
        builder?.save()
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
    
    @IBAction func addCharacteristicAction(sender: UIButton) {
        
        print( "addCharacteristicAction" )
    }
    // MARK: - Collection View

    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        
        guard service != nil else { return 0 }
        return 1
    }
    
    func collectionView( collectionView: UICollectionView, numberOfItemsInSection: NSInteger ) -> NSInteger {
    
        return 2
        if let count = characteristics?.count {
            return 1 + count
        }
        return 1
    }
    
    func collectionView( collectionView: UICollectionView,
                          cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        if indexPath.row == 0 { // For advertised service setup
            let cell = collectionView.dequeueReusableCellWithReuseIdentifier( "ServiceView", forIndexPath: indexPath ) as! ServicesCollectionViewCell
            
            cell.serviceNameField.text = service!.name
			cell.serviceNameField.delegate = cell
			
            cell.uuidField.text = service!.uuid
            cell.uuidField.inputView = UIView.init( frame: CGRectZero );    // No keyboard
			cell.uuidField.delegate = cell
            cell.tag = indexPath.item
			cell.verifyTextReady()
			
            return cell
        } else {
			if indexPath.row > 0 { // For characteristic setup
				let cell = collectionView.dequeueReusableCellWithReuseIdentifier( "CharacteristicView", forIndexPath: indexPath ) as! CharacteristicsCollectionViewCell
				
				cell.uuidField.text = ""
				cell.uuidField.inputView = UIView.init( frame: CGRectZero );    // No keyboard
				cell.tag = indexPath.item

				cell.valueTextView.text = ""
				cell.tag = indexPath.item

				return cell
			} else {
				let cell = collectionView.dequeueReusableCellWithReuseIdentifier( "CharacteristicView", forIndexPath: indexPath ) as! CharacteristicsCollectionViewCell
				return cell
			}
        }
    }
    
    func collectionView(collectionView: UICollectionView, layout: UICollectionViewLayout, sizeForItemAtIndexPath: NSIndexPath) -> CGSize {
        
		if sizeForItemAtIndexPath.row == 0 { // For advertised service setup
			return CGSizeMake( collectionView.frame.size.width, 100 )
		} else {
			if sizeForItemAtIndexPath.row == 1 { // For characteristic setup
				return CGSizeMake( collectionView.frame.size.width, 425 )
			} else {
				return CGSizeZero
			}
		}
    }

}
