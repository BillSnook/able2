//
//  buildServiceCVC.swift
//  able2
//
//  Created by William Snook on 5/25/16.
//  Copyright © 2016 William Snook. All rights reserved.
//

import UIKit
import CoreBluetooth


class buildServiceCVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITextFieldDelegate, DeleteButtonDelegate {
    
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

        navigationItem.title = "Current Service"

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

        collectionView.reloadData()
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
            let alertController = UIAlertController(title: "Warning", message: "You have not saved changes to your service. You need to do this before you can create new Characteristics. Save now?", preferredStyle: .Alert)
            
            // Configure Alert Controller
            alertController.addAction(UIAlertAction(title: "No", style: .Cancel, handler: { (_) -> Void in
            }))
            
            alertController.addAction(UIAlertAction(title: "Save", style: .Default, handler: { (_) -> Void in
                self.saveDetails()
                self.performSegueWithIdentifier( "toNewCharacteristic", sender: nil )
            }))
            
            // Present Alert Controller
            presentViewController(alertController, animated: true, completion: nil)
        } else {
            self.performSegueWithIdentifier( "toNewCharacteristic", sender: nil )
        }
  
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
            let alertController = UIAlertController(title: "Warning", message: "Warning. You have made changes to this service. If you return to the device page now you will lose those changes.", preferredStyle: .Alert)
            
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
            let alertController = UIAlertController(title: "Warning", message: "You have not saved changes to this service. Save now?", preferredStyle: .Alert)
            
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
            newCharacteristicButton.enabled = !needSave
            addCharacteristicLabel.enabled = !needSave
        }
        
    }
    
    // MARK: - DeleteButtonDelegate
    
    func deleteCellAt( indexPath: NSIndexPath ) {
        
        let alertController = UIAlertController(title: "Warning", message: "You are about to delete a characteristic from your service. This operation cannot be undone. Continue?", preferredStyle: .Alert)
        
        // Configure Alert Controller
        alertController.addAction(UIAlertAction(title: "No", style: .Cancel, handler: { (_) -> Void in
        }))
        
        alertController.addAction(UIAlertAction(title: "Delete", style: .Default, handler: { (_) -> Void in
            self.removeCellAt( indexPath )
        }))
        
        // Present Alert Controller
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    func removeCellAt( indexPath: NSIndexPath ) {
        
        buildService!.removeCharacteristicAtIndex( indexPath.row )
        builder!.saveService( buildService! )
        collectionView.deleteItemsAtIndexPaths( [indexPath] )
        saveDetails()
    }
    
    // MARK: - State methods
    
    func unsavedEditWarningThenCharacteristic() {
        
        if saveButton.enabled {
            // Initialize Alert Controller
            let alertController = UIAlertController(title: "Warning", message: "You have not saved changes to this service. Save now?", preferredStyle: .Alert)
            
            // Configure Alert Controller
            alertController.addAction(UIAlertAction(title: "No", style: .Cancel, handler: { (_) -> Void in
                self.performSegueWithIdentifier( "toEditCharacteristic", sender: nil )
            }))
            
            alertController.addAction(UIAlertAction(title: "Save", style: .Default, handler: { (_) -> Void in
                self.saveDetails()
                self.performSegueWithIdentifier( "toEditCharacteristic", sender: nil )
            }))
            
            // Present Alert Controller
            presentViewController(alertController, animated: true, completion: nil)
        } else {
            self.performSegueWithIdentifier( "toEditCharacteristic", sender: nil )
        }
    }
    

    // MARK: - Control actions
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        builder!.currentService = buildService
        navigationItem.title = "Service"
        if segue.identifier == "toNewCharacteristic" {
            let dest = segue.destinationViewController as! buildCharacteristicVC
            dest.buildCharacteristic = nil
            Log.debug("dest.buildCharacteristic will be nil")
        } else if segue.identifier == "toEditCharacteristic" {
            let dest = segue.destinationViewController as! buildCharacteristicVC
            if let indexPaths = collectionView.indexPathsForSelectedItems() where indexPaths.count > 0 {
                dest.buildCharacteristic = buildService!.buildCharacteristics[indexPaths.first!.item]
                Log.debug("dest.buildCharacteristic will be a BuildCharacteristics instance")
            }
        }
    }
    
    func permissionsToString( permissions: CBAttributePermissions ) -> String {
        
        var pStr = ""
        if permissions.contains( .Readable ) {
            pStr += "Rd"
        }
        if permissions.contains( .Writeable ) {
            if pStr != "" { pStr += ", " }
            pStr += "Wr"
        }
        if permissions.contains( .ReadEncryptionRequired ) {
            if pStr != "" { pStr += ", " }
            pStr += "RdEn"
        }
        if permissions.contains( .WriteEncryptionRequired ) {
            if pStr != "" { pStr += ", " }
            pStr += "WrEn"
        }
        
        return pStr
    }
    
    func propertiesToString( properties: CBCharacteristicProperties ) -> String {
        
        var pStr = ""
        if properties.contains( .Read ) {
            pStr += "Rd"
        }
        if properties.contains( .WriteWithoutResponse ) {
            if pStr != "" { pStr += ", " }
            pStr += "Wr"
        }
        if properties.contains( .AuthenticatedSignedWrites ) {
            if pStr != "" { pStr += ", " }
            pStr += "WrAu"
        }
        if properties.contains( .Write ) {
            if pStr != "" { pStr += ", " }
            pStr += "WrwR"
        }
        if properties.contains( .Notify ) {
            if pStr != "" { pStr += ", " }
            pStr += "No"
        }
        if properties.contains( .Indicate ) {
            if pStr != "" { pStr += ", " }
            pStr += "In"
        }
        if properties.contains( .NotifyEncryptionRequired ) {
            if pStr != "" { pStr += ", " }
            pStr += "NoEn"
        }
        if properties.contains( .IndicateEncryptionRequired ) {
            if pStr != "" { pStr += ", " }
            pStr += "InEn"
        }
        return pStr
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

        let cell = collectionView.dequeueReusableCellWithReuseIdentifier( "CharacteristicSummary", forIndexPath: indexPath ) as! CharacteristicCollectionViewCell

        let buildCharacteristic = buildService!.buildCharacteristics[ indexPath.row ]

        cell.uuidLabel.text = buildCharacteristic.uuid
        if let valueData = buildCharacteristic.value {
            let nsString = NSString(data: valueData, encoding: NSUTF8StringEncoding)!
            cell.valueLabel.text = nsString as String
        } else {
            cell.valueLabel.text = ""
        }
        
        cell.setupButton()

        cell.propertyLabel.text = permissionsToString( buildCharacteristic.permissions! ) + "  -  " + propertiesToString( buildCharacteristic.properties! )
            
        cell.indexPath = indexPath
        cell.delegate = self
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        unsavedEditWarningThenCharacteristic()
    }
    

    func collectionView(collectionView: UICollectionView, layout: UICollectionViewLayout, sizeForItemAtIndexPath: NSIndexPath) -> CGSize {
        
		return CGSizeMake( collectionView.frame.size.width, 120.0 )
    }

}
