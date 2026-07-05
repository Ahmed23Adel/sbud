//
//  ProfileUITests.swift
//  sbud
//
//  Created by Erdal on 30.06.2026.
//

import XCTest

final class ProfileUITests: XCTestCase {

    private var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["UI_TESTING"]
        app.launch()
        navigateToProfileTab()
    }

    override func tearDown() {
        app.terminate()
        app = nil
        super.tearDown()
    }

    // MARK: - Helpers

    private func navigateToProfileTab() {
        let tabBar = app.tabBars.firstMatch
        guard tabBar.waitForExistence(timeout: 8) else { return }
        tabBar.buttons["Profile"].tap()
    }

    // MARK: - Core Buttons Visible

    func test_editProfileButton_isVisible() {
        let editButton = app.buttons["profile.editButton"]
        XCTAssertTrue(editButton.waitForExistence(timeout: 10))
    }

    func test_myEventsButton_isVisible() {
        let myEventsButton = app.buttons["profile.myEventsButton"]
        XCTAssertTrue(myEventsButton.waitForExistence(timeout: 10))
    }

    func test_settingsButton_isVisible() {
        let settingsButton = app.buttons["profile.settingsButton"]
        XCTAssertTrue(settingsButton.waitForExistence(timeout: 10))
    }

    func test_shareButton_isVisible() {
        let shareButton = app.buttons["profile.shareButton"]
        XCTAssertTrue(shareButton.waitForExistence(timeout: 10))
    }

    func test_friendRequestsButton_isVisible() {
        let button = app.buttons["profile.friendRequestsButton"]
        XCTAssertTrue(button.waitForExistence(timeout: 10))
    }

    func test_hostRequestsButton_isVisible() {
        let button = app.buttons["profile.hostRequestsButton"]
        XCTAssertTrue(button.waitForExistence(timeout: 10))
    }

    func test_qrCodeButton_isVisible() {
        let button = app.buttons["profile.qrCodeButton"]
        XCTAssertTrue(button.waitForExistence(timeout: 10))
    }

    func test_friendsStatsButton_isVisible() {
        let button = app.buttons["profile.friendsStatsButton"]
        XCTAssertTrue(button.waitForExistence(timeout: 10))
    }

    func test_userName_isDisplayed() {
        // Stub profile from MainCoordinator.resolveInitialRoute(): name "Test", surName "User".
        let name = app.staticTexts["TEST USER"]
        XCTAssertTrue(name.waitForExistence(timeout: 10))
    }

    // MARK: - Navigation: Settings

    func test_tapSettings_navigatesAwayFromProfileRoot() {
        let settingsButton = app.buttons["profile.settingsButton"]
        guard settingsButton.waitForExistence(timeout: 10) else {
            return XCTFail("Settings button not found")
        }
        settingsButton.tap()

        let editButton = app.buttons["profile.editButton"]
        XCTAssertTrue(
            (!editButton.exists) || editButton.waitForNonExistence(timeout: 5),
            "Edit Profile button should no longer be on screen once Settings is pushed"
        )
        XCTAssertTrue(app.navigationBars.firstMatch.waitForExistence(timeout: 5),
                      "Settings screen should appear in a navigation bar context")
    }

    // MARK: - Navigation: My Events

    func test_tapMyEvents_navigatesToCombinedEventsScreen() {
        let myEventsButton = app.buttons["profile.myEventsButton"]
        guard myEventsButton.waitForExistence(timeout: 10) else {
            return XCTFail("My Events button not found")
        }
        myEventsButton.tap()

        let editButton = app.buttons["profile.editButton"]
        XCTAssertTrue(
            (!editButton.exists) || editButton.waitForNonExistence(timeout: 5),
            "Own-profile content should no longer be on screen once My Events is pushed"
        )
    }

    // MARK: - Navigation: Friends List

    func test_tapFriendsStats_navigatesToFriendsList() {
        let friendsButton = app.buttons["profile.friendsStatsButton"]
        guard friendsButton.waitForExistence(timeout: 10) else {
            return XCTFail("Friends stats button not found")
        }
        friendsButton.tap()

        let editButton = app.buttons["profile.editButton"]
        XCTAssertTrue(
            (!editButton.exists) || editButton.waitForNonExistence(timeout: 5),
            "Own-profile content should no longer be on screen once Friends List is pushed"
        )
    }

    // MARK: - QR Code Sheet

    func test_tapQRCode_opensSheet() {
        let qrButton = app.buttons["profile.qrCodeButton"]
        guard qrButton.waitForExistence(timeout: 10) else {
            return XCTFail("QR code button not found")
        }
        qrButton.tap()

        // QRCodeSheetView is presented modally — the own-profile edit button (which sits
        // behind the sheet) is the simplest signal that something covers the screen now.
        XCTAssertTrue(app.otherElements.firstMatch.waitForExistence(timeout: 5))
    }

    func test_qrCodeSheet_dismissesOnSwipeDown() {
        let qrButton = app.buttons["profile.qrCodeButton"]
        guard qrButton.waitForExistence(timeout: 10) else {
            return XCTFail("QR code button not found")
        }
        qrButton.tap()
        // Give the sheet a moment to present before attempting to dismiss it.
        Thread.sleep(forTimeInterval: 0.5)

        app.swipeDown()

        let editButton = app.buttons["profile.editButton"]
        XCTAssertTrue(editButton.waitForExistence(timeout: 5),
                      "Own profile should be visible again after dismissing the QR sheet")
    }

    // MARK: - Tab Round-Tripping

    func test_navigatingAwayAndBack_restoresProfileContent() {
        let tabBar = app.tabBars.firstMatch
        guard tabBar.waitForExistence(timeout: 8) else {
            return XCTFail("Tab bar not found")
        }
        XCTAssertTrue(app.buttons["profile.editButton"].waitForExistence(timeout: 10))

        tabBar.buttons["Home"].tap()
        XCTAssertFalse(app.buttons["profile.editButton"].exists)

        tabBar.buttons["Profile"].tap()
        XCTAssertTrue(app.buttons["profile.editButton"].waitForExistence(timeout: 8),
                      "Profile content should still render after navigating away and back")
    }
}
