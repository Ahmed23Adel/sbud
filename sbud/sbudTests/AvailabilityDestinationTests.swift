//
//  AvailabilityDestinationTests.swift
//  sbudTests
//

import XCTest
import SwiftUI
import MapKit
@testable import sbud

final class AvailabilityDestinationTests: XCTestCase {

    // MARK: - AvailabilityDestination Equatable

    func test_moreInfoEvent_equalWhenSameId() {
        let lhs = AvailabilityDestination.moreInfoEvent(eventId: "abc")
        let rhs = AvailabilityDestination.moreInfoEvent(eventId: "abc")
        XCTAssertEqual(lhs, rhs)
    }

    func test_moreInfoEvent_notEqualWhenDifferentId() {
        let lhs = AvailabilityDestination.moreInfoEvent(eventId: "abc")
        let rhs = AvailabilityDestination.moreInfoEvent(eventId: "xyz")
        XCTAssertNotEqual(lhs, rhs)
    }

    func test_addNewEvent_equalToItself() {
        XCTAssertEqual(AvailabilityDestination.addNewEvent, AvailabilityDestination.addNewEvent)
    }

    func test_profile_equalWhenSameUserId() {
        let lhs = AvailabilityDestination.profile(userId: "u1")
        let rhs = AvailabilityDestination.profile(userId: "u1")
        XCTAssertEqual(lhs, rhs)
    }

    func test_profile_notEqualWhenDifferentUserId() {
        let lhs = AvailabilityDestination.profile(userId: "u1")
        let rhs = AvailabilityDestination.profile(userId: "u2")
        XCTAssertNotEqual(lhs, rhs)
    }

    func test_chat_equalWhenAllParamsMatch() {
        let user = UserProfile(id: "u1")
        let lhs = AvailabilityDestination.chat(user: user, eventId: "e1", eventTitle: "Run")
        let rhs = AvailabilityDestination.chat(user: user, eventId: "e1", eventTitle: "Run")
        XCTAssertEqual(lhs, rhs)
    }

    func test_chat_notEqualWhenDifferentEventId() {
        let user = UserProfile(id: "u1")
        let lhs = AvailabilityDestination.chat(user: user, eventId: "e1", eventTitle: "Run")
        let rhs = AvailabilityDestination.chat(user: user, eventId: "e2", eventTitle: "Run")
        XCTAssertNotEqual(lhs, rhs)
    }

    func test_searchEvents_equalToItself() {
        let region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 0, longitude: 0),
            span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        )
        let lhs = AvailabilityDestination.searchEvents(region: region, filterResults: nil)
        let rhs = AvailabilityDestination.searchEvents(region: region, filterResults: nil)
        XCTAssertEqual(lhs, rhs)
    }

    func test_differentCases_notEqual() {
        XCTAssertNotEqual(
            AvailabilityDestination.addNewEvent,
            AvailabilityDestination.moreInfoEvent(eventId: "x")
        )
    }

    // MARK: - AvailabilityDestination Hashable

    func test_sameDestination_sameHashValue() {
        let a = AvailabilityDestination.moreInfoEvent(eventId: "id1")
        let b = AvailabilityDestination.moreInfoEvent(eventId: "id1")
        XCTAssertEqual(a.hashValue, b.hashValue)
    }

    func test_allCases_canBeUsedInSet() {
        let user = UserProfile(id: "u1")
        let region = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 45, longitude: 9),
            span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
        )
        var set: Set<AvailabilityDestination> = []
        set.insert(.moreInfoEvent(eventId: "e1"))
        set.insert(.addNewEvent)
        set.insert(.profile(userId: "u1"))
        set.insert(.chat(user: user, eventId: "e1", eventTitle: "T"))
        set.insert(.searchEvents(region: region, filterResults: nil))
        XCTAssertEqual(set.count, 5)
    }

    // MARK: - AvailabilityNavigationDestination Equatable

    func test_navDest_moreInfoEvent_equalWhenSameId() {
        let lhs = AvailabilityNavigationDestination.moreInfoEvent("e1")
        let rhs = AvailabilityNavigationDestination.moreInfoEvent("e1")
        XCTAssertEqual(lhs, rhs)
    }

    func test_navDest_addNewEvent_equal() {
        XCTAssertEqual(
            AvailabilityNavigationDestination.addNewEvent,
            AvailabilityNavigationDestination.addNewEvent
        )
    }

    func test_navDest_profileView_equalWhenSameUserId() {
        XCTAssertEqual(
            AvailabilityNavigationDestination.profileView(userId: "u1"),
            AvailabilityNavigationDestination.profileView(userId: "u1")
        )
    }

    func test_navDest_chat_equalWhenAllParamsMatch() {
        let user = UserProfile(id: "u1")
        let lhs = AvailabilityNavigationDestination.chat(user: user, eventId: "e1", eventTitle: "Run")
        let rhs = AvailabilityNavigationDestination.chat(user: user, eventId: "e1", eventTitle: "Run")
        XCTAssertEqual(lhs, rhs)
    }

    func test_navDest_differentCases_notEqual() {
        XCTAssertNotEqual(
            AvailabilityNavigationDestination.addNewEvent,
            AvailabilityNavigationDestination.moreInfoEvent("x")
        )
    }

    // MARK: - AvailabilitySheetType

    func test_sheetType_filterId() {
        XCTAssertEqual(AvailabilitySheetType.filter.id, "filter")
    }

    // MARK: - AvailabilitySheet.id

    func test_availabilitySheet_filter_id_isFilterString() {
        // AvailabilitySheet.filter takes a Binding — use a dummy one
        let filters = AvailabilityFiltersResults()
        var boxed = filters
        let binding = Binding(get: { boxed }, set: { boxed = $0 })
        let sheet = AvailabilitySheet.filter(availabilityFiltersResults: binding)
        XCTAssertEqual(sheet.id, "filter")
    }

    // MARK: - AvailabilitySheet Equatable

    func test_availabilitySheet_filter_equalsFilter() {
        let filters = AvailabilityFiltersResults()
        var b1 = filters
        var b2 = filters
        let s1 = AvailabilitySheet.filter(availabilityFiltersResults: Binding(get: { b1 }, set: { b1 = $0 }))
        let s2 = AvailabilitySheet.filter(availabilityFiltersResults: Binding(get: { b2 }, set: { b2 = $0 }))
        // Both are .filter — regardless of binding identity they should be equal
        XCTAssertEqual(s1, s2)
    }

    // MARK: - AvailabilityNavigationDestination Hashable

    func test_navDest_canBeUsedInSet() {
        let user = UserProfile(id: "u1")
        var set: Set<AvailabilityNavigationDestination> = []
        set.insert(.addNewEvent)
        set.insert(.moreInfoEvent("e1"))
        set.insert(.profileView(userId: "u1"))
        set.insert(.chat(user: user, eventId: "e1", eventTitle: "T"))
        XCTAssertEqual(set.count, 4)
    }

    func test_navDest_moreInfoEvent_sameId_onlyOneEntryInSet() {
        var set: Set<AvailabilityNavigationDestination> = []
        set.insert(.moreInfoEvent("same"))
        set.insert(.moreInfoEvent("same"))
        XCTAssertEqual(set.count, 1)
    }

    func test_navDest_profileView_differentId_twoEntriesInSet() {
        var set: Set<AvailabilityNavigationDestination> = []
        set.insert(.profileView(userId: "u1"))
        set.insert(.profileView(userId: "u2"))
        XCTAssertEqual(set.count, 2)
    }

    func test_navDest_chat_differentEventTitle_notEqual() {
        let user = UserProfile(id: "u1")
        let lhs = AvailabilityNavigationDestination.chat(user: user, eventId: "e1", eventTitle: "Morning")
        let rhs = AvailabilityNavigationDestination.chat(user: user, eventId: "e1", eventTitle: "Evening")
        XCTAssertNotEqual(lhs, rhs)
    }

    func test_navDest_chat_differentUser_notEqual() {
        let u1 = UserProfile(id: "u1")
        let u2 = UserProfile(id: "u2")
        let lhs = AvailabilityNavigationDestination.chat(user: u1, eventId: "e1", eventTitle: "Run")
        let rhs = AvailabilityNavigationDestination.chat(user: u2, eventId: "e1", eventTitle: "Run")
        XCTAssertNotEqual(lhs, rhs)
    }
}
