//
//  SessionTestHelper.swift
//  sbudTests
//
//  Created by Riccardo Maria Cadario on 12/07/2026.
//
import Foundation
import CoreLocation

extension Date {
    static func seconds(_ value: Double) -> Date {
        Date(timeIntervalSince1970: value)
    }
}

extension CLLocation {
    static func make(lat: Double = 45.0,
                     lon: Double = 9.0,
                     altitude: Double = 100,
                     accuracy: Double = 10,
                     speed: Double = 3.0,
                     timestamp: Date = Date()) -> CLLocation {
        CLLocation(coordinate: CLLocationCoordinate2D(latitude: lat, longitude: lon),
                   altitude: altitude,
                   horizontalAccuracy: accuracy,
                   verticalAccuracy: 10,
                   course: 0,
                   speed: speed,
                   timestamp: timestamp)
    }
}

