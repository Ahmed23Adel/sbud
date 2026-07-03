//
//  MapsHelperTests.swift
//  sbudTests
//

import XCTest
import MapKit
@testable import sbud

final class MapsHelperTests: XCTestCase {

    private var sut: MapsHelper!

    override func setUp() {
        super.setUp()
        sut = MapsHelper()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // MARK: - calcCenterForLoc

    func test_calcCenter_returnsAverageLatLon() {
        let center = sut.calcCenterForLoc(minLat: 0, maxLat: 10, minLon: 20, maxLon: 40)
        XCTAssertEqual(center.latitude, 5.0, accuracy: 0.0001)
        XCTAssertEqual(center.longitude, 30.0, accuracy: 0.0001)
    }

    func test_calcCenter_sameMinMaxReturnsItself() {
        let center = sut.calcCenterForLoc(minLat: 45.0, maxLat: 45.0, minLon: 9.0, maxLon: 9.0)
        XCTAssertEqual(center.latitude, 45.0, accuracy: 0.0001)
        XCTAssertEqual(center.longitude, 9.0, accuracy: 0.0001)
    }

    func test_calcCenter_negativeCoordinates() {
        let center = sut.calcCenterForLoc(minLat: -10, maxLat: 10, minLon: -20, maxLon: 20)
        XCTAssertEqual(center.latitude, 0.0, accuracy: 0.0001)
        XCTAssertEqual(center.longitude, 0.0, accuracy: 0.0001)
    }

    // MARK: - calcDelta

    func test_calcDelta_largerThanMinimumReturnsScaled() {
        let (latDelta, lonDelta) = sut.calcDelta(maxLat: 10, minLat: 0, maxLon: 10, minLon: 0)
        XCTAssertEqual(latDelta, 10 * 1.3, accuracy: 0.0001)
        XCTAssertEqual(lonDelta, 10 * 1.3, accuracy: 0.0001)
    }

    func test_calcDelta_smallRangeFallsBackToCityZoom() {
        let (latDelta, lonDelta) = sut.calcDelta(maxLat: 0.001, minLat: 0, maxLon: 0.001, minLon: 0)
        XCTAssertEqual(latDelta, sut.cityZoomLatitudeDelta, accuracy: 0.0001)
        XCTAssertEqual(lonDelta, sut.cityZoomLongitudeDelta, accuracy: 0.0001)
    }

    // MARK: - determinePrecision

    func test_precision_veryZoomedIn_returnsIndividuals() {
        let region = makeRegion(latDelta: 0.005)
        XCTAssertEqual(sut.determinePrecision(from: region), .individuals)
    }

    func test_precision_zoomedIn_returnsIndividuals() {
        let region = makeRegion(latDelta: 0.03)
        XCTAssertEqual(sut.determinePrecision(from: region), .individuals)
    }

    func test_precision_cityLevel_returnsCity() {
        let region = makeRegion(latDelta: 0.1)
        XCTAssertEqual(sut.determinePrecision(from: region), .city)
    }

    func test_precision_largeCityLevel_returnsLargeCity() {
        let region = makeRegion(latDelta: 0.5)
        XCTAssertEqual(sut.determinePrecision(from: region), .largeCity)
    }

    func test_precision_countryLevel_returnsCountry() {
        let region = makeRegion(latDelta: 2.0)
        XCTAssertEqual(sut.determinePrecision(from: region), .country)
    }

    func test_precision_veryZoomedOut_returnsContinent() {
        let region = makeRegion(latDelta: 50.0)
        XCTAssertEqual(sut.determinePrecision(from: region), .continent)
    }

    // Boundary: exactly 0.05 — switch evaluates top-to-bottom, so 0.01...0.05 matches first → .individuals
    func test_precision_boundary_0_05_returnsIndividuals() {
        let region = makeRegion(latDelta: 0.05)
        XCTAssertEqual(sut.determinePrecision(from: region), .individuals)
    }

    // MARK: - isNewRegionContained

    func test_isContained_whenNewIsInsideOld_returnsTrue() {
        let old = makeRegion(center: CLLocationCoordinate2D(latitude: 45, longitude: 9), latDelta: 1.0, lonDelta: 1.0)
        let new = makeRegion(center: CLLocationCoordinate2D(latitude: 45, longitude: 9), latDelta: 0.1, lonDelta: 0.1)
        XCTAssertTrue(sut.isNewRegionContained(new: new, old: old))
    }

    func test_isContained_whenNewIsLargerThanOld_returnsFalse() {
        let old = makeRegion(center: CLLocationCoordinate2D(latitude: 45, longitude: 9), latDelta: 0.1, lonDelta: 0.1)
        let new = makeRegion(center: CLLocationCoordinate2D(latitude: 45, longitude: 9), latDelta: 1.0, lonDelta: 1.0)
        XCTAssertFalse(sut.isNewRegionContained(new: new, old: old))
    }

    func test_isContained_whenNewIsShiftedOutside_returnsFalse() {
        let old = makeRegion(center: CLLocationCoordinate2D(latitude: 45, longitude: 9), latDelta: 0.5, lonDelta: 0.5)
        let new = makeRegion(center: CLLocationCoordinate2D(latitude: 46, longitude: 9), latDelta: 0.1, lonDelta: 0.1)
        XCTAssertFalse(sut.isNewRegionContained(new: new, old: old))
    }

    // MARK: - Helpers

    private func makeRegion(latDelta: Double) -> MKCoordinateRegion {
        makeRegion(
            center: CLLocationCoordinate2D(latitude: 45, longitude: 9),
            latDelta: latDelta,
            lonDelta: latDelta
        )
    }

    private func makeRegion(
        center: CLLocationCoordinate2D,
        latDelta: Double,
        lonDelta: Double
    ) -> MKCoordinateRegion {
        MKCoordinateRegion(
            center: center,
            span: MKCoordinateSpan(latitudeDelta: latDelta, longitudeDelta: lonDelta)
        )
    }
}
