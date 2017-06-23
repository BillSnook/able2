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


class listPeripheralsTVC : UITableViewController, NSFetchedResultsControllerDelegate {
    
    var managedObjectContext: NSManagedObjectContext? = nil
    
    lazy var fetchedResultsController: NSFetchedResultsController = { () -> NSFetchedResultsController<Peripheral> in
        let fetchRequest: NSFetchRequest<Peripheral> = NSFetchRequest( entityName: "Peripheral" )
        let sortDescriptor = NSSortDescriptor(key: "name", ascending: true)
        fetchRequest.sortDescriptors = [sortDescriptor]

        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        let managedObjectContext = appDelegate!.managedObjectContext
        let fetchedResultsController = NSFetchedResultsController( fetchRequest: fetchRequest, managedObjectContext: managedObjectContext, sectionNameKeyPath: nil, cacheName: nil )
//        fetchedResultsController.delegate = self
        
        return fetchedResultsController
    }()

    var scanner: Scanner = Scanner.sharedScanner
    var timer = Timer()
    

	
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let userDefaults = UserDefaults.standard
        let didDetectIncompatibleStore = userDefaults.bool(forKey: "didDetectIncompatibleStore")
        if didDetectIncompatibleStore {
            // Show Alert
            let applicationName = Bundle.main.object(forInfoDictionaryKey: "CFBundleDisplayName")
            let message = "A serious application error occurred while \(applicationName ?? "<missing app name>") tried to read your data. Please contact support for help."
            self.showAlertWithTitle("Warning", message: message, cancelButtonTitle: "OK")
        }
    
		let appDelegate = UIApplication.shared.delegate as? AppDelegate
		managedObjectContext = appDelegate!.managedObjectContext
//        DLog.trace( "viewDidLoad, listPeripheralsTVC, managedObjectContext: \(managedObjectContext)")
        do {
            try self.fetchedResultsController.performFetch()
        } catch let error as NSError {
            DLog.error("Could not fetch \(error), \(error.userInfo)")
        }

        self.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem
        self.navigationItem.leftItemsSupplementBackButton = true

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear( animated )
		
        scanner.managedObjectContext = managedObjectContext
		scanner.startScan()
        runTimer()
		
        tableView.reloadData()
    }
    
    
    override func viewWillDisappear(_ animated: Bool) {

		scanner.stopScan()

        super.viewWillDisappear( animated )
    }
    
//    deinit {
//    }
    
    
// MARK: - Helper Methods
    
    fileprivate func showAlertWithTitle(_ title: String, message: String, cancelButtonTitle: String) {
        // Initialize Alert Controller
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        // Configure Alert Controller
        alertController.addAction(UIAlertAction(title: cancelButtonTitle, style: .default, handler: { (_) -> Void in
            let userDefaults = UserDefaults.standard
            userDefaults.removeObject(forKey: "didDetectIncompatibleStore")
        }))
        
        // Present Alert Controller
        present(alertController, animated: true, completion: nil)
    }
    
    
    fileprivate func showDeleteAlertWithTitle(_ title: String, message: String, cancelButtonTitle: String) {
        // Initialize Alert Controller
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        // Configure Alert Controller
        alertController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        
        alertController.addAction(UIAlertAction(title: "OK", style: .destructive, handler: { (_) -> Void in
            self.doDeleteOperation()
        }))
        
        // Present Alert Controller
        present(alertController, animated: true, completion: nil)
    }
    
    
    // MARK: - Fetched Results Controller delegate methods
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    func controller( _ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath? ) {
        
        switch (type) {
        case .insert:
            if let indexPath = newIndexPath {
                tableView.insertRows( at: [indexPath], with: .fade )
            }
        case .delete:
            if let indexPath = indexPath {
                tableView.deleteRows( at: [indexPath], with: .fade )
            }
        case .update:
            if let indexPath = indexPath {
//                DLog.trace( "didChangeObject, Update at indexPath section: \(indexPath.section), row: \(indexPath.row)" )
                if let cell = tableView.dequeueReusableCell( withIdentifier: "peripheralCell", for: indexPath ) as? PeripheralCell {
                    configureCell( cell, atIndexPath: indexPath )
                }
            }
        case .move:
            if let indexPath = indexPath {
                tableView.deleteRows( at: [indexPath], with: .fade )
            }
            if let newIndexPath = newIndexPath {
                tableView.insertRows( at: [newIndexPath], with: .fade )
            }

        }
        
    }
    
    
// MARK: - TableView support
    
    func configureCell( _ cell: PeripheralCell, atIndexPath indexPath: IndexPath ) {
        let peripheralEntity = fetchedResultsController.object(at: indexPath)
        cell.peripheralName.text = cleanName( peripheralEntity.name! )
        cell.peripheralIdentifier.text = peripheralEntity.mainUUID
        
        let sightings = peripheralEntity.sightings as! Set<Sighting>?
        var timeStamp: TimeInterval = 0
        var recentSighting: Sighting?
//        DLog.trace("set count: \(sightings!.count)" )
        for sighting in sightings! {
            let timeValue = sighting.date!.timeIntervalSince1970
//            DLog.trace("timeValue: \(timeValue)" )
            if timeValue > timeStamp {
                timeStamp = timeValue
                recentSighting = sighting
            }
        }
        var rssi: Int16 = 0
        if let foundSighting = recentSighting {
            rssi = foundSighting.rssi!.int16Value
            
            let now = Date().timeIntervalSince1970
            let minute = 60.0
            let tenMinute = minute * 10
            let hour = minute * 60.0
            let day = hour * 24.0
            
            if timeStamp + day > now {
                if timeStamp + hour > now {
                    if timeStamp + tenMinute > now {
                        if timeStamp + minute > now {
                            cell.peripheralRSSI.textColor = UIColor.green    // Last minute
                        } else {
                            cell.peripheralRSSI.textColor = UIColor.cyan     // Last 10 minutes
                        }
                    } else {
                        cell.peripheralRSSI.textColor = UIColor.orange       // Last hour
                    }
                } else {
                    cell.peripheralRSSI.textColor = UIColor.magenta          // Last day
                }
            } else {
                cell.peripheralRSSI.textColor = UIColor.red                  // Over a day
            }
        } else {
            rssi = peripheralEntity.rssi!.int16Value
            cell.peripheralRSSI.textColor = UIColor.black                    // Unknown
        }
        
        if ( rssi == 127 ) {
            cell.peripheralRSSI.text = "---"
        } else {
            cell.peripheralRSSI.text = String( rssi )
        }
        
        cell.accessoryType = .none;
        if peripheralEntity.connectable != nil {
            if peripheralEntity.connectable!.boolValue {
                cell.accessoryType = .disclosureIndicator
            }
        }
    }
    
    func runTimer() {
        timer = Timer.scheduledTimer(timeInterval: 2, target: self, selector: (#selector(self.updateTimer)), userInfo: nil, repeats: true)
    }
    
    func updateTimer() {
        if scanner.scanRunning {
            tableView.reloadData()
        } else {
            timer.invalidate()
        }
    }

    
// MARK: - Segues
    
    override func shouldPerformSegue(withIdentifier: String, sender: Any?) -> Bool {
        if withIdentifier == "toServices" {
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let peripheral = self.fetchedResultsController.object(at: indexPath)
                if peripheral.connectable != nil {
                    if peripheral.connectable!.boolValue {
                        return true
                    }
                    self.tableView.deselectRow(at: indexPath, animated: true)
                }
                return false
            }
        }
        return true
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "toServices" {
//            DLog.info( "Segue toServices" )
            scanner.stopScan()
            if let indexPath = self.tableView.indexPathForSelectedRow {
                let peripheral = self.fetchedResultsController.object(at: indexPath)
                let controller = segue.destination as! ListServicesTVC
                controller.perp = peripheral
            }
        }
    }
    
    @IBAction func clearData(_ sender: UIBarButtonItem) {
        
        let message = "You are about to delete all your stored info on Bluetooth devices that you have seen. Are you sure?"
        self.showDeleteAlertWithTitle("Warning", message: message, cancelButtonTitle: "OK")
    }
    
    fileprivate func doDeleteOperation() {
//        DLog.trace( "doDeleteOperation" )
        scanner.stopScan()
        fetchedResultsController.delegate = nil

        let appDelegate = UIApplication.shared.delegate as? AppDelegate
        appDelegate?.deleteAllPeripherals()

        fetchedResultsController.delegate = self
        do {
            try self.fetchedResultsController.performFetch()
        } catch let error as NSError {
            DLog.error("Could not fetch \(error), \(error.userInfo)")
        }

        tableView.reloadData()
        scanner.startScan()
        runTimer()
    }
    
// MARK: - Table view data source
    
    override func numberOfSections( in tableView: UITableView ) -> Int {
        // Return the number of rows in the section.
        if let sections = fetchedResultsController.sections {
            return sections.count
        }
        return 0
    }
    
    override func tableView( _ tableView: UITableView, numberOfRowsInSection section: NSInteger ) -> NSInteger {
        // Return the number of rows in the section.
        if let sections = fetchedResultsController.sections {
            let sectionInfo = sections[section]
            return sectionInfo.numberOfObjects
        }
        return 0
    }
    
    override func tableView( _ tableView: UITableView, heightForRowAt indexPath: IndexPath ) -> CGFloat {
        return 66.0
    }
    
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath ) -> UITableViewCell {
        let peripheralCell = tableView.dequeueReusableCell( withIdentifier: "peripheralCell", for: indexPath ) as! PeripheralCell
        
        configureCell( peripheralCell, atIndexPath: indexPath )
        
        return peripheralCell;
    }

    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let peripheralEntity = fetchedResultsController.object(at: indexPath) 
            managedObjectContext?.delete(peripheralEntity)
        }
    }
    
}
