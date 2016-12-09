//
//  buildCharacteristicVC.swift
//  able2
//
//  Created by William Snook on 7/24/16.
//  Copyright © 2016 William Snook. All rights reserved.
//

//import Foundation
import UIKit
import CoreBluetooth


class buildCharacteristicVC: UIViewController,
//            UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout,
            UITextFieldDelegate {
    
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    @IBOutlet weak var infoDetailButton: UIButton!
    
    @IBOutlet weak var uuidField: UITextField!
    @IBOutlet weak var uuidButton: UIButton!
    @IBOutlet weak var valueView: UITextView!
    
    @IBOutlet weak var permReadSwitch: UISwitch!
    @IBOutlet weak var permWriteSwitch: UISwitch!
    @IBOutlet weak var permReadWithEncryptionSwitch: UISwitch!
    @IBOutlet weak var permWriteWithEncryptionSwitch: UISwitch!

    @IBOutlet weak var propReadSwitch: UISwitch!
    @IBOutlet weak var propWriteSwitch: UISwitch!
    @IBOutlet weak var propAuthenticateSwitch: UISwitch!
    @IBOutlet weak var propWriteWithResponseSwitch: UISwitch!
    
    @IBOutlet weak var propNotifySwitch: UISwitch!
    @IBOutlet weak var propIndicateSwitch: UISwitch!
    @IBOutlet weak var propNotifyWithEncryptionSwitch: UISwitch!
    @IBOutlet weak var propIndicateWithEncryptionSwitch: UISwitch!

    var builder: Builder?
    var buildCharacteristic: BuildCharacteristic?

    var newBackButton: UIBarButtonItem?
    
    var displayState = DisplayState.neutral
    
    var basicInfoState = true
    
    
    //--    ----    ----    ----
    
    // MARK: - Lifecycle events
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        Log.debug("")

        builder = Builder.sharedBuilder
        if nil == buildCharacteristic {
            buildCharacteristic = BuildCharacteristic( fromCharacteristic: nil )
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear( animated )
        
        Log.debug("")
        
        navigationItem.title = "Characteristic"
        
        uuidField.text = buildCharacteristic!.uuid
        uuidField.inputView = UIView.init( frame: CGRect.zero );    // No keyboard
        valueView.text = buildCharacteristic!.valueString
        permissionsToControls( buildCharacteristic!.permissions! )
        propertiesToControls( buildCharacteristic!.properties! )
        
        textFieldBorderSetup(uuidField)
        
        setControlState()
        
    }
    
    // MARK: - Control actions
    
    @IBAction func saveAction(_ sender: AnyObject) {
        
//        guard buildCharacteristic != nil else { Log.info( "save failed" ); return }
        
        saveDetails()
    }
    
    func saveDetails() {
        
        // Gather and save data from fields and create characteristic
        buildCharacteristic!.uuid = uuidField.text
        buildCharacteristic!.valueString = valueView.text
        buildCharacteristic!.permissions = controlsToPermissions()
        buildCharacteristic!.properties = controlsToProperties()
        Log.debug("")
        builder!.saveCharacteristic( buildCharacteristic! )
        setControlState()
    }
    
    
    @IBAction func makeNewUUIDAction(_ sender: AnyObject) {
        
        let newuuid = UUID.init()
        uuidField.text = newuuid.uuidString
        uuidField.isEnabled = true    // Allows selection
        textFieldBorderSetup( uuidField )
        buildCharacteristic!.uuid = newuuid.uuidString
        setControlState()
        
    }
    
    func unsavedCancelWarning() {
        
        if saveButton.isEnabled {
            // Initialize Alert Controller
            let alertController = UIAlertController(title: "Warning", message: "Warning. You have made changes to this characteristic. If you return to the service page now you will lose those changes.", preferredStyle: .alert)
            
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
    
    func textChanged() {
        
        buildCharacteristic?.valueString = valueView.text
        setControlState()
    }
    
    func setControlState() {
        
        var needSave = false
        
        if buildCharacteristic!.isValid() {
            if buildCharacteristic!.hasChanged() {
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

    }
    
    // MARK: - State methods
    
    func setControlsEnabled( _ enabled: Bool ) {
        
        uuidField.isEnabled = enabled
        uuidButton.isEnabled = enabled
        valueView.isEditable = enabled
        
        permReadSwitch.isEnabled = enabled
        permWriteSwitch.isEnabled = enabled
        permReadWithEncryptionSwitch.isEnabled = enabled
        permWriteWithEncryptionSwitch.isEnabled = enabled
        
        propReadSwitch.isEnabled = enabled
        propWriteSwitch.isEnabled = enabled
        propAuthenticateSwitch.isEnabled = enabled
        propWriteWithResponseSwitch.isEnabled = enabled
        propNotifySwitch.isEnabled = enabled
        propIndicateSwitch.isEnabled = enabled
        propNotifyWithEncryptionSwitch.isEnabled = enabled
        propIndicateWithEncryptionSwitch.isEnabled = enabled
    }
    
    func stateDidChange() {
        
        setControlState()
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
    
    func textViewBorderSetup( _ textView: (UITextView) ) {
        
        if let text = textView.text {
            if text.isEmpty {
                setTVBorderOf( textView, toDisplayState: .invalid )
            } else {
                setTVBorderOf( textView, toDisplayState: .valid )
            }
        } else {
            setTVBorderOf( textView, toDisplayState: .neutral )
        }
    }
    
    func setTVBorderOf( _ textView: (UITextView), toDisplayState: (DisplayState) ) {
        
        textView.layer.borderWidth = 0.5
        textView.layer.cornerRadius = 6.0
        switch toDisplayState {
        case .neutral:
            textView.layer.borderColor = UIColor.lightGray.cgColor
        case .valid:
            textView.layer.borderColor = UIColor.green.cgColor
        case .invalid:
            textView.layer.borderColor = UIColor.red.cgColor
        }
        
    }
    
    // MARK: - Set Switches
    
    func permissionsToControls( _ permissions: CBAttributePermissions ) {
        
        permReadSwitch.isOn = permissions.contains( .readable )
        permWriteSwitch.isOn = permissions.contains( .writeable )
        permReadWithEncryptionSwitch.isOn = permissions.contains( .readEncryptionRequired )
        permWriteWithEncryptionSwitch.isOn = permissions.contains( .writeEncryptionRequired )

    }
    
    func propertiesToControls( _ properties: CBCharacteristicProperties ) {
        
        propReadSwitch.isOn = properties.contains( .read )
        propWriteSwitch.isOn = properties.contains( .writeWithoutResponse )
        propAuthenticateSwitch.isOn = properties.contains( .authenticatedSignedWrites )
        propWriteWithResponseSwitch.isOn = properties.contains( .write )
        
        propNotifySwitch.isOn = properties.contains( .notify )
        propIndicateSwitch.isOn = properties.contains( .indicate )
        propNotifyWithEncryptionSwitch.isOn = properties.contains( .notifyEncryptionRequired )
        propIndicateWithEncryptionSwitch.isOn = properties.contains( .indicateEncryptionRequired )
        
    }
    
    
    // MARK: - Read Switches
    
    func controlsToPermissions() -> CBAttributePermissions {
        
        var permissions = CBAttributePermissions()
        if permReadSwitch.isOn {
            permissions.insert( .readable )
        }
        if permWriteSwitch.isOn {
            permissions.insert( .writeable )
        }
        if permReadWithEncryptionSwitch.isOn {
            permissions.insert( .readEncryptionRequired )
        }
        if permWriteWithEncryptionSwitch.isOn {
            permissions.insert( .writeEncryptionRequired )
        }
        return permissions
    }
    
    func controlsToProperties() -> CBCharacteristicProperties {
        
        var properties = CBCharacteristicProperties()
        if propReadSwitch.isOn {
            properties.insert( .read )
        }
        if propWriteSwitch.isOn {
            properties.insert( .writeWithoutResponse )
        }
        if propAuthenticateSwitch.isOn {
            properties.insert( .authenticatedSignedWrites )
        }
        if propWriteWithResponseSwitch.isOn {
            properties.insert( .write )
        }
        if propNotifySwitch.isOn {
            properties.insert( .notify )
        }
        if propIndicateSwitch.isOn {
            properties.insert( .indicate )
        }
        if propNotifyWithEncryptionSwitch.isOn {
            properties.insert( .notifyEncryptionRequired )
        }
        if propIndicateWithEncryptionSwitch.isOn {
            properties.insert( .indicateEncryptionRequired )
        }
        return properties
    }
    
    // MARK: - UITextFieldDelegate
    
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        
        return false	// false because uuidField should never allow changes to its text
    }
    
    func textFieldDidEndEditing(_ textField: (UITextField)) {
        
        textFieldBorderSetup( textField )
    }

    // MARK: - UITextViewDelegate - uuidField
    
    func textView(_ textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        
        var displayState = DisplayState.neutral
        if let viewText = textView.text {
            let nonEmptyText = !viewText.isEmpty && ( range.length != viewText.characters.count )
            let nonEmptyReplacement = !text.isEmpty
            if nonEmptyReplacement || nonEmptyText {
                displayState = .valid
            }
        }
        setTVBorderOf( textView, toDisplayState: displayState )
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + Double(Int64(0.1 * Double(NSEC_PER_SEC))) / Double(NSEC_PER_SEC), execute: {
            self.textChanged()
        })
        return true
    }
    
    func textViewDidEndEditing(_ textView: (UITextView)) {
        
//        textFieldBorderSetup( textField )
//        let nsString = textView.text as NSString
//?        valueView.text = nsString //.dataUsingEncoding(NSUTF8StringEncoding)!
        stateDidChange()
    }
    
    // MARK: - Changing entitys
    
    @IBAction func permissionControl(_ sender: UISwitch) {
        
        buildCharacteristic!.permissions = controlsToPermissions()
        stateDidChange()
    }
    
    @IBAction func propertiesChanged(_ sender: UISwitch) {
        
        buildCharacteristic!.properties = controlsToProperties()
        stateDidChange()
    }
    
}
