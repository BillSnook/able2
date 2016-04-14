//
//  able2Tests.swift
//  able2Tests
//
//  Created by William Snook on 3/25/16.
//  Copyright © 2016 William Snook. All rights reserved.
//

import XCTest
import CoreData
import CoreBluetooth
import Log

@testable import able2


//extension Formatters {
//    static let Constrained = Formatter("[%@] %@ | %@.%@:%@\t\t%@", [
//        .Date("HH:mm:ss.SSS"),
//        .Level,
//        .File(fullPath: false, fileExtension: false),
//        .Function,
//        .Line,
//        .Message
//        ])
//}
//
//extension Themes {
//    static let MobileForming = Theme(
//        trace:   "#AAAAAA",
//        debug:   "#44AAAA",
//        info:    "#44CC44",
//        warning: "#CC6666",
//        error:   "#EE4444"
//    )
//}


//let Log = Logger( formatter: .Constrained, theme: .MobileForming )


class able2Tests: XCTestCase {

//    var appDelegate: AppDelegate? = nil
    var managedContext: NSManagedObjectContext? = nil

    override func setUp() {
        super.setUp()

        let appDelegate = AppDelegate()
        managedContext = appDelegate.managedObjectContext
//        managedContext = setUpInMemoryManagedObjectContext()

//        deleteAllPeripherals(managedContext!)

    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
        
//        deleteAllPeripherals(managedContext!)
    }
    
    func test1CoreDataSetupData1() {

        if let peripheralEntity =  NSEntityDescription.entityForName("Peripheral", inManagedObjectContext: managedContext!) {
            if let entry = NSManagedObject(entity: peripheralEntity, insertIntoManagedObjectContext: managedContext) as? Peripheral {
                entry.mainUUID = NSUUID().UUIDString
                entry.name = "Test name"
                entry.connectable = false
                entry.rssi = NSNumber( float: -45 )
                
                let sightingEntity = NSEntityDescription.entityForName("Sighting", inManagedObjectContext: managedContext!)
                if let newSighting = NSManagedObject(entity: sightingEntity!, insertIntoManagedObjectContext: managedContext) as? Sighting {
                    newSighting.date = NSDate()
                    newSighting.rssi = NSNumber( float: -50 )
                    entry.sightings = NSSet( object: newSighting )
                }

                do {
                    try managedContext!.save()
//                    print("After save Try")
                } catch let error as NSError  {
                    XCTFail( "Error - Managed Context save error: \(error), \(error.userInfo)")
                }
                
                let fetch = NSFetchRequest( entityName: "Peripheral" )
//                let predicate = NSPredicate( format: "mainUUID == '\(peripheral.identifier.UUIDString)'" )
//                fetch.predicate = predicate
//
                do {
                    let results = try managedContext!.executeFetchRequest( fetch ) as! [Peripheral]
                    XCTAssertTrue( results.count == 1, "Count of read data results(\(results.count)) does not match count of data records written (1)" )
                    
                    let peripheral = results[0]
                    XCTAssertEqual( peripheral.mainUUID, entry.mainUUID, "UUID does not match")
                    XCTAssertEqual( peripheral.name, entry.name, "name does not match")
                    XCTAssertEqual( peripheral.connectable, entry.connectable, "connectable set incorrectly")
                    XCTAssertEqual( peripheral.rssi, entry.rssi, "rssi not set correctly")
                } catch let error as NSError {
                    XCTFail( "Error - executeFetchRequest error: \(error), \(error.userInfo)")
                }
            } else {
                XCTFail( "Error - NSManagedObject insertIntoManagedObjectContext failure" )
            }
        } else {
            XCTFail( "Error - NSEntityDescription.entityForName failure" )
        }
        
    }
    
    func test2CoreDataCheckData1() {
        
        let uuid = NSUUID()
        let peripheral = CBPeripheralMock(name: "Test", identifier: uuid)
//        peripheral.name = "Test"
//        peripheral.identifier = uuid

        let scanner: Scanner = Scanner.sharedScanner
        scanner.stopScan()
        XCTAssertFalse( scanner.scanRunning, "Scanner is still scanning" )
        scanner.storeEntry( peripheral, advertisementData: ["kCBAdvDataIsConnectable": NSNumber.init(bool: true)], RSSI: NSNumber(float: Float(-45)), managedContext: managedContext! )
        
        let fetch = NSFetchRequest( entityName: "Peripheral" )
//        let predicate = NSPredicate( format: "mainUUID == '\(peripheral.identifier.UUIDString)'" )
//        fetch.predicate = predicate
//
        do {
            let results = try managedContext!.executeFetchRequest( fetch ) as! [Peripheral]
            XCTAssertTrue( results.count == 1, "Count of read data results(\(results.count)) does not match count of data records written (1)" )
            if !results.isEmpty {
                let peripheral = results[0]
                XCTAssertNotNil( peripheral.mainUUID, "UUID is nil")
                XCTAssertEqual( peripheral.name, "Test", "name does not match")
            }
        } catch let error as NSError {
            XCTFail( "Error - executeFetchRequest error: \(error), \(error.userInfo)")
        }

    }
    
    
    
//    func testPerformanceExample() {
//        // This is an example of a performance test case.
//        self.measureBlock {
//            // Put the code you want to measure the time of here.
//        }
//    }
    
}
