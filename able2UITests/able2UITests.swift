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
       
        let centralButton = app.buttons["beCentral"]
        XCTAssertEqual( centralButton.exists, true )
        
        centralButton.tap()
        
        app.navigationBars["Peripheral List"].childrenMatchingType(.Button).matchingIdentifier("Back").elementBoundByIndex(0).tap()
        
        let peripheralButton = app.buttons["bePeripheral"]
        XCTAssertEqual( peripheralButton.exists, true )

        peripheralButton.tap()
        
        app.navigationBars["Setup Peripheral"].childrenMatchingType(.Button).matchingIdentifier("Back").elementBoundByIndex(0).tap()
        
}
    
    func test2CentralScene() {
    
//        let centralButton = app.buttons["beCentral"]
//        XCTAssertEqual( centralButton.exists, true )
//        
//        centralButton.tap()
//        
//        app.navigationBars["Peripheral List"].childrenMatchingType(.Button).matchingIdentifier("Back").elementBoundByIndex(0).tap()
    
    }
    
    func test3PeripheralScene() {
    
//        let peripheralButton = app.buttons["bePeripheral"]
//        XCTAssertEqual( peripheralButton.exists, true )
//        
//        peripheralButton.tap()
//        
//        app.navigationBars["Setup Peripheral"].childrenMatchingType(.Button).matchingIdentifier("Back").elementBoundByIndex(0).tap()
        
    }

}
