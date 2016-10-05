//
//  buildPeripheralCVC.swift
//  able2
//
//  Created by William Snook on 5/25/16.
//  Copyright © 2016 William Snook. All rights reserved.
//

import UIKit
import CoreBluetooth


protocol DeleteButtonDelegate {
    
    func deleteCellAt( _ indexPath: IndexPath )
    
}


class buildPeripheralCVC: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UITextFieldDelegate, CBPeripheralManagerDelegate, DeleteButtonDelegate {
    
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

    var newBackButton: UIBarButtonItem?
    
    
//--    ----    ----    ----
    
    // MARK: - Lifecycle events

    override func viewDidLoad() {
        super.viewDidLoad()
   
        DLog.debug("")

        advertiseButton.layer.borderColor = UIColor.black.cgColor
        advertiseButton.layer.borderWidth = 1.0
        advertiseButton.layer.cornerRadius = 6.0
        advertiseButton.setTitle( "Advertise", for: UIControlState() )
        advertiseButton.setTitleColor( UIColor.black, for: UIControlState() )
        advertiseButton.setTitleColor( UIColor.lightGray, for: .disabled )
        
        let deviceValid = ( buildDevice != nil )    // Set by caller, makePeripheralsTVC
        advertiseButton.isEnabled = deviceValid
        newServiceButton.isEnabled = deviceValid
        addServiceLabel.isEnabled = deviceValid

        builder = Builder.sharedBuilder
        if !deviceValid {
            buildDevice = BuildDevice( fromDevice: nil )
        }
        builder!.currentDevice = buildDevice

    }

    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear( animated )
   
        DLog.debug("")

        navigationItem.title = "Current Device"

        nameField.text = buildDevice!.name
        
        uuidField.text = buildDevice!.uuid
        uuidField.inputView = UIView.init( frame: CGRect.zero )    // No keyboard
        
        textFieldBorderSetup(nameField)
        textFieldBorderSetup(uuidField)
   
        // Setup local controls
        setControlState()
        
        collectionView.reloadData()
    }
    
    override func viewDidDisappear(_ animated: Bool) {

        if builder!.buildState == .advertising {
            endAdvertising( withButton: advertiseButton )
        }

        DLog.debug("")
        super.viewDidDisappear( animated )
    }
    
    override func viewWillTransition(to size: CGSize,
                                           with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        // Code here will execute before the rotation begins.
        coordinator.animate(alongsideTransition: { (context) -> Void in
            // Place code here to perform animations during the rotation.
            // You can pass nil for this closure if not necessary.
            },
           completion: { (context) -> Void in
            // Code here will execute after the rotation has finished.
            self.collectionView.reloadData()
        })
    }
    
    
    // MARK: - Control actions

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
//        builder!.currentDevice = buildDevice
        navigationItem.title = "Device"
        if segue.identifier == "toNewService" {
            let dest = segue.destination as! buildServiceCVC
            dest.buildService = nil
            DLog.debug("dest.buildService will be nil")
        } else if segue.identifier == "toEditService" {
            let dest = segue.destination as! buildServiceCVC
            if let indexPaths = collectionView.indexPathsForSelectedItems , indexPaths.count > 0 {
                dest.buildService = buildDevice!.buildServices[(indexPaths.first! as NSIndexPath).item]
                DLog.debug("dest.buildService will be a BuildServices instance")
            }
        }
    }

    @IBAction func saveAction(_ sender: AnyObject) {

        guard buildDevice != nil else { DLog.info( "save failed - no device" ); return }
        
        // state == saved, set controls (saved, advertise, back button)
        
        saveDetails()
    }
    
    func saveDetails() {
        // Gather and save data from fields and save device
        buildDevice!.name = nameField.text
        buildDevice!.uuid = uuidField.text
        builder!.saveDevice()
        setControlState()
    }

    @IBAction func advertiseAction(_ sender: AnyObject) {
        
        guard builder!.buildState == .saved || builder!.buildState == .advertising else { return }
        let adButton = sender as! UIButton
        if builder!.buildState != .advertising {        // If we were not advertising, now we want to start
            beginAdvertising( withButton: adButton )
        } else {
            endAdvertising( withButton: adButton )
        }
    }
    
    @IBAction func makeNewUUIDAction(_ sender: AnyObject) {
        
        let newuuid = UUID.init()
        uuidField.text = newuuid.uuidString
        uuidField.isEnabled = true    // Allows selection
        textFieldBorderSetup( uuidField )
        buildDevice!.uuid = newuuid.uuidString
		setControlState()
		
    }

    @IBAction func addServiceAction(_ sender: AnyObject) {
        
        if saveButton.isEnabled {
            // Initialize Alert Controller
            let alertController = UIAlertController(title: "Warning", message: "You have not saved changes to your device. You need to do this before you can create new Services. Save now?", preferredStyle: .alert)
            
            // Configure Alert Controller
            alertController.addAction(UIAlertAction(title: "No", style: .cancel, handler: { (_) -> Void in
//                self.navigationController?.popViewControllerAnimated(true)
            }))
            
            alertController.addAction(UIAlertAction(title: "Save", style: .default, handler: { (_) -> Void in
                self.saveDetails()
                self.performSegue( withIdentifier: "toNewService", sender: nil )
            }))
            
            // Present Alert Controller
            present(alertController, animated: true, completion: nil)
        } else {
            self.performSegue( withIdentifier: "toNewService", sender: nil )
        }
    }
    
    func beginAdvertising( withButton: UIButton ) {
        
        guard !saveButton.isEnabled else {
            return
        }
        setControlsEnabled( notAdvertising: false )
        collectionView.isUserInteractionEnabled = false
        withButton.setTitle( "Stop Advertising", for: UIControlState() )
        startAdvertising()
    }
    
    func endAdvertising( withButton: UIButton ) {
        
        setControlsEnabled( notAdvertising: true )
        collectionView.isUserInteractionEnabled = true
        withButton.setTitle( "Advertise", for: UIControlState() )
        stopAdvertising()
    }
    
    func unsavedCancelWarning() {
        
        if saveButton.isEnabled {
            // Initialize Alert Controller
            let alertController = UIAlertController(title: "Warning", message: "Warning. You have made changes to your device. If you continue now you will lose those changes.", preferredStyle: .alert)
            
            // Configure Alert Controller
            alertController.addAction(UIAlertAction(title: "Lose Changes", style: .cancel, handler: { (_) -> Void in
                let _ = self.navigationController?.popViewController(animated: true)
            }))
            
            alertController.addAction(UIAlertAction(title: "Save Changes", style: .default, handler: { (_) -> Void in
                self.saveDetails()
                let _ = self.navigationController?.popViewController(animated: true)
            }))
            
            // Present Alert Controller
            present(alertController, animated: true, completion: nil)
        } else {
            let _ = self.navigationController?.popViewController(animated: true)
        }
    }
    
    func unsavedEditWarningThenService() {
        
        if saveButton.isEnabled {
            // Initialize Alert Controller
            let alertController = UIAlertController(title: "Warning", message: "You have not saved changes to your device. Save now?", preferredStyle: .alert)
            
            // Configure Alert Controller
            alertController.addAction(UIAlertAction(title: "No", style: .cancel, handler: { (_) -> Void in
                self.performSegue( withIdentifier: "toEditService", sender: nil )
            }))
            
            alertController.addAction(UIAlertAction(title: "Save", style: .default, handler: { (_) -> Void in
                self.saveDetails()
                self.performSegue( withIdentifier: "toEditService", sender: nil )
            }))
            
            // Present Alert Controller
            present(alertController, animated: true, completion: nil)
        } else {
            self.performSegue( withIdentifier: "toEditService", sender: nil )
        }
    }
    
    // MARK: - DeleteButtonDelegate

    func deleteCellAt( _ indexPath: IndexPath ) {
        
        let alertController = UIAlertController(title: "Warning", message: "You are about to remove a service from your device. This operation cannot be undone. Continue?", preferredStyle: .alert)
        
        // Configure Alert Controller
        alertController.addAction(UIAlertAction(title: "No", style: .cancel, handler: { (_) -> Void in
        }))
        
        alertController.addAction(UIAlertAction(title: "Delete", style: .default, handler: { (_) -> Void in
            self.removeCellAt( indexPath )
        }))
        
        // Present Alert Controller
        present(alertController, animated: true, completion: nil)
    }
    
    func removeCellAt( _ indexPath: IndexPath ) {
        
        buildDevice!.removeServiceAtIndex( (indexPath as NSIndexPath).row )
        builder!.saveDevice()
        collectionView.deleteItems( at: [indexPath] )
        saveDetails()
    }
    
    
    // MARK: - State methods
    
    func setControlsEnabled( notAdvertising enabled: Bool ) {
        
        nameField.isEnabled = enabled
        uuidField.isEnabled = enabled
        uuidButton.isEnabled = enabled
        if buildDevice!.buildServices.count > 1 {   // Up to two for now
            newServiceButton.isEnabled = false
            addServiceLabel.isEnabled = false
        } else {
            newServiceButton.isEnabled = builder!.buildState == .saved
            addServiceLabel.isEnabled = builder!.buildState == .saved
        }
        collectionView.isUserInteractionEnabled = builder!.buildState == .saved
    }
    
    func textChanged() {
        
        buildDevice!.name = nameField.text
        setControlState()
    }
    
    func setControlState() {
        
        var needSave = false
        
        if builder!.currentDevice!.isValid() {
            if builder!.currentDevice!.hasDeviceChanged() {
                builder!.buildState = .unsaved
                needSave = true
            } else {
                builder!.buildState = .saved
            }
        } else {
            builder!.buildState = .invalid
        }
        
        if needSave {
            navigationItem.hidesBackButton = true
            newBackButton = newBackButton != nil ? newBackButton : UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(self.unsavedCancelWarning))
            navigationItem.leftBarButtonItem = newBackButton
        } else {
            navigationItem.leftBarButtonItem = nil
            navigationItem.hidesBackButton = false
        }
        
        saveButton.isEnabled = needSave
        advertiseButton.isEnabled = (builder!.buildState == .saved) || (builder!.buildState == .advertising)
        
        setControlsEnabled( notAdvertising: builder!.buildState != .advertising )
    }
    
    // MARK: - CBPeripheralManagerDelegate support
    
    func peripheralManagerDidUpdateState(_ peripheral: CBPeripheralManager) {
        
        var state = ""
        switch ( peripheral.state ) {
        case .unknown:
            state = "Currently in an unknown state."
        case .resetting:
            state = "Peripheral Manager is resetting."
        case .unsupported:
            state = "No support for Bluetooth Low Energy."
        case .unauthorized:
            state = "Not authorized to use Bluetooth Low Energy."
        case .poweredOff:
            state = "Currently powered off."
        case .poweredOn:
            state = "Currently powered on."
        }
        DLog.info( "Bluetooth peripheral manager state: \(state)" )
        
        if (peripheral.state != .poweredOn) {		// In a real app, you'd deal with all the states correctly
//            resetScanList()
            return
        }
        // The state must be CBCentralManagerStatePoweredOn...
        // ... so start scanning
        self.startPublish()

    }
    
    func peripheralManagerDidStartAdvertising(_ peripheral: CBPeripheralManager, error: Error?) {
        
        if ( error != nil ) {
            print( "  error: \(error!.localizedDescription)" )
        } else {
            print( "  success!!" )
        }
    }
    
    func peripheralManager(_ peripheral: CBPeripheralManager, didAdd service: CBService, error: Error?) {
        
        if ( error != nil ) {
            print( "  error: \(error!.localizedDescription)" )
        } else {
            print( "  success!! Send: \(service.uuid.uuidString)" )
            let adverts = [CBAdvertisementDataLocalNameKey:buildDevice!.name! as AnyObject, CBAdvertisementDataServiceUUIDsKey:[CBUUID( string: buildDevice!.uuid! )]] as [String:Any]
            peripheralManager?.startAdvertising( adverts )
        }
    }

    
    // MARK: - Advertising support
    
    func startAdvertising() {
        
        builder!.buildState = .advertising
        peripheralManager = CBPeripheralManager( delegate: self, queue: nil )
        
    }
    
    func stopAdvertising() {
        
        guard peripheralManager != nil else { return }
        builder!.buildState = .saved
        guard peripheralManager!.isAdvertising else { return }
        peripheralManager!.stopAdvertising()
        peripheralManager!.removeAllServices()
        
    }
    
    func startPublish() {
        
//        guard buildDevice != nil else { return }
        guard peripheralManager != nil else { return }

        if let mutableService = buildDevice!.toBluetooth() {
            peripheralManager!.add( mutableService )
        }
        
    }
    

    // MARK: - Control state support
    
    func setBorderOf( _ textField: (UITextField), toDisplayState: (DisplayState) ) {

        textField.layer.borderWidth = 0.5
        textField.layer.cornerRadius = 6.0
        switch toDisplayState {
        case .neutral:
            textField.layer.borderColor = UIColor.lightGray.cgColor
        case .valid:
            textField.layer.borderColor = UIColor.green.cgColor
        case .invalid:
            textField.layer.borderColor = UIColor.red.cgColor
        }
        
    }
    
    // Verify data is valid for advertising
    func textFieldNotEmpty( _ textField: (UITextField) ) -> Bool {
        
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
    
    func textFieldBorderSetup( _ textField: (UITextField) ) {
        
        if let text = textField.text {
            if text.isEmpty {
                setBorderOf( textField, toDisplayState: .invalid )
            } else {
                setBorderOf( textField, toDisplayState: .valid )
            }
        } else {
            setBorderOf( textField, toDisplayState: .neutral )
        }
    }
    

    // MARK: - UITextFieldDelegate
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        if textField == uuidField {
            return false	// false because uuidField should never allow changes to its text
        }
        
        var displayState = DisplayState.invalid // .Neutral
        if let text = textField.text {
            let nonEmptyText = !text.isEmpty && ( range.length != text.characters.count )
            let nonEmptyReplacement = !string.isEmpty
            if nonEmptyReplacement || nonEmptyText {
                displayState = .valid
            } else {
                displayState = .invalid
            }
        }
        setBorderOf( textField, toDisplayState: displayState )
        DispatchQueue.main.asyncAfter( deadline: DispatchTime.now() + Double(Int64(0.1 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC)) { () -> Void in
            self.textChanged()
        }
        return true
    }
    
    func textFieldDidEndEditing(_ textField: (UITextField)) {
        
        textFieldBorderSetup( textField )
    }
    
    // MARK: - Collection View

    func numberOfSections(in collectionView: UICollectionView) -> Int {
        
        return 1
    }
    
    func collectionView( _ collectionView: UICollectionView, numberOfItemsInSection: NSInteger ) -> NSInteger {
    
        return buildDevice!.buildServices.count
    }
    
    func collectionView( _ collectionView: UICollectionView,
                          cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell( withReuseIdentifier: "ServicesCollectionViewCell", for: indexPath ) as! ServicesCollectionViewCell
        
        let buildService = buildDevice!.buildServices[ (indexPath as NSIndexPath).row ]

        cell.nameLabel.text = buildService.name
        cell.uuidLabel.text = buildService.uuid
        cell.primaryLabel.text = (buildService.primary ? "Primary" : "")
        switch ( buildService.buildCharacteristics.count ) {
        case 0:
            cell.characteristicsLabel.text = "No Characteristics"
        case 1:
            cell.characteristicsLabel.text = "1 Characteristic"
        default:
            cell.characteristicsLabel.text = "\(buildService.buildCharacteristics.count) Characteristics"
        }
        cell.subservicesLabel.text = ""  //  "No Sub-Services"
        
        cell.setupButton()

        cell.indexPath = indexPath
        cell.delegate = self

        return cell
    }
    

    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        unsavedEditWarningThenService()
    }
    

    func collectionView(_ collectionView: UICollectionView, layout: UICollectionViewLayout, sizeForItemAt sizeForItemAtIndexPath: IndexPath) -> CGSize {
        
		return CGSize( width: collectionView.frame.size.width, height: 90.0 )
    }

}
