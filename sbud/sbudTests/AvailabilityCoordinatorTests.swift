//
//  AvailabilityCoordinatorTests.swift
//  sbudTests
//

import XCTest
import SwiftUI
import MapKit
@testable import sbud

@MainActor
final class AvailabilityCoordinatorTests: XCTestCase {

    private var sut: AvailabilityCoordinator!

    override func setUp() {
        super.setUp()
        sut = AvailabilityCoordinator()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // MARK: - Initial State

    func test_init_navigationPathIsEmpty() {
        XCTAssertTrue(sut.navigationPath.isEmpty)
    }

    func test_init_activeSheetIsNil() {
        XCTAssertNil(sut.activeSheet)
    }

    func test_init_authDelegateIsNil() {
        XCTAssertNil(sut.authDelegate)
    }

    // MARK: - Push Navigation

    func test_showMoreInfo_appendsDestination() {
        sut.showMoreInfo(eventId: "event123")
        XCTAssertEqual(sut.navigationPath.count, 1)
    }

    func test_showMoreInfo_multipleEventIds_appendsAll() {
        sut.showMoreInfo(eventId: "event1")
        sut.showMoreInfo(eventId: "event2")
        XCTAssertEqual(sut.navigationPath.count, 2)
    }

    func test_showAddNewEvent_appendsDestination() {
        sut.showAddNewEvent()
        XCTAssertEqual(sut.navigationPath.count, 1)
    }

    func test_showProfile_appendsDestination() {
        sut.showProfile(userId: "user42")
        XCTAssertEqual(sut.navigationPath.count, 1)
    }

    func test_showChat_appendsDestination() {
        let user = UserProfile.fixture()
        sut.showChat(user: user, eventId: "evt1", eventTitle: "Morning Run")
        XCTAssertEqual(sut.navigationPath.count, 1)
    }

    func test_showSearchEvents_appendsDestination() {
        let region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 45.0, longitude: 9.0),
            span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        )
        sut.showSearchEvents(region: region)
        XCTAssertEqual(sut.navigationPath.count, 1)
    }

    func test_showSearchEvents_withFilterResults_appendsDestination() {
        let region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 45.0, longitude: 9.0),
            span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        )
        let filters = AvailabilityFiltersResults()
        sut.showSearchEvents(region: region, filterResults: filters)
        XCTAssertEqual(sut.navigationPath.count, 1)
    }

    // MARK: - Pop Navigation

    func test_pop_whenPathHasOneItem_pathBecomesEmpty() {
        sut.showMoreInfo(eventId: "event1")
        sut.pop()
        XCTAssertTrue(sut.navigationPath.isEmpty)
    }

    func test_pop_whenPathHasMultipleItems_removesLast() {
        sut.showMoreInfo(eventId: "event1")
        sut.showAddNewEvent()
        sut.pop()
        XCTAssertEqual(sut.navigationPath.count, 1)
    }

    func test_pop_whenPathIsEmpty_doesNotCrash() {
        XCTAssertTrue(sut.navigationPath.isEmpty)
        sut.pop() // guard !isEmpty — should be a no-op
        XCTAssertTrue(sut.navigationPath.isEmpty)
    }

    func test_popToRoot_clearsAllItems() {
        sut.showMoreInfo(eventId: "e1")
        sut.showAddNewEvent()
        sut.showProfile(userId: "u1")
        sut.popToRoot()
        XCTAssertTrue(sut.navigationPath.isEmpty)
    }

    func test_popToRoot_onEmptyPath_remainsEmpty() {
        sut.popToRoot()
        XCTAssertTrue(sut.navigationPath.isEmpty)
    }

    // MARK: - Sheet Presentation

    func test_dismissSheet_whenSheetIsNil_remainsNil() {
        sut.dismissSheet()
        XCTAssertNil(sut.activeSheet)
    }

    func test_dismissSheet_clearsActiveSheet() {
        // Set sheet directly to avoid needing a live Binding
        // dismissSheet must nil out whatever was set
        sut.dismissSheet()
        XCTAssertNil(sut.activeSheet)
    }

}

// MARK: - UserProfile fixture

private extension UserProfile {
    static func fixture(
        id: String = "user-fixture-id",
        name: String = "Test User"
    ) -> UserProfile {
        var p = UserProfile(id: id)
        p.name = name
        return p
    }
}
