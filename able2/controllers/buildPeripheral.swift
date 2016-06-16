//
//  buildPeripheral.swift
//  able2
//
//  Created by William Snook on 5/25/16.
//  Copyright © 2016 William Snook. All rights reserved.
//

import UIKit


let kCharacteristicChangedKey = "CharacteristicChangedKey"


class buildPeripheral: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITextFieldDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var advertiseButton: UIButton!
    @IBOutlet weak var newCharacteristicButton: UIButton!
    
    var builder: Builder?
    var buildService: BuildService?
//    var buildCharacteristics: Array<BuildCharacteristic>?  //[BuildCharacteristic]?
    
    var advertising = false
    
    
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var uuidField: UITextField!
    @IBOutlet weak var primarySwitch: UISwitch!
    @IBOutlet weak var uuidButton: UIButton!
    
    var displayState = DisplayState.Neutral
    var nameFieldValid = false
    var uuidFieldValid = false
    
    
//--    ----    ----    ----
    
    // MARK: - Lifecycle events

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.Plain, target:nil, action:nil)

        advertiseButton.layer.borderColor = UIColor.blackColor().CGColor
        advertiseButton.layer.borderWidth = 1.0
        advertiseButton.layer.cornerRadius = 6.0
        advertiseButton.setTitle( "Advertise", forState: .Normal )
        advertiseButton.setTitleColor( UIColor.blackColor(), forState: .Normal )
        advertiseButton.setTitleColor( UIColor.lightGrayColor(), forState: .Disabled )
        
        let serviceValid = ( buildService != nil )
        advertiseButton.enabled = serviceValid
        newCharacteristicButton.enabled = serviceValid
        nameFieldValid = serviceValid
        uuidFieldValid = serviceValid

        builder = Builder.sharedBuilder
        if !serviceValid {
            buildService = builder!.bareService()
        }

        saveButton.enabled = false
    }

    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear( animated )
        
        nameField.text = buildService!.name
        
        uuidField.text = buildService!.uuid
        uuidField.inputView = UIView.init( frame: CGRectZero );    // No keyboard
        
        if let primary = buildService!.primary {
            primarySwitch.on = primary.boolValue
        } else {
            primarySwitch.on = false
        }
        
        textFieldBorderSetup(nameField)
        textFieldBorderSetup(uuidField)

        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(characteristicChanged( _: )), name: kCharacteristicChangedKey, object: nil)
    }
    
    override func viewDidDisappear(animated: Bool) {
        
        NSNotificationCenter.defaultCenter().removeObserver( self )

        if advertising {
            stopAdvertising()
        }
        super.viewDidDisappear( animated )
    }
    
    override func viewWillTransitionToSize(size: CGSize,
                                           withTransitionCoordinator coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransitionToSize(size, withTransitionCoordinator: coordinator)
        // Code here will execute before the rotation begins.
        coordinator.animateAlongsideTransition({ (context) -> Void in
            // Place code here to perform animations during the rotation.
            // You can pass nil for this closure if not necessary.
            },
           completion: { (context) -> Void in
            // Code here will execute after the rotation has finished.
            self.collectionView.reloadData()
        })
    }
    
    
    // MARK: - Control actions

    @IBAction func saveAction(sender: AnyObject) {

        guard buildService != nil else { print( "save failed" ); return }
        saveButton.enabled = false
        // Gather and save data from fields and create service
        buildService!.name = nameField.text
        buildService!.uuid = uuidField.text
        buildService!.primary = primarySwitch.on
        
        // characteristics
//        let buildCharacteristic = buildService!.buildCharacteristics[ 0 ]
        
        builder!.save( buildService! )
        advertiseButton.enabled = true
    }

    @IBAction func advertiseAction(sender: AnyObject) {
        
        guard validateService() else { return }
        let adButton = sender as! UIButton
        if !advertising {           // If we were not advertising, now we want to start
            guard !saveButton.enabled else { return }   // But must be saved first - may need alert
            setControlsEnabled( false )
            adButton.setTitle( "Stop Advertising", forState: .Normal )
            startAdvertising()
        } else {
            adButton.setTitle( "Advertise", forState: .Normal )
			setControlsEnabled( true )
            stopAdvertising()
        }
    }
    
    @IBAction func characteristicAction(sender: UIButton) {
        
        print( "characteristicAction" )
        if let buildCharacteristic = builder?.bareCharacteristic() {
            buildCharacteristic.index = buildService!.buildCharacteristics.count // Give it order
            buildService!.buildCharacteristics.append( buildCharacteristic )
        }

//        serviceModified( nameFieldValid )
        collectionView.reloadData()
    }

    @IBAction func primaryAction(sender: AnyObject) {
        
		serviceModified( nameFieldValid )
    }
    
    @IBAction func makeNewUUIDAction(sender: AnyObject) {
        
        let uuid = NSUUID.init()
        uuidField.text = uuid.UUIDString
        uuidField.enabled = true    // Allows selection
        uuidFieldValid = true
        textFieldBorderSetup( uuidField )
		serviceModified( nameFieldValid )
		
    }
    
    // MARK: - State methods
    
    func setControlsEnabled( enabled: (Bool) ) {
        
        nameField.enabled = enabled
        uuidField.enabled = enabled
        uuidButton.enabled = enabled
        primarySwitch.enabled = enabled
        
    }
    

    // MARK: - Advertising support
    
    func startAdvertising() {
        
        advertising = true
    }
    
    func stopAdvertising() {
        
        advertising = false
    }
    

    func serviceModified( nameValid: Bool = false ) {
        
//    print( "buildPeripheral serviceModified, nameValid: \(nameValid), nameFieldValid: \(nameFieldValid), uuidFieldValid: \(uuidFieldValid) " )
		
        let validToSave = uuidFieldValid && nameValid
        saveButton.enabled = validToSave
        advertiseButton.enabled = !validToSave && nameFieldValid
    }

    func characteristicChanged(notification: NSNotification) {

        saveButton.enabled = true
        advertiseButton.enabled = false
    }
    
    func validateService() -> Bool {    // All text fields have text in them
        
        guard nameFieldValid else { return false }
        guard uuidFieldValid else { return false }
        return true
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
    

    // MARK: - UITextFieldDelegate
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        if textField == uuidField {
            return false	// false because uuidField should never allow changes to its text
        }
        
        nameFieldValid = false       // Set if cell will be
        var displayState = DisplayState.Invalid // .Neutral
        if let text = textField.text {
//            print( "\ntext: \(text), length: \(text.characters.count)" )
//            print( "range location: \(range.location), length: \(range.length)" )
//            print( "string: \(string), length: \(string.characters.count)" )
            let nonEmptyText = !text.isEmpty && ( range.length != text.characters.count )
            let nonEmptyReplacement = !string.isEmpty
            if nonEmptyReplacement || nonEmptyText {
                nameFieldValid = true
                displayState = .Valid
            } else {
                displayState = .Invalid
            }
        }
        setBorderOf( textField, toDisplayState: displayState )
        serviceModified( nameFieldValid )
        return true
    }
    
    func textFieldDidEndEditing(textField: (UITextField)) {
        
        textFieldBorderSetup( textField )
    }
    
    // MARK: - Collection View

    func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        
        return 1
    }
    
    func collectionView( collectionView: UICollectionView, numberOfItemsInSection: NSInteger ) -> NSInteger {
    
        return buildService!.buildCharacteristics.count
    }
    
    func collectionView( collectionView: UICollectionView,
                          cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCellWithReuseIdentifier( "CharacteristicView", forIndexPath: indexPath ) as! CharacteristicsCollectionViewCell
        
        let buildCharacteristic = buildService!.buildCharacteristics[ indexPath.row ]
        cell.uuidField.text = buildCharacteristic.uuid
        cell.uuidField.inputView = UIView.init( frame: CGRectZero );    // No keyboard
        cell.textFieldBorderSetup(cell.uuidField)

        if let value = buildCharacteristic.value {
            let nsString = NSString(data: value, encoding: NSUTF8StringEncoding)!
            cell.valueTextView.text = nsString as String
        } else {
            cell.valueTextView.text = ""
        }
        cell.valueTextView.delegate = buildCharacteristic
        buildCharacteristic.cell = cell

        
        cell.delegate = buildCharacteristic
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout: UICollectionViewLayout, sizeForItemAtIndexPath: NSIndexPath) -> CGSize {
        
		return CGSizeMake( collectionView.frame.size.width, 425 )
    }

}
