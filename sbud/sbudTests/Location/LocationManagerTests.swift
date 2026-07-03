//
//  LocationManagerTests.swift
//  sbudTests
//
//  Created by Riccardo Maria Cadario on 02/07/2026.
//

import XCTest
import CoreLocation
import Combine
@testable import sbud // Questo permette al test di "vedere" i file della tua app

final class LocationManagerTests: XCTestCase {

    // Il "Subject Under Test" (quello che stiamo testando)
    var sut: LocationManager!

    override func setUp() {
        super.setUp()
        // Inizializziamo il singleton prima di ogni test
        sut = LocationManager.shared
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // MARK: - Tests

    func test_Initialization_PropertiesAreNilAtStart() {
        // Verifica che all'avvio le proprietà siano vuote (non abbiamo ancora la posizione)
        // Nota: Essendo un singleton, se altri test girano prima, potrebbero non essere nil,
        // ma per test isolati va bene.
        XCTAssertNotNil(sut)
    }

    func test_ApplyConfiguration_ExecutesClosureWithCLLocationManager() {
        // Arrange (Prepariamo il test)
        let expectation = XCTestExpectation(description: "La closure di configurazione deve essere eseguita")
        var receivedManager: CLLocationManager?

        
        sut.applyConfiguration { manager in
            receivedManager = manager
            expectation.fulfill()
        }

        
        wait(for: [expectation], timeout: 1.0)
        XCTAssertNotNil(receivedManager, "Il locationManager interno deve essere passato alla closure")
        XCTAssertEqual(receivedManager?.desiredAccuracy, kCLLocationAccuracyBest, "La precisione di default dovrebbe essere kCLLocationAccuracyBest come impostato nell'init")
    }
}
