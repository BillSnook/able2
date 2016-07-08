//
//  buildServiceCVC.swift
//  able2
//
//  Created by William Snook on 5/25/16.
//  Copyright © 2016 William Snook. All rights reserved.
//

import UIKit
import CoreBluetooth


let kServiceChangedKey = "ServiceChangedKey"


class buildServiceCVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITextFieldDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var newCharacteristicButton: UIButton!
    @IBOutlet weak var addCharacteristicLabel: UILabel!
    
    var builder: Builder?
    var buildService: BuildService?
//    var buildCharacteristics: Array<BuildCharacteristic>?  //[BuildCharacteristic]?
    
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var uuidField: UITextField!
    @IBOutlet weak var primarySwitch: UISwitch!
    @IBOutlet weak var uuidButton: UIButton!
    
    var displayState = DisplayState.Neutral
    var nameFieldValid = false
    var uuidFieldValid = false
    
    var peripheralManager: CBPeripheralManager?

    var newBackButton: UIBarButtonItem?
    
    
//--    ----    ----    ----
    
    // MARK: - Lifecycle events

    override func viewDidLoad() {
        super.viewDidLoad()
        
        Log.debug("")

//        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.Plain, target:nil, action:nil)
//        self.navigationItem.hidesBackButton = true
//        let newBackButton = UIBarButtonItem(title: "List", style: .Plain, target: self, action: #selector(self.goBack))
//        self.navigationItem.leftBarButtonItem = newBackButton;

        let serviceValid = ( buildService != nil )
        newCharacteristicButton.enabled = serviceValid
        addCharacteristicLabel.enabled = serviceValid
        nameFieldValid = serviceValid
        uuidFieldValid = serviceValid

        builder = Builder.sharedBuilder
        if !serviceValid {
            buildService = BuildService( fromService: nil )
        }

        saveButton.enabled = false
        checkAddCharacteristicButton()
    }

    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear( animated )
        
        Log.debug("")

        navigationItem.title = "Service"

        nameField.text = buildService!.name
        
        uuidField.text = buildService!.uuid
        uuidField.inputView = UIView.init( frame: CGRectZero );    // No keyboard
        
        if buildService!.primary {
            primarySwitch.on = buildService!.primary.boolValue
        } else {
            primarySwitch.on = false
        }
        
        textFieldBorderSetup(nameField)
        textFieldBorderSetup(uuidField)

        setSaveState( false )

        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(characteristicChanged( _: )), name: kServiceChangedKey, object: nil)
    }
    
    override func viewDidDisappear(animated: Bool) {
        
        NSNotificationCenter.defaultCenter().removeObserver( self )

        Log.debug("")

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

        guard buildService != nil else { Log.info( "save failed" ); return }
        setSaveState( false )

        checkAddCharacteristicButton()
        
        saveDetails()
    }
    
    func saveDetails() {

        // Gather and save data from fields and create service
        buildService!.name = nameField.text
        buildService!.uuid = uuidField.text
        buildService!.primary = primarySwitch.on
        Log.debug("")
        builder!.saveService( buildService! )
}

    @IBAction func characteristicAction(sender: UIButton) {
        
        Log.info( "characteristicAction" )
        guard buildService != nil else { Log.info( "But buildService is nil" ); return }
        let buildCharacteristic = BuildCharacteristic( fromCharacteristic: nil )
        buildCharacteristic.index = buildService!.buildCharacteristics.count // Give it order
        buildService!.buildCharacteristics.append( buildCharacteristic )
        checkAddCharacteristicButton()

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
    
    func setSaveState( enabled: Bool ) {
        
        saveButton.enabled = enabled
        if enabled {
            navigationItem.hidesBackButton = true
            newBackButton = newBackButton != nil ? newBackButton : UIBarButtonItem(title: "Cancel", style: .Plain, target: self, action: #selector(self.unsavedCancelWarning))
            navigationItem.leftBarButtonItem = newBackButton
        } else {
            navigationItem.leftBarButtonItem = nil
            navigationItem.hidesBackButton = false
        }
        
    }
    
    // MARK: - State methods
    
    func setControlsEnabled( enabled: Bool ) {
        
        nameField.enabled = enabled
        uuidField.enabled = enabled
        uuidButton.enabled = enabled
        primarySwitch.enabled = enabled

        // characteristics
        for buildCharacteristic in buildService!.buildCharacteristics {
            buildCharacteristic.enabled( enabled )
        }
    }
    
    func serviceModified( nameValid: Bool = false ) {
        
//    Log.info( "buildServiceCVC serviceModified, nameValid: \(nameValid), nameFieldValid: \(nameFieldValid), uuidFieldValid: \(uuidFieldValid) " )
		
        let validToSave = uuidFieldValid && nameValid
        saveButton.enabled = validToSave
    }

    func characteristicChanged(notification: NSNotification) {

        saveButton.enabled = true
        checkAddCharacteristicButton()
    }
    
    func checkAddCharacteristicButton() {
        
        if let count = buildService?.buildCharacteristics.count where count > 0 {   // Only one for now
            newCharacteristicButton.enabled = false
            addCharacteristicLabel.enabled = false
        } else {
            newCharacteristicButton.enabled = true
            addCharacteristicLabel.enabled = true
        }
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
//            Log.info( "\ntext: \(text), length: \(text.characters.count)" )
//            Log.info( "range location: \(range.location), length: \(range.length)" )
//            Log.info( "string: \(string), length: \(string.characters.count)" )
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
        buildCharacteristic.setupCell( cell )
        
        cell.delegate = buildCharacteristic
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout: UICollectionViewLayout, sizeForItemAtIndexPath: NSIndexPath) -> CGSize {
        
		return CGSizeMake( collectionView.frame.size.width, 425 )
    }

}
