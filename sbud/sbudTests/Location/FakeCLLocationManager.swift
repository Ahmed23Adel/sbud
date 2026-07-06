//
//  FakeCLLocationManager.swift
//  sbud
//
//  Created by Riccardo Maria Cadario on 06/07/2026.
//


import XCTest
import CoreLocation
@testable import sbud

// Finto CLLocationManager
final class FakeCLLocationManager: CLLocationManager {
    var fakeStatus: CLAuthorizationStatus = .notDetermined
    override var authorizationStatus: CLAuthorizationStatus { fakeStatus }
}

final class LocationManagerTests: XCTestCase {

    // Nota: LocationManager è un singleton (init privato), quindi testiamo .shared.
    var sut: LocationManager!

    override func setUp() {
        super.setUp()
        sut = LocationManager.shared
        sut.userLocation = nil
        sut.lastLocation = nil
        sut.authorizationStatus = nil
    }

    // MARK: - didUpdateLocations

    func test_didUpdateLocations_setsUserLocationAndLastLocation() {
        let location = CLLocation(latitude: 45.8206, longitude: 8.8251) // Varese

        sut.locationManager(CLLocationManager(), didUpdateLocations: [location])

        XCTAssertEqual(sut.userLocation?.latitude, 45.8206)
        XCTAssertEqual(sut.userLocation?.longitude, 8.8251)
        XCTAssertEqual(sut.lastLocation?.coordinate.latitude, 45.8206)
    }

    func test_didUpdateLocations_usesMostRecentLocation() {
        let older = CLLocation(latitude: 1, longitude: 1)
        let newest = CLLocation(latitude: 45.0, longitude: 9.0)

        sut.locationManager(CLLocationManager(), didUpdateLocations: [older, newest])

        XCTAssertEqual(sut.userLocation?.latitude, 45.0, "Deve usare l'ultima posizione dell'array")
    }

    func test_didUpdateLocations_emptyArray_doesNotChangeState() {
        sut.locationManager(CLLocationManager(), didUpdateLocations: [])

        XCTAssertNil(sut.userLocation)
        XCTAssertNil(sut.lastLocation)
    }

    // MARK: - Authorization

    func test_authorizationChange_updatesPublishedStatus() {
        let fake = FakeCLLocationManager()
        fake.fakeStatus = .denied

        sut.locationManagerDidChangeAuthorization(fake)

        XCTAssertEqual(sut.authorizationStatus, .denied)
    }

    func test_authorizationChange_authorizedWhenInUse_isStored() {
        let fake = FakeCLLocationManager()
        fake.fakeStatus = .authorizedWhenInUse

        sut.locationManagerDidChangeAuthorization(fake)

        XCTAssertEqual(sut.authorizationStatus, .authorizedWhenInUse)
    }

    func test_authorizationChange_notDetermined_isStored() {
        let fake = FakeCLLocationManager()
        fake.fakeStatus = .notDetermined

        sut.locationManagerDidChangeAuthorization(fake)

        XCTAssertEqual(sut.authorizationStatus, .notDetermined)
    }
}
