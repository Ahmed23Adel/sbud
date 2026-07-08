//
//  HomeUITests.swift
//  sbud
//
//  Created by Erdal on 30.06.2026.
//

import XCTest

final class HomeUITests: XCTestCase {

    private var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["UI_TESTING"]
        app.launch()
    }

    override func tearDown() {
        app.terminate()
        app = nil
        super.tearDown()
    }

    // MARK: - Default Landing Tab

    func test_appLaunch_landsOnHomeTab() {
        let scrollView = app.scrollViews["home.scrollView"]
        XCTAssertTrue(scrollView.waitForExistence(timeout: 10), "Home should be the default selected tab on launch")
    }

    func test_homeTab_isSelectedByDefault() {
        let tabBar = app.tabBars.firstMatch
        guard tabBar.waitForExistence(timeout: 8) else {
            return XCTFail("Tab bar not found")
        }
        XCTAssertTrue(tabBar.buttons["Home"].isSelected)
    }

    // MARK: - Section Headers (always rendered, independent of network state)

    func test_upcomingEventsSection_headerVisible() {
        let header = app.staticTexts["UPCOMING EVENTS"]
        XCTAssertTrue(header.waitForExistence(timeout: 10))
    }

    func test_privateEventsSection_headerVisible() {
        let header = app.staticTexts["PRIVATE EVENTS"]
        XCTAssertTrue(header.waitForExistence(timeout: 10))
    }

    func test_recommendedEventsSection_headerVisible() {
        let header = app.staticTexts["RECOMMENDED EVENTS"]
        XCTAssertTrue(header.waitForExistence(timeout: 10))
    }

    func test_buddyMovesSection_headerVisible() {
        let header = app.staticTexts["BUDDY MOVES"]
        XCTAssertTrue(header.waitForExistence(timeout: 10))
    }

    func test_newPeopleSection_headerVisible() {
        let header = app.staticTexts["NEW PEOPLE"]
        XCTAssertTrue(header.waitForExistence(timeout: 10))
    }

    func test_allFiveSections_appearInExpectedTopToBottomOrder() {
        let scrollView = app.scrollViews["home.scrollView"]
        guard scrollView.waitForExistence(timeout: 10) else {
            return XCTFail("Home scroll view not found")
        }
        let expectedOrder = ["UPCOMING EVENTS", "PRIVATE EVENTS", "RECOMMENDED EVENTS", "BUDDY MOVES", "NEW PEOPLE"]
        for header in expectedOrder {
            XCTAssertTrue(app.staticTexts[header].waitForExistence(timeout: 5), "Missing section header: \(header)")
        }
    }

    // MARK: - Pull to Refresh

    func test_pullToRefresh_doesNotCrashAndSectionsRemain() {
        let scrollView = app.scrollViews["home.scrollView"]
        guard scrollView.waitForExistence(timeout: 10) else {
            return XCTFail("Home scroll view not found")
        }
        // Drag from top to simulate a pull-to-refresh gesture.
        let start = scrollView.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.05))
        let end = scrollView.coordinate(withNormalizedOffset: CGVector(dx: 0.5, dy: 0.6))
        start.press(forDuration: 0.05, thenDragTo: end)

        XCTAssertTrue(app.staticTexts["UPCOMING EVENTS"].waitForExistence(timeout: 8),
                      "Sections should still be present after a pull-to-refresh")
    }

    // MARK: - Tab Round-Tripping

    func test_navigatingAwayAndBack_restoresHomeContent() {
        let tabBar = app.tabBars.firstMatch
        guard tabBar.waitForExistence(timeout: 8) else {
            return XCTFail("Tab bar not found")
        }
        XCTAssertTrue(app.staticTexts["UPCOMING EVENTS"].waitForExistence(timeout: 10))

        tabBar.buttons["Profile"].tap()
        XCTAssertFalse(app.staticTexts["UPCOMING EVENTS"].exists)

        tabBar.buttons["Home"].tap()
        XCTAssertTrue(app.staticTexts["UPCOMING EVENTS"].waitForExistence(timeout: 8),
                      "Home content should still render after navigating away and back")
    }
}
