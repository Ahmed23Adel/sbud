//
//  SettingsUITests.swift
//  sbudUITests
//
//  Created by Riccardo Maria Cadario on 03/07/2026.
//

import XCTest

final class SettingsUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["UI_TESTING"]
        app.launch()
    }

    /// Naviga fino a Settings. ADATTA questi tap al percorso vero della tua app.
    private func openSettings() {
        let profileTab = app.buttons["Profile"]
        XCTAssertTrue(profileTab.waitForExistence(timeout: 5))
        profileTab.tap()

        let gear = app.buttons["gearshape"]
        XCTAssertTrue(gear.waitForExistence(timeout: 5))
        gear.tap()
    }

    func test_settingsScreen_showsAllPrivacyToggles() {
        openSettings()

        XCTAssertTrue(app.switches["toggle_PrivateProfile"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.switches["toggle_ShowEmail"].exists)
        XCTAssertTrue(app.switches["toggle_ShowPhone"].exists)
        XCTAssertTrue(app.buttons["logout_button"].exists)
    }

    func test_togglePrivateProfile_changesValue() {
        openSettings()

        let toggle = app.switches["toggle_PrivateProfile"]
        XCTAssertTrue(toggle.waitForExistence(timeout: 5))

        let before = toggle.value as? String
        toggle.tap()
        let after = toggle.value as? String

        XCTAssertNotEqual(before, after, "Il toggle deve cambiare stato al tap")
    }

    func test_logout_returnsToSignUpScreen() {
        openSettings()

        let logout = app.buttons["logout_button"]
        XCTAssertTrue(logout.waitForExistence(timeout: 5))
        logout.tap()

        // Verifica che siamo tornati alla schermata di signup.
        // Adatta "SignUp" a un testo/elemento che esiste davvero in SignUpView
        XCTAssertTrue(app.staticTexts["Sign Up"].waitForExistence(timeout: 5))
    }
}
