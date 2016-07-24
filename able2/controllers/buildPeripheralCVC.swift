//
//  buildPeripheralCVC.swift
//  able2
//
//  Created by William Snook on 5/25/16.
//  Copyright © 2016 William Snook. All rights reserved.
//

import UIKit
import CoreBluetooth


class buildPeripheralCVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITextFieldDelegate, CBPeripheralManagerDelegate, ServicesCVCDelegate {
    
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    @IBOutlet weak var advertiseButton: UIButton!
    
    @IBOutlet weak var newServiceButton: UIButton!
    @IBOutlet weak var addServiceLabel: UILabel!
    
    @IBOutlet weak var nameField: UITextField!
    @IBOutlet weak var uuidField: UITextField!
    @IBOutlet weak var uuidButton: UIButton!
    
    
    var builder: Builder?
    var buildDevice: BuildDevice?           // Set by calling view controller
    
    var peripheralManager: CBPeripheralManager?

    var services: [BuildService]?

    var newBackButton: UIBarButtonItem?
    
    
//--    ----    ----    ----
    
    // MARK: - Lifecycle events

    override func viewDidLoad() {
        super.viewDidLoad()
   
        Log.debug("")

        advertiseButton.layer.borderColor = UIColor.blackColor().CGColor
        advertiseButton.layer.borderWidth = 1.0
        advertiseButton.layer.cornerRadius = 6.0
        advertiseButton.setTitle( "Advertise", forState: .Normal )
        advertiseButton.setTitleColor( UIColor.blackColor(), forState: .Normal )
        advertiseButton.setTitleColor( UIColor.lightGrayColor(), forState: .Disabled )
        
        let deviceValid = ( buildDevice != nil )
        advertiseButton.enabled = deviceValid
        newServiceButton.enabled = deviceValid
        addServiceLabel.enabled = deviceValid

        builder = Builder.sharedBuilder
        if !deviceValid {
            buildDevice = BuildDevice( fromDevice: nil )
        }
        builder!.currentDevice = buildDevice

    }

    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear( animated )
   
        Log.debug("")

        navigationItem.title = "Current Device"

        nameField.text = buildDevice!.name
        
        uuidField.text = buildDevice!.uuid
        uuidField.inputView = UIView.init( frame: CGRectZero )    // No keyboard
        
        textFieldBorderSetup(nameField)
        textFieldBorderSetup(uuidField)
   
        // Setup controls - local and downstream
        setControlState()
        
        collectionView.reloadData()
    }
    
    override func viewDidDisappear(animated: Bool) {

        if builder!.buildState == .Advertising {
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
        
        builder!.currentDevice = buildDevice
        navigationItem.title = "Device"
        if segue.identifier == "toNewService" {
            let dest = segue.destinationViewController as! buildServiceCVC
            dest.buildService = nil
            Log.debug("dest.buildService will be nil")
        } else if segue.identifier == "toEditService" {
            let dest = segue.destinationViewController as! buildServiceCVC
            if let indexPaths = collectionView.indexPathsForSelectedItems() where indexPaths.count > 0 {
                dest.buildService = buildDevice!.buildServices[indexPaths.first!.item]
                Log.debug("dest.buildService will be a BuildServices instance")
            }
        }
    }

    @IBAction func saveAction(sender: AnyObject) {

        guard buildDevice != nil else { Log.info( "save failed - no device" ); return }
        
        // state == saved, set controls (saved, advertise, back button)
        
        saveDetails()
    }
    
    func saveDetails() {
        // Gather and save data from fields and save device
        buildDevice!.name = nameField.text
        buildDevice!.uuid = uuidField.text
        builder!.currentDevice = buildDevice
        builder!.saveDevice()
        setControlState()
    }

    @IBAction func advertiseAction(sender: AnyObject) {
        
        guard builder!.buildState == .Saved || builder!.buildState == .Advertising else { return }
        let adButton = sender as! UIButton
        if builder!.buildState != .Advertising {        // If we were not advertising, now we want to start
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
    
    @IBAction func makeNewUUIDAction(sender: AnyObject) {
        
        let newuuid = NSUUID.init()
        uuidField.text = newuuid.UUIDString
        uuidField.enabled = true    // Allows selection
        textFieldBorderSetup( uuidField )
        buildDevice!.uuid = newuuid.UUIDString
		setControlState()
		
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
    
    func deleteCellAt( indexPath: NSIndexPath ) {
        
        let alertController = UIAlertController(title: "Warning", message: "You are about to remove a service from your device. This operation cannot be undone. Continue?", preferredStyle: .Alert)
        
        // Configure Alert Controller
        alertController.addAction(UIAlertAction(title: "No", style: .Cancel, handler: { (_) -> Void in
        }))
        
        alertController.addAction(UIAlertAction(title: "Delete Service", style: .Default, handler: { (_) -> Void in
            self.removeCellAt( indexPath )
        }))
        
        // Present Alert Controller
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    func removeCellAt( indexPath: NSIndexPath ) {
        
        buildDevice!.removeServiceAtIndex( indexPath.row )
        builder!.saveDevice()
        collectionView.deleteItemsAtIndexPaths( [indexPath] )
    }
    
    
    // MARK: - State methods
    
    func setControlsEnabled( enabled: Bool ) {
        
        nameField.enabled = enabled
        uuidField.enabled = enabled
        uuidButton.enabled = enabled

    }
    
    func textChanged() {
        
        buildDevice!.name = nameField.text
        setControlState()
    }
    
    func setControlState() {
        
        var needSave = false
        
        if builder!.currentDevice!.isValid() {
            if builder!.currentDevice!.hasDeviceChanged() {
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
        advertiseButton.enabled = (builder!.buildState == .Saved) || (builder!.buildState == .Advertising)
        
        if let count = buildDevice?.buildServices.count where count > 1 {   // Up to two for now
            newServiceButton.enabled = false
            addServiceLabel.enabled = false
        } else {
            newServiceButton.enabled = !(builder!.buildState == .Advertising)
            addServiceLabel.enabled = !(builder!.buildState == .Advertising)
        }
        
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
            print( "  error: \(error!.localizedDescription)" )
        } else {
            print( "  success!!" )
        }
    }
    
    func peripheralManager(peripheral: CBPeripheralManager, didAddService service: CBService, error: NSError?) {
        
        if ( error != nil ) {
            print( "  error: \(error!.localizedDescription)" )
        } else {
            print( "  success!! Send: \(service.UUID.UUIDString)" )
            let adverts = [CBAdvertisementDataLocalNameKey:buildDevice!.name!, CBAdvertisementDataServiceUUIDsKey:[CBUUID( string: buildDevice!.uuid! )]] as [String:AnyObject]
            peripheralManager?.startAdvertising( adverts )
        }
    }

    
    // MARK: - Advertising support
    
    func startAdvertising() {
        
        builder!.buildState = .Advertising
        peripheralManager = CBPeripheralManager( delegate: self, queue: nil )
        
    }
    
    func stopAdvertising() {
        
        guard peripheralManager != nil else { return }
        guard peripheralManager!.isAdvertising else { return }
        peripheralManager!.stopAdvertising()
        peripheralManager!.removeAllServices()
        
        builder!.buildState = .Saved
    }
    
    func startPublish() {
        
        guard buildDevice != nil else { return }
        guard peripheralManager != nil else { return }

//        let mutableService = buildService!.toBluetooth()
//        peripheralManager!.addService( mutableService )
        
    }
    

    // MARK: - Control state support
    
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
    
        return buildDevice!.buildServices.count
    }
    
    func collectionView( collectionView: UICollectionView,
                          cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCellWithReuseIdentifier( "ServicesCollectionViewCell", forIndexPath: indexPath ) as! ServicesCollectionViewCell
        
        let buildService = buildDevice!.buildServices[ indexPath.row ]
        buildService.setupCell( cell )
        cell.indexPath = indexPath
        cell.delegate = self

        return cell
    }
    

    func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        
        unsavedEditServiceWarning()
    }
    

    func collectionView(collectionView: UICollectionView, layout: UICollectionViewLayout, sizeForItemAtIndexPath: NSIndexPath) -> CGSize {
        
		return CGSizeMake( collectionView.frame.size.width, 90 )
    }

}
