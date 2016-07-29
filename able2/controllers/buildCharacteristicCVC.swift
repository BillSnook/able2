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
    
    var displayState = DisplayState.Neutral
    
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
    
    override func viewWillAppear(animated: Bool) {
        
        super.viewWillAppear( animated )
        
        Log.debug("")
        
        navigationItem.title = "Characteristic"
        
        uuidField.text = buildCharacteristic!.uuid
        uuidField.inputView = UIView.init( frame: CGRectZero );    // No keyboard
        valueView.text = buildCharacteristic!.valueString
        permissionsToControls( buildCharacteristic!.permissions! )
        propertiesToControls( buildCharacteristic!.properties! )
        
        textFieldBorderSetup(uuidField)
        
        setControlState()
        
    }
    
    // MARK: - Control actions
    
    @IBAction func saveAction(sender: AnyObject) {
        
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
    
    
    @IBAction func makeNewUUIDAction(sender: AnyObject) {
        
        let newuuid = NSUUID.init()
        uuidField.text = newuuid.UUIDString
        uuidField.enabled = true    // Allows selection
        textFieldBorderSetup( uuidField )
        buildCharacteristic!.uuid = newuuid.UUIDString
        setControlState()
        
    }
    
    func unsavedCancelWarning() {
        
        if saveButton.enabled {
            // Initialize Alert Controller
            let alertController = UIAlertController(title: "Warning", message: "Warning. You have made changes to this characteristic. If you return to the service page now you will lose those changes.", preferredStyle: .Alert)
            
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
    
    func textChanged() {
        
        buildCharacteristic?.valueString = valueView.text
        setControlState()
    }
    
    func setControlState() {
        
        var needSave = false
        
        if buildCharacteristic!.isValid() {
            if buildCharacteristic!.hasChanged() {
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

    }
    
    // MARK: - State methods
    
    func setControlsEnabled( enabled: Bool ) {
        
        uuidField.enabled = enabled
        uuidButton.enabled = enabled
        valueView.editable = enabled
        
        permReadSwitch.enabled = enabled
        permWriteSwitch.enabled = enabled
        permReadWithEncryptionSwitch.enabled = enabled
        permWriteWithEncryptionSwitch.enabled = enabled
        
        propReadSwitch.enabled = enabled
        propWriteSwitch.enabled = enabled
        propAuthenticateSwitch.enabled = enabled
        propWriteWithResponseSwitch.enabled = enabled
        propNotifySwitch.enabled = enabled
        propIndicateSwitch.enabled = enabled
        propNotifyWithEncryptionSwitch.enabled = enabled
        propIndicateWithEncryptionSwitch.enabled = enabled
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
    
    func textViewBorderSetup( textView: (UITextView) ) {
        
        if let text = textView.text {
            if text.isEmpty {
                setTVBorderOf( textView, toDisplayState: .Invalid )
            } else {
                setTVBorderOf( textView, toDisplayState: .Valid )
            }
        } else {
            setTVBorderOf( textView, toDisplayState: .Neutral )
        }
    }
    
    func setTVBorderOf( textView: (UITextView), toDisplayState: (DisplayState) ) {
        
        textView.layer.borderWidth = 0.5
        textView.layer.cornerRadius = 6.0
        switch toDisplayState {
        case .Neutral:
            textView.layer.borderColor = UIColor.lightGrayColor().CGColor
        case .Valid:
            textView.layer.borderColor = UIColor.greenColor().CGColor
        case .Invalid:
            textView.layer.borderColor = UIColor.redColor().CGColor
        }
        
    }
    
    // MARK: - Set Switches
    
    func permissionsToControls( permissions: CBAttributePermissions ) {
        
        permReadSwitch.on = permissions.contains( .Readable )
        permWriteSwitch.on = permissions.contains( .Writeable )
        permReadWithEncryptionSwitch.on = permissions.contains( .ReadEncryptionRequired )
        permWriteWithEncryptionSwitch.on = permissions.contains( .WriteEncryptionRequired )

    }
    
    func propertiesToControls( properties: CBCharacteristicProperties ) {
        
        propReadSwitch.on = properties.contains( .Read )
        propWriteSwitch.on = properties.contains( .WriteWithoutResponse )
        propAuthenticateSwitch.on = properties.contains( .AuthenticatedSignedWrites )
        propWriteWithResponseSwitch.on = properties.contains( .Write )
        
        propNotifySwitch.on = properties.contains( .Notify )
        propIndicateSwitch.on = properties.contains( .Indicate )
        propNotifyWithEncryptionSwitch.on = properties.contains( .NotifyEncryptionRequired )
        propIndicateWithEncryptionSwitch.on = properties.contains( .IndicateEncryptionRequired )
        
    }
    
    
    // MARK: - Read Switches
    
    func controlsToPermissions() -> CBAttributePermissions {
        
        var permissions = CBAttributePermissions()
        if permReadSwitch.on {
            permissions.insert( .Readable )
        }
        if permWriteSwitch.on {
            permissions.insert( .Writeable )
        }
        if permReadWithEncryptionSwitch.on {
            permissions.insert( .ReadEncryptionRequired )
        }
        if permWriteWithEncryptionSwitch.on {
            permissions.insert( .WriteEncryptionRequired )
        }
        return permissions
    }
    
    func controlsToProperties() -> CBCharacteristicProperties {
        
        var properties = CBCharacteristicProperties()
        if propReadSwitch.on {
            properties.insert( .Read )
        }
        if propWriteSwitch.on {
            properties.insert( .WriteWithoutResponse )
        }
        if propAuthenticateSwitch.on {
            properties.insert( .AuthenticatedSignedWrites )
        }
        if propWriteWithResponseSwitch.on {
            properties.insert( .Write )
        }
        if propNotifySwitch.on {
            properties.insert( .Notify )
        }
        if propIndicateSwitch.on {
            properties.insert( .Indicate )
        }
        if propNotifyWithEncryptionSwitch.on {
            properties.insert( .NotifyEncryptionRequired )
        }
        if propIndicateWithEncryptionSwitch.on {
            properties.insert( .IndicateEncryptionRequired )
        }
        return properties
    }
    
    // MARK: - UITextFieldDelegate
    
    func textField(textField: UITextField, shouldChangeCharactersInRange range: NSRange, replacementString string: String) -> Bool {
        
        return false	// false because uuidField should never allow changes to its text
    }
    
    func textFieldDidEndEditing(textField: (UITextField)) {
        
        textFieldBorderSetup( textField )
    }

    // MARK: - UITextViewDelegate - uuidField
    
    func textView(textView: UITextView, shouldChangeTextInRange range: NSRange, replacementText text: String) -> Bool {
        
        var displayState = DisplayState.Neutral
        if let viewText = textView.text {
            let nonEmptyText = !viewText.isEmpty && ( range.length != viewText.characters.count )
            let nonEmptyReplacement = !text.isEmpty
            if nonEmptyReplacement || nonEmptyText {
                displayState = .Valid
            }
        }
        setTVBorderOf( textView, toDisplayState: displayState )
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(0.1 * Double(NSEC_PER_SEC))), dispatch_get_main_queue(), {
            self.textChanged()
        })
        return true
    }
    
    func textViewDidEndEditing(textView: (UITextView)) {
        
//        textFieldBorderSetup( textField )
//        let nsString = textView.text as NSString
//?        valueView.text = nsString //.dataUsingEncoding(NSUTF8StringEncoding)!
        stateDidChange()
    }
    
    // MARK: - Changing entitys
    
    @IBAction func permissionControl(sender: UISwitch) {
        
        buildCharacteristic!.permissions = controlsToPermissions()
        stateDidChange()
    }
    
    @IBAction func propertiesChanged(sender: UISwitch) {
        
        buildCharacteristic!.properties = controlsToProperties()
        stateDidChange()
    }
    
}
