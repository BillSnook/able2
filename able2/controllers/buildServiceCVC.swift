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
    
    var displayState = DisplayState.neutral
    
    
    
//--    ----    ----    ----
    
    // MARK: - Lifecycle events

    override func viewDidLoad() {
        super.viewDidLoad()
        
        Log.debug("")

        let serviceValid = ( buildService != nil )
        newCharacteristicButton.isEnabled = serviceValid
        addCharacteristicLabel.isEnabled = serviceValid

        builder = Builder.sharedBuilder
        if !serviceValid {
            buildService = BuildService( fromService: nil )
        }
    }

    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear( animated )
        
        Log.debug("")

        navigationItem.title = "Current Service"

        nameField.text = buildService!.name
        
        uuidField.text = buildService!.uuid
        uuidField.inputView = UIView.init( frame: CGRect.zero );    // No keyboard
        
        if buildService!.primary {
            primarySwitch.isOn = buildService!.primary
        } else {
            primarySwitch.isOn = false
        }
        
        textFieldBorderSetup(nameField)
        textFieldBorderSetup(uuidField)

        setControlState()

        collectionView.reloadData()
    }
    
    override func viewDidDisappear(_ animated: Bool) {

        Log.debug("")

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

    @IBAction func saveAction(_ sender: AnyObject) {

//        guard buildService != nil else { Log.info( "save failed" ); return }
        
        saveDetails()
    }
    
    func saveDetails() {

        // Gather and save data from fields and create service
        buildService!.name = nameField.text
        buildService!.uuid = uuidField.text
        buildService!.primary = primarySwitch.isOn
        Log.debug("")
        builder!.saveService( buildService! )
        setControlState()
    }

    @IBAction func addCharacteristicAction(_ sender: UIButton) {
        
        Log.info( "" )
        if saveButton.isEnabled {
            // Initialize Alert Controller
            let alertController = UIAlertController(title: "Warning", message: "You have not saved changes to your service. You need to do this before you can create new Characteristics. Save now?", preferredStyle: .alert)
            
            // Configure Alert Controller
            alertController.addAction(UIAlertAction(title: "No", style: .cancel, handler: { (_) -> Void in
            }))
            
            alertController.addAction(UIAlertAction(title: "Save", style: .default, handler: { (_) -> Void in
                self.saveDetails()
                self.performSegue( withIdentifier: "toNewCharacteristic", sender: nil )
            }))
            
            // Present Alert Controller
            present(alertController, animated: true, completion: nil)
        } else {
            self.performSegue( withIdentifier: "toNewCharacteristic", sender: nil )
        }
  
    }
    
    @IBAction func primaryAction(_ sender: AnyObject) {
        
        buildService!.primary = primarySwitch.isOn
		setControlState()
    }
    
    @IBAction func makeNewUUIDAction(_ sender: AnyObject) {
        
        let newuuid = UUID.init()
        uuidField.text = newuuid.uuidString
        uuidField.isEnabled = true    // Allows selection
        textFieldBorderSetup( uuidField )
        buildService!.uuid = newuuid.uuidString
		setControlState()
		
    }
    
    func unsavedCancelWarning() {
        
        if saveButton.isEnabled {
            // Initialize Alert Controller
            let alertController = UIAlertController(title: "Warning", message: "Warning. You have made changes to this service. If you return to the device page now you will lose those changes.", preferredStyle: .alert)
            
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
    
    func unsavedEditServiceWarning() {
        
        if saveButton.isEnabled {
            // Initialize Alert Controller
            let alertController = UIAlertController(title: "Warning", message: "You have not saved changes to this service. Save now?", preferredStyle: .alert)
            
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
    
    func textChanged() {
        
        buildService!.name = nameField.text
        setControlState()
    }
    
    func setControlState() {
        
        var needSave = false
        
        if buildService!.isValid() {
            if buildService!.hasChanged() {
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
        
        if let count = buildService?.buildCharacteristics.count , count > 1 {   // Up to one for now
            newCharacteristicButton.isEnabled = false
            addCharacteristicLabel.isEnabled = false
        } else {
            newCharacteristicButton.isEnabled = !needSave
            addCharacteristicLabel.isEnabled = !needSave
        }
        
    }
    
    // MARK: - DeleteButtonDelegate
    
    func deleteCellAt( _ indexPath: IndexPath ) {
        
        let alertController = UIAlertController(title: "Warning", message: "You are about to delete a characteristic from your service. This operation cannot be undone. Continue?", preferredStyle: .alert)
        
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
        
        buildService!.removeCharacteristicAtIndex( (indexPath as NSIndexPath).row )
        builder!.saveService( buildService! )
        collectionView.deleteItems( at: [indexPath] )
        saveDetails()
    }
    
    // MARK: - State methods
    
    func unsavedEditWarningThenCharacteristic() {
        
        if saveButton.isEnabled {
            // Initialize Alert Controller
            let alertController = UIAlertController(title: "Warning", message: "You have not saved changes to this service. Save now?", preferredStyle: .alert)
            
            // Configure Alert Controller
            alertController.addAction(UIAlertAction(title: "No", style: .cancel, handler: { (_) -> Void in
                self.performSegue( withIdentifier: "toEditCharacteristic", sender: nil )
            }))
            
            alertController.addAction(UIAlertAction(title: "Save", style: .default, handler: { (_) -> Void in
                self.saveDetails()
                self.performSegue( withIdentifier: "toEditCharacteristic", sender: nil )
            }))
            
            // Present Alert Controller
            present(alertController, animated: true, completion: nil)
        } else {
            self.performSegue( withIdentifier: "toEditCharacteristic", sender: nil )
        }
    }
    

    // MARK: - Control actions
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        builder!.currentService = buildService
        navigationItem.title = "Service"
        if segue.identifier == "toNewCharacteristic" {
            let dest = segue.destination as! buildCharacteristicVC
            dest.buildCharacteristic = nil
            Log.debug("dest.buildCharacteristic will be nil")
        } else if segue.identifier == "toEditCharacteristic" {
            let dest = segue.destination as! buildCharacteristicVC
            if let indexPaths = collectionView.indexPathsForSelectedItems , indexPaths.count > 0 {
                dest.buildCharacteristic = buildService!.buildCharacteristics[(indexPaths.first! as NSIndexPath).item]
                Log.debug("dest.buildCharacteristic will be a BuildCharacteristics instance")
            }
        }
    }
    
    func permissionsToString( _ permissions: CBAttributePermissions ) -> String {
        
        var pStr = ""
        if permissions.contains( .readable ) {
            pStr += "Rd"
        }
        if permissions.contains( .writeable ) {
            if pStr != "" { pStr += ", " }
            pStr += "Wr"
        }
        if permissions.contains( .readEncryptionRequired ) {
            if pStr != "" { pStr += ", " }
            pStr += "RdEn"
        }
        if permissions.contains( .writeEncryptionRequired ) {
            if pStr != "" { pStr += ", " }
            pStr += "WrEn"
        }
        
        return pStr
    }
    
    func propertiesToString( _ properties: CBCharacteristicProperties ) -> String {
        
        var pStr = ""
        if properties.contains( .read ) {
            pStr += "Rd"
        }
        if properties.contains( .writeWithoutResponse ) {
            if pStr != "" { pStr += ", " }
            pStr += "Wr"
        }
        if properties.contains( .authenticatedSignedWrites ) {
            if pStr != "" { pStr += ", " }
            pStr += "WrAu"
        }
        if properties.contains( .write ) {
            if pStr != "" { pStr += ", " }
            pStr += "WrwR"
        }
        if properties.contains( .notify ) {
            if pStr != "" { pStr += ", " }
            pStr += "No"
        }
        if properties.contains( .indicate ) {
            if pStr != "" { pStr += ", " }
            pStr += "In"
        }
        if properties.contains( .notifyEncryptionRequired ) {
            if pStr != "" { pStr += ", " }
            pStr += "NoEn"
        }
        if properties.contains( .indicateEncryptionRequired ) {
            if pStr != "" { pStr += ", " }
            pStr += "InEn"
        }
        return pStr
    }

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
    
        return buildService!.buildCharacteristics.count
    }
    
    func collectionView( _ collectionView: UICollectionView,
                          cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {

        let cell = collectionView.dequeueReusableCell( withReuseIdentifier: "CharacteristicSummary", for: indexPath ) as! CharacteristicCollectionViewCell

        let buildCharacteristic = buildService!.buildCharacteristics[ (indexPath as NSIndexPath).row ]

        cell.uuidLabel.text = buildCharacteristic.uuid
        if let valueData = buildCharacteristic.value {
            let nsString = NSString(data: valueData as Data, encoding: String.Encoding.utf8.rawValue)!
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
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        unsavedEditWarningThenCharacteristic()
    }
    

    func collectionView(_ collectionView: UICollectionView, layout: UICollectionViewLayout, sizeForItemAt sizeForItemAtIndexPath: IndexPath) -> CGSize {
        
		return CGSize( width: collectionView.frame.size.width, height: 120.0 )
    }

}
