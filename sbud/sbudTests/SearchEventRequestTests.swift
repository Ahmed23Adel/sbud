//
//  SearchEventRequestTests.swift
//  sbudTests
//

import XCTest
import FirebaseFirestore
@testable import sbud

final class SearchEventRequestTests: XCTestCase {

    // MARK: - endpoint

    func test_basicRequest_endpointIsTitle() {
        let req = SearchEventRequestType.basic(query: "run", page: 1, pageSize: 20)
        XCTAssertEqual(req.endpoint, "events/search/title")
    }

    func test_filteredRequest_endpointIsFiltered() {
        let req = SearchEventRequestType.filtered(
            topLeft: GeoPoint(latitude: 46, longitude: 8),
            bottomRight: GeoPoint(latitude: 44, longitude: 10),
            activityType: "Running",
            startTime: Date(),
            endTime: Date().addingTimeInterval(3600),
            query: "run",
            extraFilters: [:],
            page: 1,
            pageSize: 20
        )
        XCTAssertEqual(req.endpoint, "events/search/filtered")
    }

    // MARK: - toDict — basic

    func test_basicRequest_toDictContainsQuery() {
        let req = SearchEventRequestType.basic(query: "marathon", page: 1, pageSize: 20)
        XCTAssertEqual(req.toDict()["query"], "marathon")
    }

    func test_basicRequest_toDictContainsPage() {
        let req = SearchEventRequestType.basic(query: "run", page: 3, pageSize: 20)
        XCTAssertEqual(req.toDict()["page"], "3")
    }

    func test_basicRequest_toDictContainsPageSize() {
        let req = SearchEventRequestType.basic(query: "run", page: 1, pageSize: 15)
        XCTAssertEqual(req.toDict()["page_size"], "15")
    }

    func test_basicRequest_toDictHasExactlyThreeKeys() {
        let req = SearchEventRequestType.basic(query: "run", page: 1, pageSize: 20)
        XCTAssertEqual(req.toDict().count, 3)
    }

    // MARK: - toDict — filtered

    func test_filteredRequest_toDictContainsCoordinates() {
        let req = SearchEventRequestType.filtered(
            topLeft: GeoPoint(latitude: 46.0, longitude: 8.0),
            bottomRight: GeoPoint(latitude: 44.0, longitude: 10.0),
            activityType: "Running",
            startTime: Date(timeIntervalSince1970: 0),
            endTime: Date(timeIntervalSince1970: 3600),
            query: "run",
            extraFilters: [:],
            page: 1,
            pageSize: 20
        )
        let dict = req.toDict()
        XCTAssertEqual(dict["topLeftLatitude"],      "46.0")
        XCTAssertEqual(dict["topLeftLongitude"],     "8.0")
        XCTAssertEqual(dict["bottomRightLatitude"],  "44.0")
        XCTAssertEqual(dict["bottomRightLongitude"], "10.0")
    }

    func test_filteredRequest_toDictContainsActivityType() {
        let req = SearchEventRequestType.filtered(
            topLeft: GeoPoint(latitude: 0, longitude: 0),
            bottomRight: GeoPoint(latitude: 0, longitude: 0),
            activityType: "Cycling",
            startTime: Date(),
            endTime: Date(),
            query: "q",
            extraFilters: [:],
            page: 1,
            pageSize: 20
        )
        XCTAssertEqual(req.toDict()["selectedActivityType"], "Cycling")
    }

    func test_filteredRequest_toDictMergesExtraFilters() {
        let req = SearchEventRequestType.filtered(
            topLeft: GeoPoint(latitude: 0, longitude: 0),
            bottomRight: GeoPoint(latitude: 0, longitude: 0),
            activityType: "Running",
            startTime: Date(),
            endTime: Date(),
            query: "q",
            extraFilters: ["minProposedDistance": "5.0"],
            page: 1,
            pageSize: 20
        )
        XCTAssertEqual(req.toDict()["minProposedDistance"], "5.0")
    }

    func test_filteredRequest_toDictExtraFiltersOverrideConflict() {
        // If extraFilters has a key that conflicts with base keys, new value wins
        let req = SearchEventRequestType.filtered(
            topLeft: GeoPoint(latitude: 0, longitude: 0),
            bottomRight: GeoPoint(latitude: 0, longitude: 0),
            activityType: "Running",
            startTime: Date(),
            endTime: Date(),
            query: "q",
            extraFilters: ["query": "overridden"],
            page: 1,
            pageSize: 20
        )
        XCTAssertEqual(req.toDict()["query"], "overridden")
    }
}
