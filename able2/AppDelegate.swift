//
//  AppDelegate.swift
//  able2
//
//  Created by William Snook on 3/25/16.
//  Copyright © 2016 William Snook. All rights reserved.
//

import Foundation
import UIKit
import CoreData
import Log


extension Formatters {
    static let Constrained = Formatter("[%@] %@ | %@.%@:%@\t\t%@", [
        .Date("HH:mm:ss.SSS"),
        .Level,
        .File(fullPath: false, fileExtension: false),
        .Function,
        .Line,
        .Message
        ])
}

extension Themes {
    static let MobileForming = Theme(
        trace:   "#AAAAAA",
        debug:   "#44AAAA",
        info:    "#44CC44",
        warning: "#CC6666",
        error:   "#EE4444"
    )
}

func bluetoothUUID( uuidString: String ) -> String {
    if let name = bluetoothNames[uuidString] {
        return name
    } else {
        return uuidString
    }
}

func cleanName( name: String? ) -> String {
    
    guard name != nil else {
        return "Name nil"
    }
    guard name!.characters.count != 0 else {
        return "No name"
    }
    let prefix = name![name!.startIndex]
    if prefix == "~" {
        return name!.substringFromIndex(name!.startIndex.successor())
    } else {
        return name!
    }
}


let Log = Logger( formatter: .Constrained, theme: .MobileForming )

var bluetoothNames = Dictionary<String, String>()


@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, UISplitViewControllerDelegate {

    var window: UIWindow?

    var navigationPaneButtonItem: UIBarButtonItem?
    
    var splitViewController: UISplitViewController?

    var savedNavigationController: UINavigationController?

    
    required override init() {
        
        super.init()
        
        Log.trace( "Starting up" )
        
    }
    
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Override point for customization after application launch.
        
        bluetoothNames["180A"] = "Device Information"
        bluetoothNames["2A24"] = "Model Number String"
        bluetoothNames["2A25"] = "Serial Number String"
        bluetoothNames["2A26"] = "Firmware Revision String"
        bluetoothNames["2A27"] = "Hardware Revision String"
        bluetoothNames["2A28"] = "Software Revision String"
        bluetoothNames["2A29"] = "Manufacturer Name String"
        
        bluetoothNames["8667556C-9A37-4C91-84ED-54EE27D90049"] = "Continuity"
        bluetoothNames["D0611E78-BBB4-4591-A5F8-487910AE4366"] = "Continuity"

        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        self.saveManagedObjectContext()
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveManagedObjectContext()
    }
    
    // MARK: - Core Data stack

    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.billsnook.testx.able2" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1]
    }()

    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource("able2", withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
//        return NSManagedObjectModel.mergedModelFromBundles([NSBundle.mainBundle()])!
    }()

    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let URLPersistentStore = self.applicationDocumentsDirectory.URLByAppendingPathComponent("SingleViewCoreData.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        let options = [ NSMigratePersistentStoresAutomaticallyOption : true, NSInferMappingModelAutomaticallyOption : true ]
        do {
            try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: URLPersistentStore, options: options)
        } catch {
            let fm = NSFileManager.defaultManager()
            
            if fm.fileExistsAtPath(URLPersistentStore.path!) {
                let nameIncompatibleStore = self.nameForIncompatibleStore()
                let URLCorruptPersistentStore = self.applicationIncompatibleStoresDirectory().URLByAppendingPathComponent(nameIncompatibleStore)
                
                do {
                    // Move Incompatible Store
                    try fm.moveItemAtURL(URLPersistentStore, toURL: URLCorruptPersistentStore)
                    
                    do {
                        // Declare Options
//                        let options = [ NSMigratePersistentStoresAutomaticallyOption : true, NSInferMappingModelAutomaticallyOption : true ]
                        
                        // Add Persistent Store to Persistent Store Coordinator
                        try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: URLPersistentStore, options: options)
                        
                    } catch {
                        let storeError = error as NSError
                        print("\(storeError), \(storeError.userInfo)")
                        // Update User Defaults
                        let userDefaults = NSUserDefaults.standardUserDefaults()
                        userDefaults.setBool(true, forKey: "didDetectIncompatibleStore")                    }
                } catch {
                    let moveError = error as NSError
                    print("\(moveError), \(moveError.userInfo)")
                }
            }
        }
        
        return coordinator
    }()

    lazy var managedObjectContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()

    // MARK: - Core Data Saving support

    func saveManagedObjectContext () {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                let nserror = error as NSError
                NSLog("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    private func applicationStoresDirectory() -> NSURL {
        let fm = NSFileManager.defaultManager()
        
        // Fetch Application Support Directory
        let URLs = fm.URLsForDirectory(.ApplicationSupportDirectory, inDomains: .UserDomainMask)
        let applicationSupportDirectory = URLs[(URLs.count - 1)]
        
        // Create Application Stores Directory
        let URL = applicationSupportDirectory.URLByAppendingPathComponent("Stores")
        
        if !fm.fileExistsAtPath(URL.path!) {
            do {
                // Create Directory for Stores
                try fm.createDirectoryAtURL(URL, withIntermediateDirectories: true, attributes: nil)
                
            } catch {
                let createError = error as NSError
                print("\(createError), \(createError.userInfo)")
            }
        }
        
        return URL
    }
    
    private func applicationIncompatibleStoresDirectory() -> NSURL {
        let fm = NSFileManager.defaultManager()
        
        // Create Application Incompatible Stores Directory
        let URL = applicationStoresDirectory().URLByAppendingPathComponent("Incompatible")
        
        if !fm.fileExistsAtPath(URL.path!) {
            do {
                // Create Directory for Stores
                try fm.createDirectoryAtURL(URL, withIntermediateDirectories: true, attributes: nil)
                
            } catch {
                let createError = error as NSError
                print("\(createError), \(createError.userInfo)")
            }
        }
        
        return URL
    }
    
    private func nameForIncompatibleStore() -> String {
        // Initialize Date Formatter
        let dateFormatter = NSDateFormatter()
        
        // Configure Date Formatter
        dateFormatter.formatterBehavior = .Behavior10_4
        dateFormatter.dateFormat = "yyyy-MM-dd-HH-mm-ss"
        
        return "\(dateFormatter.stringFromDate(NSDate())).sqlite"
    }
    
    func deleteAllPeripherals() {
        if #available(iOS 9.0, *) {
            let fetchRequest = NSFetchRequest( entityName: "Peripheral" )
            let delete = NSBatchDeleteRequest( fetchRequest: fetchRequest )
            do {
                try persistentStoreCoordinator.executeRequest(delete, withContext: managedObjectContext)
            } catch let error as NSError {
                print( "Error while deleting batch: \(error)" )
            }
        } else {
            let perpRequest = NSFetchRequest()
            perpRequest.entity = NSEntityDescription.entityForName( "Peripheral", inManagedObjectContext: managedObjectContext )
            perpRequest.includesPropertyValues = false
            do {
                let perps: NSArray = try managedObjectContext.executeFetchRequest( perpRequest )
                for perp in perps as! [Peripheral] {
                    managedObjectContext.deleteObject( perp )
                }
                try managedObjectContext.save()
            } catch let error as NSError {
                print( "Error while fetching or saving batch: \(error)" )
            }
        }
    }
}
