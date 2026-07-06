//
//  FriendRequestsUITests.swift
//  sbud
//
//  Created by Erdal on 2.07.2026.
//

import XCTest

final class FriendRequestsUITests: XCTestCase {

    private var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["UI_TESTING"]
        app.launch()
        app.tabBars.firstMatch.waitForExistence(timeout: 8)
        app.tabBars.firstMatch.buttons["Profile"].tap()
    }

    override func tearDown() {
        app.terminate()
        app = nil
        super.tearDown()
    }

    func test_tapFriendRequestsButton_navigatesToScreen() {
        let btn = app.buttons["profile.friendRequestsButton"]
        guard btn.waitForExistence(timeout: 10) else {
            return XCTFail("Friend requests button not found")
        }
        btn.tap()
        let title = app.staticTexts["FRIEND REQUESTS"]
        XCTAssertTrue(title.waitForExistence(timeout: 5))
    }

    func test_friendRequestsScreen_noAuth_showsEmptyState() {
        let btn = app.buttons["profile.friendRequestsButton"]
        guard btn.waitForExistence(timeout: 10) else {
            return XCTFail("Friend requests button not found")
        }
        btn.tap()
        let empty = app.staticTexts["No pending requests."]
        XCTAssertTrue(empty.waitForExistence(timeout: 8))
    }

    func test_navigatingBack_returnsToOwnProfile() {
        let btn = app.buttons["profile.friendRequestsButton"]
        guard btn.waitForExistence(timeout: 10) else {
            return XCTFail("Friend requests button not found")
        }
        btn.tap()
        XCTAssertTrue(app.staticTexts["FRIEND REQUESTS"].waitForExistence(timeout: 5))
        app.navigationBars.buttons.firstMatch.tap()
        XCTAssertTrue(app.buttons["profile.editButton"].waitForExistence(timeout: 5))
    }
}

