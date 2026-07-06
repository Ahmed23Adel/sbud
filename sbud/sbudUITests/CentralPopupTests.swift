//
//  CentralPopupTests.swift
//  sbud
//
//  Created by Erdal on 30.06.2026.
//

import XCTest

final class CentralPopupUITests: XCTestCase {

    private var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["UI_TESTING"]
    }

    override func tearDown() {
        app.terminate()
        app = nil
        super.tearDown()
    }

    // MARK: - Appearance

    func test_popup_appearsWithCorrectMessage() {
        app.launchEnvironment["UI_TESTING_POPUP_MSG"] = "You have joined the event!"
        app.launchEnvironment["UI_TESTING_POPUP_TYPE"] = "notification"
        app.launch()

        let popup = app.otherElements["centralPopup.container"]
        XCTAssertTrue(popup.waitForExistence(timeout: 10), "CentralPopup should appear shortly after launch")

        let message = app.staticTexts["centralPopup.message"]
        XCTAssertTrue(message.waitForExistence(timeout: 5))
        XCTAssertEqual(message.label, "You have joined the event!")
    }

    func test_errorPopup_appearsWithCorrectMessage() {
        app.launchEnvironment["UI_TESTING_POPUP_MSG"] = "Error: network lost"
        app.launchEnvironment["UI_TESTING_POPUP_TYPE"] = "error"
        app.launch()

        let message = app.staticTexts["centralPopup.message"]
        XCTAssertTrue(message.waitForExistence(timeout: 10))
        XCTAssertEqual(message.label, "Error: network lost")
    }

    func test_warningPopup_appears() {
        app.launchEnvironment["UI_TESTING_POPUP_MSG"] = "Capacity reached."
        app.launchEnvironment["UI_TESTING_POPUP_TYPE"] = "warning"
        app.launch()

        let message = app.staticTexts["centralPopup.message"]
        XCTAssertTrue(message.waitForExistence(timeout: 10))
        XCTAssertEqual(message.label, "Capacity reached.")
    }

    func test_informationPopup_appears() {
        app.launchEnvironment["UI_TESTING_POPUP_MSG"] = "You're #3 in line."
        app.launchEnvironment["UI_TESTING_POPUP_TYPE"] = "information"
        app.launch()

        let message = app.staticTexts["centralPopup.message"]
        XCTAssertTrue(message.waitForExistence(timeout: 10))
        XCTAssertEqual(message.label, "You're #3 in line.")
    }

    // MARK: - Tap to Dismiss

    func test_tappingPopup_dismissesIt() {
        app.launchEnvironment["UI_TESTING_POPUP_MSG"] = "Tap me to dismiss"
        app.launchEnvironment["UI_TESTING_POPUP_TYPE"] = "notification"
        app.launch()

        let popup = app.otherElements["centralPopup.container"]
        guard popup.waitForExistence(timeout: 10) else {
            return XCTFail("Popup never appeared")
        }
        popup.tap()

        // reverseAnimation() shrinks (0.3s) then drops off-screen (0.5s) then calls
        // onDismiss (0.5s) — generous timeout to absorb that full sequence.
        XCTAssertTrue(popup.waitForNonExistence(timeout: 5),
                      "Tapping the popup should trigger its dismiss animation and remove it")
    }

    // MARK: - Auto-Dismiss

    func test_popup_autoDismissesAfterFourSeconds() {
        app.launchEnvironment["UI_TESTING_POPUP_MSG"] = "Auto dismiss me"
        app.launchEnvironment["UI_TESTING_POPUP_TYPE"] = "notification"
        app.launch()

        let popup = app.otherElements["centralPopup.container"]
        guard popup.waitForExistence(timeout: 10) else {
            return XCTFail("Popup never appeared")
        }

        // CentralPopup auto-dismisses ~4.0s after appearing, then animates off over
        // roughly another 0.8–1.0s. 10s gives ample margin without hard-coding timing.
        XCTAssertTrue(popup.waitForNonExistence(timeout: 10),
                      "Popup should auto-dismiss without any user interaction")
    }

    // MARK: - No Popup When Not Triggered

    func test_noLaunchEnvironment_noPopupAppears() {
        app.launch() // no UI_TESTING_POPUP_MSG set

        let popup = app.otherElements["centralPopup.container"]
        // Give the app a moment to finish launching, then confirm nothing appeared.
        _ = app.tabBars.firstMatch.waitForExistence(timeout: 8)
        XCTAssertFalse(popup.exists, "No popup should appear without an explicit trigger")
    }
}
