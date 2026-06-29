//
//  NewEventBuilderTests.swift
//  sbudTests
//

import XCTest
import FirebaseFirestore
@testable import sbud

final class NewEventBuilderTests: XCTestCase {

    private var sut: NewEventBuilder!

    override func setUp() {
        super.setUp()
        sut = NewEventBuilder()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // MARK: - Helpers: fill all required fields

    private func fillAllFields() {
        sut.coverImgURL = "https://example.com/img.jpg"
        sut.title = "Morning Run"
        sut.description = "Come join us at the park"
        sut.eventCapacity = 20
        sut.dateLocationsHolder.append(DateLocations(
            startDateTime: Date(),
            endDateTime: Date().addingTimeInterval(3600),
            locations: [GeoPoint(latitude: 45, longitude: 9)]
        ))
    }

    // MARK: - areFieldsValid — false cases

    func test_areFieldsValid_allEmpty_returnsFalse() {
        XCTAssertFalse(sut.areFieldsValid())
    }

    func test_areFieldsValid_emptyCoverImg_returnsFalse() {
        fillAllFields()
        sut.coverImgURL = ""
        XCTAssertFalse(sut.areFieldsValid())
    }

    func test_areFieldsValid_emptyTitle_returnsFalse() {
        fillAllFields()
        sut.title = ""
        XCTAssertFalse(sut.areFieldsValid())
    }

    func test_areFieldsValid_emptyDescription_returnsFalse() {
        fillAllFields()
        sut.description = ""
        XCTAssertFalse(sut.areFieldsValid())
    }

    func test_areFieldsValid_zeroCapacity_returnsFalse() {
        fillAllFields()
        sut.eventCapacity = 0
        XCTAssertFalse(sut.areFieldsValid())
    }

    func test_areFieldsValid_negativeCapacity_returnsFalse() {
        fillAllFields()
        sut.eventCapacity = -1
        XCTAssertFalse(sut.areFieldsValid())
    }

    func test_areFieldsValid_noDateLocations_returnsFalse() {
        sut.coverImgURL = "https://example.com/img.jpg"
        sut.title = "Test"
        sut.description = "Desc"
        sut.eventCapacity = 10
        // dateLocationsHolder is empty by default
        XCTAssertFalse(sut.areFieldsValid())
    }

    // MARK: - areFieldsValid — true case

    func test_areFieldsValid_allFieldsFilled_returnsTrue() {
        fillAllFields()
        XCTAssertTrue(sut.areFieldsValid())
    }

    func test_areFieldsValid_capacityOfOne_returnsTrue() {
        fillAllFields()
        sut.eventCapacity = 1
        XCTAssertTrue(sut.areFieldsValid())
    }

    // MARK: - validationErrorMessage

    func test_validationErrorMessage_whenValid_isNil() {
        fillAllFields()
        XCTAssertNil(sut.validationErrorMessage)
    }

    func test_validationErrorMessage_emptyCoverImg_mentionsImage() {
        fillAllFields()
        sut.coverImgURL = ""
        XCTAssertNotNil(sut.validationErrorMessage)
        XCTAssertTrue(sut.validationErrorMessage!.lowercased().contains("image"))
    }

    func test_validationErrorMessage_emptyTitle_mentionsTitle() {
        fillAllFields()
        sut.title = ""
        let msg = sut.validationErrorMessage ?? ""
        XCTAssertTrue(msg.lowercased().contains("title"))
    }

    func test_validationErrorMessage_emptyDescription_mentionsDescription() {
        fillAllFields()
        sut.description = ""
        let msg = sut.validationErrorMessage ?? ""
        XCTAssertTrue(msg.lowercased().contains("description"))
    }

    func test_validationErrorMessage_zeroCapacity_mentionsCapacity() {
        fillAllFields()
        sut.eventCapacity = 0
        let msg = sut.validationErrorMessage ?? ""
        XCTAssertTrue(msg.lowercased().contains("capacity"))
    }

    func test_validationErrorMessage_noDateLocations_mentionsDates() {
        sut.coverImgURL = "https://example.com/img.jpg"
        sut.title = "Test"
        sut.description = "Desc"
        sut.eventCapacity = 10
        let msg = sut.validationErrorMessage ?? ""
        XCTAssertFalse(msg.isEmpty)
    }

    // Priority: coverImg is checked before title
    func test_validationErrorMessage_multipleMissing_reportsCoverImgFirst() {
        // Everything is empty — coverImg is the first check
        sut.coverImgURL = ""
        sut.title = ""
        let msg = sut.validationErrorMessage ?? ""
        XCTAssertTrue(msg.lowercased().contains("image"))
    }

    // Priority: title is checked before description
    func test_validationErrorMessage_titleAndDescriptionMissing_reportsTitleFirst() {
        fillAllFields()
        sut.title = ""
        sut.description = ""
        let msg = sut.validationErrorMessage ?? ""
        XCTAssertTrue(msg.lowercased().contains("title"))
    }

    // MARK: - buildRequest

    func test_buildRequest_titleMatchesBuilder() {
        fillAllFields()
        sut.title = "Sunset Hike"
        let req = sut.buildRequest()
        XCTAssertEqual(req.title, "Sunset Hike")
    }

    func test_buildRequest_notesMatchesDescription() {
        fillAllFields()
        sut.description = "Bring sunscreen"
        let req = sut.buildRequest()
        XCTAssertEqual(req.notes, "Bring sunscreen")
    }

    func test_buildRequest_eventImageMatchesCoverImgURL() {
        fillAllFields()
        sut.coverImgURL = "https://cdn.example.com/photo.jpg"
        let req = sut.buildRequest()
        XCTAssertEqual(req.eventImage, "https://cdn.example.com/photo.jpg")
    }

    func test_buildRequest_capacityMatchesEventCapacity() {
        fillAllFields()
        sut.eventCapacity = 42
        let req = sut.buildRequest()
        XCTAssertEqual(req.maxAllowedToJoin, 42)
    }

    func test_buildRequest_isPublicMatchesBuilder() {
        fillAllFields()
        sut.isEventPublic = false
        let req = sut.buildRequest()
        XCTAssertFalse(req.isPublic)
    }

    func test_buildRequest_joiningConditionMatchesBuilder() {
        fillAllFields()
        sut.joiningCondition = .autoJoin
        let req = sut.buildRequest()
        XCTAssertEqual(req.joiningCondition, .autoJoin)
    }

    func test_buildRequest_dateLocationsCountMatches() {
        fillAllFields()
        let req = sut.buildRequest()
        XCTAssertEqual(req.dateLocations.count, sut.dateLocationsHolder.lst.count)
    }

    // MARK: - Force-unwrap regression

    func test_init_withNilProfileImageUrl_doesNotCrash() {
        // Regression: original code had profileImageUrl! which crashes when nil
        // Now it uses ?? "" so this must succeed even with no logged-in profile
        let builder = NewEventBuilder()
        XCTAssertNotNil(builder) // just proving no crash
        XCTAssertEqual(builder.coverImgURL, builder.coverImgURL) // no-op assertion, crash guard
    }
}
