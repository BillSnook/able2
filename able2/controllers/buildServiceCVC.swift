//
//  buildServiceCVC.swift
//  able2
//
//  Created by William Snook on 5/25/16.
//  Copyright © 2016 William Snook. All rights reserved.
//

import UIKit
import CoreBluetooth


class buildServiceCVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITextFieldDelegate, CellStateChangeProtocol {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var newCharacteristicButton: UIButton!
    @IBOutlet weak var addCharacteristicLabel: UILabel!
    
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var uuidField: UITextField!
    @IBOutlet weak var primarySwitch: UISwitch!
    @IBOutlet weak var uuidButton: UIButton!
    
    var builder: Builder?
    var buildService: BuildService?
    
    var peripheralManager: CBPeripheralManager?

    var newBackButton: UIBarButtonItem?
    
    var displayState = DisplayState.Neutral
    
    
//--    ----    ----    ----
    
    // MARK: - Lifecycle events

    override func viewDidLoad() {
        super.viewDidLoad()
        
        Log.debug("")

        let serviceValid = ( buildService != nil )
        newCharacteristicButton.enabled = serviceValid
        addCharacteristicLabel.enabled = serviceValid

        builder = Builder.sharedBuilder
        if !serviceValid {
            buildService = BuildService( fromService: nil )
        }
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

        setControlState()

    }
    
    override func viewDidDisappear(animated: Bool) {

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

//        guard buildService != nil else { Log.info( "save failed" ); return }
        
        saveDetails()
    }
    
    func saveDetails() {

        // Gather and save data from fields and create service
        buildService!.name = nameField.text
        buildService!.uuid = uuidField.text
        buildService!.primary = primarySwitch.on
        Log.debug("")
        builder!.saveService( buildService! )
        setControlState()
    }

    @IBAction func addCharacteristicAction(sender: UIButton) {
        
        Log.info( "" )
        if saveButton.enabled {
            // Initialize Alert Controller
            let alertController = UIAlertController(title: "Warning", message: "You have not saved changes to your device. You need to do this before you can create new Characteristics. Save now?", preferredStyle: .Alert)
            
            // Configure Alert Controller
            alertController.addAction(UIAlertAction(title: "No", style: .Cancel, handler: { (_) -> Void in
//                self.navigationController?.popViewControllerAnimated(true)
            }))
            
            alertController.addAction(UIAlertAction(title: "Save", style: .Default, handler: { (_) -> Void in
                self.saveDetails()
                self.characteristicAction()
            }))
            
            // Present Alert Controller
            presentViewController(alertController, animated: true, completion: nil)
        } else {
            self.characteristicAction()
        }
  
    }
    
    func characteristicAction() {
        
        Log.info( "" )
        guard buildService != nil else { Log.info( "But buildService is nil" ); return }
        let buildCharacteristic = BuildCharacteristic( fromCharacteristic: nil )
        buildCharacteristic.index = buildService!.buildCharacteristics.count // Give it order
        buildService!.buildCharacteristics.append( buildCharacteristic )
        setControlState()

        collectionView.reloadData()
    }

    @IBAction func primaryAction(sender: AnyObject) {
        
        buildService!.primary = primarySwitch.on
		setControlState()
    }
    
    @IBAction func makeNewUUIDAction(sender: AnyObject) {
        
        let newuuid = NSUUID.init()
        uuidField.text = newuuid.UUIDString
        uuidField.enabled = true    // Allows selection
        textFieldBorderSetup( uuidField )
        buildService!.uuid = newuuid.UUIDString
		setControlState()
		
    }
    
    func unsavedCancelWarning() {
        
        if saveButton.enabled {
            // Initialize Alert Controller
            let alertController = UIAlertController(title: "Warning", message: "Warning. You have made changes to your device. If you continue now you will lose those changes.", preferredStyle: .Alert)
            
            // Configure Alert Controller
            alertController.addAction(UIAlertAction(title: "Lose Changes", style: .Cancel, handler: { (_) -> Void in
                self.navigationController?.popViewControllerAnimated(true)
            }))
            
            alertController.addAction(UIAlertAction(title: "Save Changes", style: .Default, handler: { (_) -> Void in
                self.saveDetails()
                self.navigationController?.popViewControllerAnimated(true)
            }))
            
            // Present Alert Controller
            presentViewController(alertController, animated: true, completion: nil)
        } else {
            self.navigationController?.popViewControllerAnimated(true)
        }
    }
    
    func unsavedEditServiceWarning() {
        
        if saveButton.enabled {
            // Initialize Alert Controller
            let alertController = UIAlertController(title: "Warning", message: "You have not saved changes to your device. Save now?", preferredStyle: .Alert)
            
            // Configure Alert Controller
            alertController.addAction(UIAlertAction(title: "No", style: .Cancel, handler: { (_) -> Void in
                self.performSegueWithIdentifier( "toEditService", sender: nil )
            }))
            
            alertController.addAction(UIAlertAction(title: "Save", style: .Default, handler: { (_) -> Void in
                self.saveDetails()
                self.performSegueWithIdentifier( "toEditService", sender: nil )
            }))
            
            // Present Alert Controller
            presentViewController(alertController, animated: true, completion: nil)
        } else {
            self.performSegueWithIdentifier( "toEditService", sender: nil )
        }
    }
    
    func textChanged() {
        
        buildService!.name = nameField.text
        setControlState()
    }
    
    func setControlState() {
        
        var needSave = false
        
        if buildService!.isValid() {
            if buildService!.hasChanged() {
                builder!.buildState = .Unsaved
                needSave = true
            } else {
                builder!.buildState = .Saved
            }
        } else {
            builder!.buildState = .Invalid
        }
        
        if needSave {
            navigationItem.hidesBackButton = true
            newBackButton = newBackButton != nil ? newBackButton : UIBarButtonItem(title: "Cancel", style: .Plain, target: self, action: #selector(self.unsavedCancelWarning))
            navigationItem.leftBarButtonItem = newBackButton
        } else {
            navigationItem.leftBarButtonItem = nil
            navigationItem.hidesBackButton = false
        }
        
        saveButton.enabled = needSave
        
        if let count = buildService?.buildCharacteristics.count where count > 1 {   // Up to one for now
            newCharacteristicButton.enabled = false
            addCharacteristicLabel.enabled = false
        } else {
            newCharacteristicButton.enabled = true
            addCharacteristicLabel.enabled = true
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
    
    func stateDidChange() {

        setControlState()
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
        
        var displayState = DisplayState.Invalid // .Neutral
        if let text = textField.text {
//            Log.info( "\ntext: \(text), length: \(text.characters.count)" )
//            Log.info( "range location: \(range.location), length: \(range.length)" )
//            Log.info( "string: \(string), length: \(string.characters.count)" )
            let nonEmptyText = !text.isEmpty && ( range.length != text.characters.count )
            let nonEmptyReplacement = !string.isEmpty
            if nonEmptyReplacement || nonEmptyText {
                displayState = .Valid
            } else {
                displayState = .Invalid
            }
        }
        setBorderOf( textField, toDisplayState: displayState )
        dispatch_after( dispatch_time(DISPATCH_TIME_NOW, Int64(0.1 * Double(NSEC_PER_SEC))), dispatch_get_main_queue()) { () -> Void in
            self.textChanged()
        }
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
        
        buildCharacteristic.delegate = self
        cell.delegate = buildCharacteristic
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout: UICollectionViewLayout, sizeForItemAtIndexPath: NSIndexPath) -> CGSize {
        
		return CGSizeMake( collectionView.frame.size.width, 425 )
    }

}
