//
//  sbudUITests.swift
//  sbudUITests
//
//  Created by Riccardo Maria Cadario on 03/07/2026.
//

import XCTest

final class sbudUITests: XCTestCase {

    override func setUpWithError() throws {
        
        continueAfterFailure = false

        
    }

    override func tearDownWithError() throws {
        
    }

    @MainActor
    func testExample() throws {
        // UI tests must launch the application that they test.
        let app = XCUIApplication()
        app.launch()

        // Use XCTAssert and related functions to verify your tests produce the correct results.
        // XCUIAutomation Documentation
        // https://developer.apple.com/documentation/xcuiautomation
    }

    @MainActor
    func testLaunchPerformance() throws {
        // This measures how long it takes to launch your application.
        measure(metrics: [XCTApplicationLaunchMetric()]) {
            XCUIApplication().launch()
        }
    }
}
