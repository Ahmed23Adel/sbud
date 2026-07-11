//
//  NewEventBuilderTests.swift
//  sbud
//
//  Created by Riccardo Maria Cadario on 11/07/2026.
//
import XCTest
@testable import sbud


// MARK: - NewEventBuilder

@MainActor
final class NewEventBuilderTests: XCTestCase {

    private func makeValidBuilder() -> NewEventBuilder {
        let sut = NewEventBuilder()
        sut.coverImgURL = "http://img.test/x.jpg"
        sut.title = "Run in the park"
        sut.description = "Description"
        sut.eventCapacity = 10
        // activityExtraArgs e dateLocationsHolder: se i default non sono validi,
        // questi due test te lo dicono e li sistemiamo con valori concreti
        return sut
    }

    func test_validation_missingImage() {
        let sut = makeValidBuilder()
        sut.coverImgURL = ""
        XCTAssertEqual(sut.validationErrorMessage, "Event image is required")
        XCTAssertFalse(sut.areFieldsValid())
    }

    func test_validation_missingTitle() {
        let sut = makeValidBuilder()
        sut.title = ""
        XCTAssertEqual(sut.validationErrorMessage, "Event must have a title")
    }

    func test_validation_missingDescription() {
        let sut = makeValidBuilder()
        sut.description = ""
        XCTAssertEqual(sut.validationErrorMessage, "Please enter a valid description")
    }

    func test_validation_zeroCapacity_failsValidation() {
        let sut = makeValidBuilder()
        sut.eventCapacity = 0
        XCTAssertFalse(sut.areFieldsValid())
        XCTAssertNotNil(sut.validationErrorMessage)
    }

    func test_buildRequest_mapsAllFields() {
        let sut = makeValidBuilder()
        sut.isEventPublic = false
        sut.joiningCondition = .requestFromHost

        let request = sut.buildRequest()

        XCTAssertEqual(request.title, "Run in the park")
        XCTAssertEqual(request.eventImage, "http://img.test/x.jpg")
        XCTAssertEqual(request.maxAllowedToJoin, 10)
        XCTAssertEqual(request.notes, "Description")
        XCTAssertFalse(request.isPublic)
    }
}
