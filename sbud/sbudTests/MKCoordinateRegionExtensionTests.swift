//
//  MKCoordinateRegionExtensionTests.swift
//  sbudTests
//

import XCTest
import MapKit
import FirebaseFirestore
@testable import sbud

final class MKCoordinateRegionExtensionTests: XCTestCase {

    // Convenience: region centred at (lat, lon) with ±delta span
    private func region(lat: Double, lon: Double, delta: Double) -> MKCoordinateRegion {
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: lat, longitude: lon),
            span: MKCoordinateSpan(latitudeDelta: delta, longitudeDelta: delta)
        )
    }

    // MARK: - topLeft

    func test_topLeft_latitude_isCenterPlusHalfSpan() {
        let r = region(lat: 45.0, lon: 9.0, delta: 1.0)
        XCTAssertEqual(r.topLeft.latitude, 45.5, accuracy: 1e-9)
    }

    func test_topLeft_longitude_isCenterMinusHalfSpan() {
        let r = region(lat: 45.0, lon: 9.0, delta: 1.0)
        XCTAssertEqual(r.topLeft.longitude, 8.5, accuracy: 1e-9)
    }

    func test_topLeft_atOrigin() {
        let r = region(lat: 0, lon: 0, delta: 2.0)
        XCTAssertEqual(r.topLeft.latitude,  1.0, accuracy: 1e-9)
        XCTAssertEqual(r.topLeft.longitude, -1.0, accuracy: 1e-9)
    }

    func test_topLeft_negativeCenter() {
        let r = region(lat: -30.0, lon: -60.0, delta: 4.0)
        XCTAssertEqual(r.topLeft.latitude,  -28.0, accuracy: 1e-9)
        XCTAssertEqual(r.topLeft.longitude, -62.0, accuracy: 1e-9)
    }

    func test_topLeft_asymmetricSpan() {
        let r = MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 10.0, longitude: 20.0),
            span: MKCoordinateSpan(latitudeDelta: 2.0, longitudeDelta: 6.0)
        )
        XCTAssertEqual(r.topLeft.latitude,  11.0, accuracy: 1e-9)
        XCTAssertEqual(r.topLeft.longitude, 17.0, accuracy: 1e-9)
    }

    // MARK: - bottomRight

    func test_bottomRight_latitude_isCenterMinusHalfSpan() {
        let r = region(lat: 45.0, lon: 9.0, delta: 1.0)
        XCTAssertEqual(r.bottomRight.latitude, 44.5, accuracy: 1e-9)
    }

    func test_bottomRight_longitude_isCenterPlusHalfSpan() {
        let r = region(lat: 45.0, lon: 9.0, delta: 1.0)
        XCTAssertEqual(r.bottomRight.longitude, 9.5, accuracy: 1e-9)
    }

    func test_bottomRight_atOrigin() {
        let r = region(lat: 0, lon: 0, delta: 2.0)
        XCTAssertEqual(r.bottomRight.latitude,  -1.0, accuracy: 1e-9)
        XCTAssertEqual(r.bottomRight.longitude,  1.0, accuracy: 1e-9)
    }

    func test_bottomRight_negativeCenter() {
        let r = region(lat: -30.0, lon: -60.0, delta: 4.0)
        XCTAssertEqual(r.bottomRight.latitude,  -32.0, accuracy: 1e-9)
        XCTAssertEqual(r.bottomRight.longitude, -58.0, accuracy: 1e-9)
    }

    // MARK: - topLeft / bottomRight symmetry

    func test_topLeft_and_bottomRight_symmetricAroundCenter() {
        let r = region(lat: 45.0, lon: 9.0, delta: 2.0)
        let centerLat = (r.topLeft.latitude + r.bottomRight.latitude) / 2
        let centerLon = (r.topLeft.longitude + r.bottomRight.longitude) / 2
        XCTAssertEqual(centerLat, 45.0, accuracy: 1e-9)
        XCTAssertEqual(centerLon,  9.0, accuracy: 1e-9)
    }

    func test_topLeft_latitude_greaterThan_bottomRight_latitude() {
        let r = region(lat: 45.0, lon: 9.0, delta: 1.0)
        XCTAssertGreaterThan(r.topLeft.latitude, r.bottomRight.latitude)
    }

    func test_topLeft_longitude_lessThan_bottomRight_longitude() {
        let r = region(lat: 45.0, lon: 9.0, delta: 1.0)
        XCTAssertLessThan(r.topLeft.longitude, r.bottomRight.longitude)
    }

    // MARK: - extensionAmount

    func test_extensionAmount_is_0_05() {
        let r = region(lat: 0, lon: 0, delta: 1.0)
        XCTAssertEqual(r.extensionAmount, 0.05, accuracy: 1e-9)
    }

    // MARK: - topLeftExtended

    func test_topLeftExtended_latitude_isTopLeftPlusExtension() {
        let r = region(lat: 45.0, lon: 9.0, delta: 1.0)
        XCTAssertEqual(r.topLeftExtended.latitude, r.topLeft.latitude + 0.05, accuracy: 1e-9)
    }

    func test_topLeftExtended_longitude_isTopLeftMinusExtension() {
        // Regression: the original code used topLeft.latitude for longitude (wrong field)
        let r = region(lat: 45.0, lon: 9.0, delta: 1.0)
        XCTAssertEqual(r.topLeftExtended.longitude, r.topLeft.longitude - 0.05, accuracy: 1e-9)
    }

    func test_topLeftExtended_latitude_furtherNorthThanTopLeft() {
        let r = region(lat: 45.0, lon: 9.0, delta: 1.0)
        XCTAssertGreaterThan(r.topLeftExtended.latitude, r.topLeft.latitude)
    }

    func test_topLeftExtended_longitude_furtherWestThanTopLeft() {
        let r = region(lat: 45.0, lon: 9.0, delta: 1.0)
        XCTAssertLessThan(r.topLeftExtended.longitude, r.topLeft.longitude)
    }

    func test_topLeftExtended_longitudeNotEqualToLatitude_afterFix() {
        // Before the fix, longitude was computed from topLeft.latitude, making them equal
        // when the region was symmetric. After the fix they must differ.
        let r = region(lat: 45.0, lon: 9.0, delta: 1.0)
        XCTAssertNotEqual(r.topLeftExtended.latitude, r.topLeftExtended.longitude)
    }

    // MARK: - bottomRightExtended

    func test_bottomRightExtended_latitude_isBottomRightMinusExtension() {
        let r = region(lat: 45.0, lon: 9.0, delta: 1.0)
        XCTAssertEqual(r.bottomRightExtended.latitude, r.bottomRight.latitude - 0.05, accuracy: 1e-9)
    }

    func test_bottomRightExtended_longitude_isBottomRightPlusExtension() {
        // Regression: the original code used bottomRight.latitude for longitude (wrong field)
        let r = region(lat: 45.0, lon: 9.0, delta: 1.0)
        XCTAssertEqual(r.bottomRightExtended.longitude, r.bottomRight.longitude + 0.05, accuracy: 1e-9)
    }

    func test_bottomRightExtended_latitude_furtherSouthThanBottomRight() {
        let r = region(lat: 45.0, lon: 9.0, delta: 1.0)
        XCTAssertLessThan(r.bottomRightExtended.latitude, r.bottomRight.latitude)
    }

    func test_bottomRightExtended_longitude_furtherEastThanBottomRight() {
        let r = region(lat: 45.0, lon: 9.0, delta: 1.0)
        XCTAssertGreaterThan(r.bottomRightExtended.longitude, r.bottomRight.longitude)
    }

    func test_bottomRightExtended_longitudeNotEqualToLatitude_afterFix() {
        let r = region(lat: 45.0, lon: 9.0, delta: 1.0)
        XCTAssertNotEqual(r.bottomRightExtended.latitude, r.bottomRightExtended.longitude)
    }

    // MARK: - Extended vs non-extended bounding box is larger

    func test_extendedBoundingBox_isLargerThanOriginal() {
        let r = region(lat: 45.0, lon: 9.0, delta: 1.0)
        XCTAssertGreaterThan(r.topLeftExtended.latitude,   r.topLeft.latitude)
        XCTAssertLessThan   (r.topLeftExtended.longitude,  r.topLeft.longitude)
        XCTAssertLessThan   (r.bottomRightExtended.latitude,  r.bottomRight.latitude)
        XCTAssertGreaterThan(r.bottomRightExtended.longitude, r.bottomRight.longitude)
    }
}
