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
       
        // With the SplitView controller, we now start with the Peripheral List page displaying a list of peripherals
        // Chaining the following commands fails for an unknown reason, so we have seperated them for now
        let navbar = app.navigationBars["Peripheral List"]
        let buttons = navbar.childrenMatchingType(.Button)
        let match = buttons.matchingIdentifier("Mode")
        let element = match.elementBoundByIndex(0)
        element.tap()
        
        print( buttons.debugDescription )
        
        let centralButton = app.buttons["becomeCentral"]
        self.waitForElementToAppear(centralButton, timeout: 2)
        XCTAssertEqual( centralButton.exists, true )
        
        centralButton.tap()
        
        app.navigationBars["Peripheral List"].childrenMatchingType(.Button).matchingIdentifier("Mode").elementBoundByIndex(0).tap()

        let peripheralButton = app.buttons["becomePeripheral"]
        XCTAssertEqual( peripheralButton.exists, true )

        peripheralButton.tap()
        
        // Needs fix in the app
//        app.navigationBars["Setup Peripheral"].childrenMatchingType(.Button).matchingIdentifier("Mode").elementBoundByIndex(0).tap()
        
}
    
    func test2CentralScene() {
    
//        let centralButton = app.buttons["beCentral"]
//        XCTAssertEqual( centralButton.exists, true )
//        
//        centralButton.tap()
//        
//        app.navigationBars["Peripheral List"].childrenMatchingType(.Button).matchingIdentifier("Mode").elementBoundByIndex(0).tap()
    
    }
    
    func test3PeripheralScene() {
    
//        let peripheralButton = app.buttons["bePeripheral"]
//        XCTAssertEqual( peripheralButton.exists, true )
//        
//        peripheralButton.tap()
//        
//        app.navigationBars["Setup Peripheral"].childrenMatchingType(.Button).matchingIdentifier("Mode").elementBoundByIndex(0).tap()
        
    }

    func waitForElementToAppear(element: XCUIElement, timeout: NSTimeInterval = 5,  file: String = #file, line: UInt = #line) {
        let existsPredicate = NSPredicate(format: "exists == true")
        
        expectationForPredicate(existsPredicate, evaluatedWithObject: element, handler: nil)
        
        waitForExpectationsWithTimeout(timeout) { (error) -> Void in
            if (error != nil) {
                let message = "Failed to find \(element) after \(timeout) seconds."
                self.recordFailureWithDescription(message, inFile: file, atLine: line, expected: true)
            }
        }
    }
}
