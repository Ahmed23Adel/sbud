//
//  StoriesUITests.swift
//  sbud
//
//  Created by Riccardo Maria Cadario on 07/07/2026.
//


import XCTest

final class StoriesUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["UI_TESTING"]
        app.launch()
    }

    private func openStoriesTab() {
        let storiesTab = app.buttons["Stories"]
        XCTAssertTrue(storiesTab.waitForExistence(timeout: 5))
        storiesTab.tap()
    }

    private func openCreateStory() {
        openStoriesTab()
        let createButton = app.buttons["plus.circle.fill"]
        XCTAssertTrue(createButton.waitForExistence(timeout: 5))
        createButton.tap()
    }

    // MARK: - Tab Stories

    func test_storiesTab_opensWithoutCrashing() {
        openStoriesTab()
        XCTAssertTrue(app.buttons["Stories"].exists)
    }

    // MARK: - Creazione storia

    func test_createStory_screenOpens_withTitleAndPostButton() {
        openCreateStory()

        XCTAssertTrue(app.navigationBars["New Story"].waitForExistence(timeout: 5))
        XCTAssertTrue(app.buttons["Post Story"].exists)
        XCTAssertTrue(app.buttons["Cancel"].exists)
    }

    func test_createStory_postButton_isDisabledWithoutImages() {
        openCreateStory()

        let postButton = app.buttons["Post Story"]
        XCTAssertTrue(postButton.waitForExistence(timeout: 5))
        XCTAssertFalse(postButton.isEnabled,
                       "Senza immagini e senza evento selezionato il Post deve essere disabilitato")
    }

    func test_createStory_cancel_returnsToStoriesHome() {
        openCreateStory()

        let cancel = app.buttons["Cancel"]
        XCTAssertTrue(cancel.waitForExistence(timeout: 5))
        cancel.tap()

        XCTAssertFalse(app.navigationBars["New Story"].exists,
                       "Dopo Cancel la schermata di creazione deve chiudersi")
    }
    
    func test_storiesHome_emptyState_showsPlaceholder() {
        openStoriesTab()

        // L'utente UI_TESTING non ha amici, quindi penso apparira lo stato vuoto
        XCTAssertTrue(app.staticTexts["No stories yet"].waitForExistence(timeout: 8))
    }

    func test_storiesHome_hasManageMyStoriesButton() {
        openStoriesTab()

        XCTAssertTrue(app.buttons["person.crop.rectangle.stack"].waitForExistence(timeout: 5))
    }
}
