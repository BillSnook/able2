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

// For Log formatting
extension Formatters {
    static let Constrained = Formatter("[%@] %@ | %@.%@:%@\t\t%@", [
        .date("HH:mm:ss.SSS"),
        .level,
        .file(fullPath: false, fileExtension: false),
        .function,
        .line,
        .message
        ])
}

extension Themes {
    static let Able = Theme(
        trace:   "#AAAAAA",
        debug:   "#44AAAA",
        info:    "#44CC44",
        warning: "#CC6666",
        error:   "#EE4444"
    )
}

// Display useful names
func bluetoothUUID( _ uuidString: String ) -> String {
    if let name = bluetoothNames[uuidString] {
        return name
    } else {
        return uuidString
    }
}

func cleanName( _ name: String? ) -> String {
    
    guard name != nil else {
        return "Name nil"
    }
    guard name!.characters.count != 0 else {
        return "No name"
    }
    let prefix = name![name!.startIndex]
    if prefix == "~" {
        return name!.substring(from: name!.characters.index(after: name!.startIndex))
    } else {
        return name!
    }
}


let Log = Logger( formatter: .Constrained, theme: .Able )

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
        Log.minLevel = .Debug
        
    }
    
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        bluetoothNames["180A"] = "Device Information"
        bluetoothNames["2A24"] = "Model Number String"
        bluetoothNames["2A25"] = "Serial Number String"
        bluetoothNames["2A26"] = "Firmware Revision String"
        bluetoothNames["2A27"] = "Hardware Revision String"
        bluetoothNames["2A28"] = "Software Revision String"
        bluetoothNames["2A29"] = "Manufacturer Name String"
        
        bluetoothNames["8667556C-9A37-4C91-84ED-54EE27D90049"] = "Continuity1"
        bluetoothNames["D0611E78-BBB4-4591-A5F8-487910AE4366"] = "Continuity2"

        
//        UISplitViewControllerDelegate
        splitViewController = window?.rootViewController as? UISplitViewController
  
		if splitViewController != nil {
			splitViewController!.preferredDisplayMode = .automatic
            splitViewController!.delegate = self
		}
        return true
    }

    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        self.saveManagedObjectContext()
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        self.saveManagedObjectContext()
    }
    
    // MARK: - Core Data stack

    lazy var applicationDocumentsDirectory: URL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.billsnook.testx.able2" in the application's documents Application Support directory.
        let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return urls[urls.count-1]
    }()

    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = Bundle.main.url(forResource: "able2", withExtension: "momd")!
        return NSManagedObjectModel(contentsOf: modelURL)!
//        return NSManagedObjectModel.mergedModelFromBundles([NSBundle.mainBundle()])!
    }()

    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let URLPersistentStore = self.applicationDocumentsDirectory.appendingPathComponent("SingleViewCoreData.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        let options = [ NSMigratePersistentStoresAutomaticallyOption : true, NSInferMappingModelAutomaticallyOption : true ]
        do {
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: URLPersistentStore, options: options)
        } catch {
            Log.debug( "Throw in addPersistentStoreWithType: NSSQLiteStoreType" )
            let fm = FileManager.default
            
            if fm.fileExists(atPath: URLPersistentStore.path) {
                let nameIncompatibleStore = self.nameForIncompatibleStore()
                let URLCorruptPersistentStore = self.applicationIncompatibleStoresDirectory().appendingPathComponent(nameIncompatibleStore)
                
                do {
                    // Move Incompatible Store
                    try fm.moveItem(at: URLPersistentStore, to: URLCorruptPersistentStore)
                    
                    do {
                        // Declare Options
//                        let options = [ NSMigratePersistentStoresAutomaticallyOption : true, NSInferMappingModelAutomaticallyOption : true ]
                        
                        // Add Persistent Store to Persistent Store Coordinator
                        try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: URLPersistentStore, options: options)
                        
                    } catch {
                        let storeError = error as NSError
                        Log.debug( "Throw #2 in addPersistentStoreWithType: NSSQLiteStoreType, \(storeError), \(storeError.userInfo)" )
                        // Update User Defaults
                        let userDefaults = UserDefaults.standard
                        userDefaults.set(true, forKey: "didDetectIncompatibleStore")                    }
                } catch {
                    let moveError = error as NSError
                    Log.debug( "Throw in moveItemAtURL: \(moveError), \(moveError.userInfo)")
                }
            }
        }
        
        return coordinator
    }()

    lazy var managedObjectContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
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
                Log.debug("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    fileprivate func applicationStoresDirectory() -> URL {
        let fm = FileManager.default
        
        // Fetch Application Support Directory
        let URLs = fm.urls(for: .applicationSupportDirectory, in: .userDomainMask)
        let applicationSupportDirectory = URLs[(URLs.count - 1)]
        
        // Create Application Stores Directory
        let URL = applicationSupportDirectory.appendingPathComponent("Stores")
        
        if !fm.fileExists(atPath: URL.path) {
            do {
                // Create Directory for Stores
                try fm.createDirectory(at: URL, withIntermediateDirectories: true, attributes: nil)
                
            } catch {
                let createError = error as NSError
                print("\(createError), \(createError.userInfo)")
            }
        }
        
        return URL
    }
    
    fileprivate func applicationIncompatibleStoresDirectory() -> URL {
        let fm = FileManager.default
        
        // Create Application Incompatible Stores Directory
        let URL = applicationStoresDirectory().appendingPathComponent("Incompatible")
        
        if !fm.fileExists(atPath: URL.path) {
            do {
                // Create Directory for Stores
                try fm.createDirectory(at: URL, withIntermediateDirectories: true, attributes: nil)
                
            } catch {
                let createError = error as NSError
                print("\(createError), \(createError.userInfo)")
            }
        }
        
        return URL
    }
    
    fileprivate func nameForIncompatibleStore() -> String {
        // Initialize Date Formatter
        let dateFormatter = DateFormatter()
        
        // Configure Date Formatter
        dateFormatter.formatterBehavior = .behavior10_4
        dateFormatter.dateFormat = "yyyy-MM-dd-HH-mm-ss"
        
        return "\(dateFormatter.string(from: Date())).sqlite"
    }
    
    func deleteAllPeripherals() {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>( entityName: "Peripheral" )
        let delete = NSBatchDeleteRequest( fetchRequest: fetchRequest )
        do {
            try persistentStoreCoordinator.execute(delete, with: managedObjectContext)
        } catch let error as NSError {
            print( "Error while deleting batch: \(error)" )
        }
    }
}
