//
//  able2UITests.swift
//  able2UITests
//
//  Created by William Snook on 3/25/16.
//  Copyright © 2016 William Snook. All rights reserved.
//

import XCTest


class able2UITests: XCTestCase {

    let app = XCUIApplication()

    override func setUp() {
        super.setUp()
        
        continueAfterFailure = false

        app.launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
    }
    
    override func tearDown() {
        
        app.terminate()
        
        super.tearDown()
    }
    
    func test1FirstSceneAndReturn() {
       
        // With the SplitView controller, we now start with the Peripherals page displaying a list of peripherals
        // Chaining the following commands fails for an unknown reason, so we have seperated them for now
        let navbar = app.navigationBars["Peripherals"]
        let buttons = navbar.childrenMatchingType(.Button)
        let match = buttons.matchingIdentifier("Mode")
        let element = match.elementBoundByIndex(0)
        element.tap()
        
//        print( buttons.debugDescription )
        
        let centralButton = app.buttons["becomeCentral"]
        XCTAssertEqual( centralButton.exists, true )
        
        centralButton.tap()
        
        app.navigationBars["Peripherals"].childrenMatchingType(.Button).matchingIdentifier("Mode").elementBoundByIndex(0).tap()

        let peripheralButton = app.buttons["becomePeripheral"]
        XCTAssertEqual( peripheralButton.exists, true )

        peripheralButton.tap()
        
        // Needs fix in the app
        app.navigationBars["Create Peripheral"].childrenMatchingType(.Button).matchingIdentifier("Mode").elementBoundByIndex(0).tap()
        
        let newCentralButton = app.buttons["becomeCentral"]
        XCTAssertEqual( newCentralButton.exists, true )
        
}
    
    func test2CentralScene() {
    
        // With the SplitView controller, we now start with the Peripherals page displaying a list of peripherals
        // Chaining the following commands fails for an unknown reason, so we have seperated them for now
        let navbar = app.navigationBars["Peripherals"]
        let buttons = navbar.childrenMatchingType(.Button)
        let match = buttons.matchingIdentifier("Mode")
        let element = match.elementBoundByIndex(0)
        element.tap()
        
        let centralButton = app.buttons["becomeCentral"]
        XCTAssertTrue( centralButton.exists, "Missing centralButton" )
        
        centralButton.tap()
        
        app.navigationBars["Peripherals"].childrenMatchingType(.Button).matchingIdentifier("Mode").elementBoundByIndex(0).tap()
    
    }
    
    func test3CentralSceneDeleteCancelButton() {
        
        let navbar = app.navigationBars["Peripherals"]
        let buttons = navbar.childrenMatchingType(.Button)
        let match = buttons.matchingIdentifier("---")
        let element = match.elementBoundByIndex(0)
        element.tap()
        
        let alerts = app.alerts
        let elem = alerts.element
        let cView = elem.collectionViews
        let buttonList = cView.buttons
        let button = buttonList["Cancel"]
        
        if (button.exists) {
            button.tap()
        } else {
            XCTFail( "Could not find Cancel' button for alert" )
        }
    }
    
    func test4CentralSceneDeleteOKButton() {
        
        let navbar = app.navigationBars["Peripherals"]
        let buttons = navbar.childrenMatchingType(.Button)
        let match = buttons.matchingIdentifier("---")
        let element = match.elementBoundByIndex(0)
        element.tap()
        
        let alerts = app.alerts
        let elem = alerts.element
        let cView = elem.collectionViews
        let buttonList = cView.buttons
        let button = buttonList["OK"]
        
        if (button.exists) {
            button.tap()
        } else {
            XCTFail( "Could not find 'OK' button for alert" )
        }
    }
    
    func test5CentralSceneSelection() {
//        let table = app.tables
        
        let table = app.descendantsMatchingType(.Table).element
        XCTAssertNotNil( table )
        let cells = table.descendantsMatchingType(.Cell)
        XCTAssertNotNil( cells )
        if cells.count < 1 {
            print( "No data was found in the peripherals table so we cannot test further" )
            return
        }
        XCTAssertTrue( cells.count > 0 )

        let cell = cells.elementBoundByIndex(0)
        XCTAssertNotNil( cell )
        let labelText = cell.staticTexts.elementBoundByIndex(0)
        XCTAssertNotNil( labelText )
        let itemName = labelText.label
        XCTAssertNotNil( itemName )
        XCTAssertTrue( itemName.lengthOfBytesUsingEncoding( NSUTF8StringEncoding ) > 0 )
        cell.tap()
        
        let navbar = app.navigationBars[ itemName ]
        XCTAssertNotNil( navbar )
        let buttons = navbar.childrenMatchingType(.Button)
        XCTAssertNotNil( buttons )
        let match = buttons.matchingIdentifier("Peripherals")
        XCTAssertNotNil( match )
        let element = match.elementBoundByIndex(0)
        XCTAssertNotNil( element )
        element.tap()

        let newNavbar = app.navigationBars["Peripherals"]
        XCTAssertNotNil( newNavbar )

//        app.tables.staticTexts[0].tap()
//        app.navigationBars[0].buttons["Peripherals"].tap()
        
    }
    
//    func waitForElementToAppear(element: XCUIElement, timeout: NSTimeInterval = 5,  file: String = #file, line: UInt = #line) {
//        let existsPredicate = NSPredicate(format: "exists == true")
//        
//        expectationForPredicate(existsPredicate, evaluatedWithObject: element, handler: nil)
//        
//        waitForExpectationsWithTimeout(timeout) { (error) -> Void in
//            if (error != nil) {
//                let message = "Failed to find \(element) after \(timeout) seconds."
//                self.recordFailureWithDescription(message, inFile: file, atLine: line, expected: true)
//            }
//        }
//    }
}
