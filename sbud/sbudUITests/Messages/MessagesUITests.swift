//
//  MessagesUITests.swift
//  sbudUITests
//
//  Created by Riccardo Maria Cadario on 03/07/2026.
//

import XCTest

final class MessagesUITests: XCTestCase {

    var app: XCUIApplication!

    override func setUpWithError() throws {
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["UI_TESTING"]
        app.launch()
    }

    override func tearDownWithError() throws {
        app = nil
    }

    func test_profile_showsMyEventsSection() {
        let profileTab = app.buttons["Profile"]
        XCTAssertTrue(profileTab.waitForExistence(timeout: 5))
        profileTab.tap()

        // La sezione eventi (porta d'ingresso alle chat) deve esistere
        app.swipeUp() // MY EVENTS è in fondo alla pagina
        XCTAssertTrue(app.staticTexts["MY EVENTS"].waitForExistence(timeout: 5))
    }

    func test_myEvents_viewAll_opensEventsList() {
        app.buttons["Profile"].tap()
        app.swipeUp()

        // Ci sono due VIEW ALL (Archive History e My Events): prendiamo il secondo
        let viewAllButtons = app.buttons.matching(identifier: "VIEW ALL")
        XCTAssertTrue(viewAllButtons.firstMatch.waitForExistence(timeout: 5))
        let myEventsViewAll = viewAllButtons.count > 1
            ? viewAllButtons.element(boundBy: 1)
            : viewAllButtons.firstMatch
        myEventsViewAll.tap()

        // La lista eventi ha i tre segmenti Created/Hosted/Participated
        XCTAssertTrue(app.staticTexts["Created"].waitForExistence(timeout: 5)
                      || app.buttons["Created"].waitForExistence(timeout: 2))
    }
}
