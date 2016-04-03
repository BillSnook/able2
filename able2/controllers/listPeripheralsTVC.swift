//
//  listPeripheralsTVC.swift
//  able2
//
//  Created by William Snook on 3/28/16.
//  Copyright © 2016 William Snook. All rights reserved.
//

import Foundation
import UIKit

import CoreData


class listPeripheralsTVC : UITableViewController, SubstitutableDetailViewProtocol, NSFetchedResultsControllerDelegate {
    
    var navigationPaneBarButtonItem: UIBarButtonItem?

    var appDelegate: AppDelegate?
    var managedObjectContext: NSManagedObjectContext? = nil
    
    lazy var fetchedResultsController: NSFetchedResultsController = {
        let fetchRequest = NSFetchRequest( entityName: "Peripheral" )
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]

        let fetchedResultsController = NSFetchedResultsController( fetchRequest: fetchRequest, managedObjectContext: self.managedObjectContext!, sectionNameKeyPath: nil, cacheName: nil )
        fetchedResultsController.delegate = self
        
        return fetchedResultsController
    }()

    var scanner: Scanner = Scanner.sharedInstance

    override func viewDidLoad() {
        super.viewDidLoad()
        
        scanner.startScan()
        
        let userDefaults = NSUserDefaults.standardUserDefaults()
        let didDetectIncompatibleStore = userDefaults.boolForKey("didDetectIncompatibleStore")
        if didDetectIncompatibleStore {
            // Show Alert
            let applicationName = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleDisplayName")
            let message = "A serious application error occurred while \(applicationName) tried to read your data. Please contact support for help."
            self.showAlertWithTitle("Warning", message: message, cancelButtonTitle: "OK")
        }
    
        managedObjectContext = (UIApplication.sharedApplication().delegate as! AppDelegate).managedObjectContext
//        print( "viewDidLoad, listPeripheralsTVC, managedObjectContext: \(managedObjectContext)")
        do {
            try self.fetchedResultsController.performFetch()
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }

    }

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear( animated )

        appDelegate = UIApplication.sharedApplication().delegate as? AppDelegate
        managedObjectContext = appDelegate!.managedObjectContext
    

        tableView.reloadData()
    }
    
    
    override func viewWillDisappear(animated: Bool) {
    
        super.viewWillDisappear( animated )
    
    }
    
    deinit {
        scanner.stopScan()
    }
    
    
// MARK: - Helper Methods
    
    private func showAlertWithTitle(title: String, message: String, cancelButtonTitle: String) {
        // Initialize Alert Controller
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        
        // Configure Alert Controller
        alertController.addAction(UIAlertAction(title: cancelButtonTitle, style: .Default, handler: { (_) -> Void in
            let userDefaults = NSUserDefaults.standardUserDefaults()
            userDefaults.removeObjectForKey("didDetectIncompatibleStore")
        }))
        
        // Present Alert Controller
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    
    // MARK: - Fetched Results Controller delegate methods
    
    func controllerWillChangeContent(controller: NSFetchedResultsController) {
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(controller: NSFetchedResultsController) {
        tableView.endUpdates()
    }
    
    func controller( controller: NSFetchedResultsController, didChangeObject anObject: AnyObject, atIndexPath indexPath: NSIndexPath?, forChangeType type: NSFetchedResultsChangeType, newIndexPath: NSIndexPath? ) {
        
        switch (type) {
        case .Insert:
            if let indexPath = newIndexPath {
                tableView.insertRowsAtIndexPaths( [indexPath], withRowAnimation: .Fade )
            }
        case .Delete:
            if let indexPath = indexPath {
                tableView.deleteRowsAtIndexPaths( [indexPath], withRowAnimation: .Fade )
            }
        case .Update:
            if let indexPath = indexPath {
//                print( "didChangeObject, Update at indexPath section: \(indexPath.section), row: \(indexPath.row)" )
                if let cell = tableView.dequeueReusableCellWithIdentifier( "peripheralCell", forIndexPath: indexPath ) as? PeripheralCell {
                    configureCell( cell, atIndexPath: indexPath )
                }
//                tableView.reloadData()
            }
        case .Move:
            if let indexPath = indexPath {
                tableView.deleteRowsAtIndexPaths( [indexPath], withRowAnimation: .Fade )
            }
            if let newIndexPath = newIndexPath {
                tableView.insertRowsAtIndexPaths( [newIndexPath], withRowAnimation: .Fade )
            }

        }
        
    }
    
    
// MARK: - TableView support
    
    func configureCell( cell: PeripheralCell, atIndexPath indexPath: NSIndexPath ) {
        let peripheralEntity = fetchedResultsController.objectAtIndexPath(indexPath) as! Peripheral
        let name = peripheralEntity.name
        if ( ( name == nil ) || ( name!.characters.count == 0 ) ) {
            cell.peripheralName.text = "Missing name"
        } else {
            let prefix = name![name!.startIndex]
            if prefix == "~" {
                cell.peripheralName.text = name!.substringFromIndex(name!.startIndex.successor())
            } else {
                cell.peripheralName.text = name
            }
        }
        cell.peripheralIdentifier.text = peripheralEntity.mainUUID
        
        let sightings = peripheralEntity.sightings as! Set<Sighting>?
        var timeStamp: NSTimeInterval = 0
        var recentSighting: Sighting?
//        print("set count: \(sightings!.count)" )
        for sighting in sightings! {
            let timeValue = sighting.date!.timeIntervalSince1970
//            print("timeValue: \(timeValue)" )
            if timeValue > timeStamp {
                timeStamp = timeValue
                recentSighting = sighting
            }
        }
        var rssi: Int16 = 0
        if let foundSighting = recentSighting {
            rssi = foundSighting.rssi!.shortValue
            
            let now = NSDate().timeIntervalSince1970
            let minute = 60.0
            let tenMinute = minute * 10
            let hour = minute * 60.0
            let day = hour * 24.0
            
            if timeStamp + day > now {
                if timeStamp + hour > now {
                    if timeStamp + tenMinute > now {
                        if timeStamp + minute > now {
                            cell.peripheralRSSI.textColor = UIColor.greenColor()    // Last minute
                        } else {
                            cell.peripheralRSSI.textColor = UIColor.cyanColor()     // Last 10 minutes
                        }
                    } else {
                        cell.peripheralRSSI.textColor = UIColor.orangeColor()       // Last hour
                    }
                } else {
                    cell.peripheralRSSI.textColor = UIColor.magentaColor()           // Last day
                }
            } else {
                cell.peripheralRSSI.textColor = UIColor.redColor()                  // Over a day
            }
        } else {
            rssi = peripheralEntity.rssi!.shortValue
            cell.peripheralRSSI.textColor = UIColor.blackColor()                    // Unknown
        }
        
        if ( rssi == 127 ) {
            cell.peripheralRSSI.text = "---"
        } else {
            cell.peripheralRSSI.text = String( rssi )
        }
        
        cell.accessoryType = .None;
        if peripheralEntity.connectable!.boolValue {
            cell.accessoryType = .DisclosureIndicator;
        }
    }
    
// MARK: - Segues
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "toServices" {
            NSLog( "toServices" )
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let peripheral = self.fetchedResultsController.objectAtIndexPath(indexPath) as! Peripheral
                let controller = segue.destinationViewController as! ListServicesTVC
                controller.perp = peripheral
            }
        }
    }
    
    @IBAction func clearData(sender: UIBarButtonItem) {
//        print( "clearData" )
        scanner.stopScan()
        fetchedResultsController.delegate = nil

        appDelegate?.deleteAllPeripherals()

        fetchedResultsController.delegate = self
        do {
            try self.fetchedResultsController.performFetch()
        } catch let error as NSError {
            print("Could not fetch \(error), \(error.userInfo)")
        }

        tableView.reloadData()
        scanner.startScan()
    }
    
// MARK: - Table view data source
    
    override func numberOfSectionsInTableView( tableView: UITableView ) -> Int {
        // Return the number of rows in the section.
        if let sections = fetchedResultsController.sections {
            return sections.count
        }
        return 0
    }
    
    override func tableView( tableView: UITableView, numberOfRowsInSection section: NSInteger ) -> NSInteger {
        // Return the number of rows in the section.
        if let sections = fetchedResultsController.sections {
            let sectionInfo = sections[section]
//            if sectionInfo.numberOfObjects == 0 {
//                return 1
//            } else {
                return sectionInfo.numberOfObjects
//            }
        }
        return 0
    }
    
    override func tableView( tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath ) -> CGFloat {
    
//        if let sections = fetchedResultsController.sections {
//            let sectionInfo = sections[indexPath.section]
//            if sectionInfo.numberOfObjects > 0 {
                return 66.0
//            }
//        }
//        return 44.0
    }
    
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath ) -> UITableViewCell {
    
        // Configure the cell...
// Display message if no entries exist
//        if let sections = fetchedResultsController.sections {
//            let sectionInfo = sections[indexPath.section]
//            if sectionInfo.numberOfObjects == 0 {
//                let cell = tableView.dequeueReusableCellWithIdentifier( "messageCell", forIndexPath: indexPath )
//                cell.textLabel?.text = "No peripherals detected"
//                return cell
//            }
//        }
        // Found a peripheral entry
        let peripheralCell = tableView.dequeueReusableCellWithIdentifier( "peripheralCell", forIndexPath: indexPath ) as! PeripheralCell
        
        configureCell( peripheralCell, atIndexPath: indexPath )
        
        return peripheralCell;
    }

    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        return true
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            let peripheralEntity = fetchedResultsController.objectAtIndexPath(indexPath) as! Peripheral
            managedObjectContext?.deleteObject(peripheralEntity)
        }
    }
    
}