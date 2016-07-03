//
//  buildPeripheralCVC.swift
//  able2
//
//  Created by William Snook on 5/25/16.
//  Copyright © 2016 William Snook. All rights reserved.
//

import UIKit
import CoreBluetooth


class buildPeripheralCVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITextFieldDelegate, CBPeripheralManagerDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var advertiseButton: UIButton!
    @IBOutlet weak var newServiceButton: UIButton!
    
    var builder: Builder?
    var buildDevice: BuildDevice?
//    var buildCharacteristics: Array<BuildCharacteristic>?  //[BuildCharacteristic]?
    
    var advertising = false
    
    
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var primaryLabel: UILabel!
    @IBOutlet weak var uuidField: UITextField!
    @IBOutlet weak var uuidButton: UIButton!
    
    var displayState = DisplayState.Neutral
    var nameFieldValid = false
    var uuidFieldValid = false
    var deviceValid = false
    
    var peripheralManager: CBPeripheralManager?

    var services: [BuildService]?

    
//--    ----    ----    ----
    
    // MARK: - Lifecycle events

    override func viewDidLoad() {
        super.viewDidLoad()
   
        Log.debug("")

        self.navigationItem.backBarButtonItem = UIBarButtonItem(title:"", style:.Plain, target:nil, action:nil)

        advertiseButton.layer.borderColor = UIColor.blackColor().CGColor
        advertiseButton.layer.borderWidth = 1.0
        advertiseButton.layer.cornerRadius = 6.0
        advertiseButton.setTitle( "Advertise", forState: .Normal )
        advertiseButton.setTitleColor( UIColor.blackColor(), forState: .Normal )
        advertiseButton.setTitleColor( UIColor.lightGrayColor(), forState: .Disabled )
        
        let deviceValid = ( buildDevice != nil )
        advertiseButton.enabled = deviceValid
        newServiceButton.enabled = deviceValid
        nameFieldValid = deviceValid
        uuidFieldValid = deviceValid

        builder = Builder.sharedBuilder
        if !deviceValid {
            buildDevice = BuildDevice( fromDevice: nil )
        }

        saveButton.enabled = false
        checkAddServiceButton()
    }

    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear( animated )
   
        Log.debug("")

        nameField.text = buildDevice!.name
        
        uuidField.text = buildDevice!.uuid
        uuidField.inputView = UIView.init( frame: CGRectZero );    // No keyboard
        
        textFieldBorderSetup(nameField)
        textFieldBorderSetup(uuidField)
        
        collectionView.reloadData()
    }
    
    override func viewDidDisappear(animated: Bool) {
        
//        NSNotificationCenter.defaultCenter().removeObserver( self )

        if advertising {
            stopAdvertising()
        }
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

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        
        if segue.identifier == "toNewService" {
            let dest = segue.destinationViewController as! buildServiceCVC
            builder!.currentDevice = buildDevice
            dest.buildService = nil
            Log.debug("dest.buildService will be nil")
        } else if segue.identifier == "toEditService" {
            let dest = segue.destinationViewController as! buildServiceCVC
            if let indexPaths = self.collectionView.indexPathsForSelectedItems() where indexPaths.count > 0 {
                builder!.currentDevice = buildDevice
                dest.buildService = buildDevice!.buildServices[indexPaths.first!.item]
                Log.debug("dest.buildService will be a BuildServices instance")
            }
        }
    }

    @IBAction func saveAction(sender: AnyObject) {

        guard buildDevice != nil else { Log.info( "save failed" ); return }
        saveButton.enabled = false
        
        advertiseButton.enabled = true
        checkAddServiceButton()
        
        saveDetails()
    }
    
    func saveDetails() {
        // Gather and save data from fields and save device
        buildDevice!.name = nameField.text
        buildDevice!.uuid = uuidField.text
        builder!.saveDevice( buildDevice! )
    }

    @IBAction func advertiseAction(sender: AnyObject) {
        
        guard validateDevice() else { return }
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
        checkAddServiceButton()
    }
    
    @IBAction func makeNewUUIDAction(sender: AnyObject) {
        
        let uuid = NSUUID.init()
        uuidField.text = uuid.UUIDString
        uuidField.enabled = true    // Allows selection
        uuidFieldValid = true
        textFieldBorderSetup( uuidField )
		deviceModified( nameFieldValid )
		
    }

    @IBAction func addServiceAction(sender: AnyObject) {
        
        if saveButton.enabled {
            // Initialize Alert Controller
            let alertController = UIAlertController(title: "Warning", message: "You have not saved changes to your device. You need to do this before you can create new Services. Save now?", preferredStyle: .Alert)
            
            // Configure Alert Controller
            alertController.addAction(UIAlertAction(title: "No", style: .Cancel, handler: { (_) -> Void in
//                self.navigationController?.popViewControllerAnimated(true)
            }))
            
            alertController.addAction(UIAlertAction(title: "Save", style: .Default, handler: { (_) -> Void in
                self.saveDetails()
                self.performSegueWithIdentifier( "toNewService", sender: nil )
            }))
            
            // Present Alert Controller
            presentViewController(alertController, animated: true, completion: nil)
        } else {
            self.performSegueWithIdentifier( "toNewService", sender: nil )
        }
    }
    
    
    // MARK: - State methods
    
    func setControlsEnabled( enabled: Bool ) {
        
        nameField.enabled = enabled
        uuidField.enabled = enabled
        uuidButton.enabled = enabled

        // characteristics
//        for buildCharacteristic in buildService!.buildCharacteristics {
//            buildCharacteristic.enabled( enabled )
//        }
    }
    
    // MARK: - CBPeripheralManagerDelegate support
    
    func peripheralManagerDidUpdateState(peripheral: CBPeripheralManager) {
        
        var state = ""
        switch ( peripheral.state ) {
        case .Unknown:
            state = "Currently in an unknown state."
        case .Resetting:
            state = "Peripheral Manager is resetting."
        case .Unsupported:
            state = "No support for Bluetooth Low Energy."
        case .Unauthorized:
            state = "Not authorized to use Bluetooth Low Energy."
        case .PoweredOff:
            state = "Currently powered off."
        case .PoweredOn:
            state = "Currently powered on."
        }
        Log.info( "Bluetooth peripheral manager state: \(state)" )
        
        if (peripheral.state != .PoweredOn) {		// In a real app, you'd deal with all the states correctly
//            resetScanList()
            return
        }
        // The state must be CBCentralManagerStatePoweredOn...
        // ... so start scanning
        self.startPublish()

    }
    
    func peripheralManagerDidStartAdvertising(peripheral: CBPeripheralManager, error: NSError?) {
        
        if ( error != nil ) {
            print( "peripheralManagerDidStartAdvertising, error: \(error!.localizedDescription)" )
        } else {
            print( "peripheralManagerDidStartAdvertising, success!!" )
        }
    }
    
    func peripheralManager(peripheral: CBPeripheralManager, didAddService service: CBService, error: NSError?) {
        
        if ( error != nil ) {
            print( "didAddService, error: \(error!.localizedDescription)" )
        } else {
            print( "didAddService, success!! Send: \(service.UUID.UUIDString)" )
            let adverts = [CBAdvertisementDataLocalNameKey:buildDevice!.name!, CBAdvertisementDataServiceUUIDsKey:[CBUUID( string: buildDevice!.uuid! )]] as [String:AnyObject]
            peripheralManager?.startAdvertising( adverts )
        }
    }

    
    // MARK: - Advertising support
    
    func startAdvertising() {
        
        advertising = true
        
        peripheralManager = CBPeripheralManager( delegate: self, queue: nil )
        
    }
    
    func stopAdvertising() {
        
        guard peripheralManager != nil else { return }
        guard peripheralManager!.isAdvertising else { return }
        peripheralManager!.stopAdvertising()
        peripheralManager!.removeAllServices()
        
        advertising = false
    }
    
    func startPublish() {
        
        guard buildDevice != nil else { return }
        guard peripheralManager != nil else { return }

//        let mutableService = buildService!.toBluetooth()
//        peripheralManager!.addService( mutableService )
        
    }
    

    func deviceModified( nameValid: Bool = false ) {
        
//    Log.info( "buildPeripheralCVC deviceModified, nameValid: \(nameValid), nameFieldValid: \(nameFieldValid), uuidFieldValid: \(uuidFieldValid) " )
		
        let validToSave = uuidFieldValid && nameValid
        saveButton.enabled = validToSave
        advertiseButton.enabled = !validToSave && nameFieldValid
    }
    
    func checkAddServiceButton() {
        
        if let count = buildDevice?.buildServices.count where count > 0 {   // Only one for now
            newServiceButton.enabled = false
        } else {
            newServiceButton.enabled = !advertising
        }
    }

    func validateDevice() -> Bool {    // All text fields have text in them
        
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
        deviceModified( nameFieldValid )
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
    
        return buildDevice!.buildServices.count
    }
    
    func collectionView( collectionView: UICollectionView,
                          cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCellWithReuseIdentifier( "ServicesCollectionViewCell", forIndexPath: indexPath ) as! ServicesCollectionViewCell
        
        let buildService = buildDevice!.buildServices[ indexPath.row ]
        buildService.setupCell( cell )
//        
//        cell.delegate = buildService
        return cell
    }
    
    func collectionView(collectionView: UICollectionView, layout: UICollectionViewLayout, sizeForItemAtIndexPath: NSIndexPath) -> CGSize {
        
		return CGSizeMake( collectionView.frame.size.width, 90 )
    }

}
