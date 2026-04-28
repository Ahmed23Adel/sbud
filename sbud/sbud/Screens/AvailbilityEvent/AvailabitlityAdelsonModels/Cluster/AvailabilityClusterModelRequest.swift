//
//  Request.swift
//  sbud
//
//  Created by ahmed on 01/02/2026.
//

import Foundation
import FirebaseFirestore
import _MapKit_SwiftUI
import Geohash
import FirebaseCore

struct Coordinate: Codable, Sendable {
    let latitude: Double
    let longitude: Double
}
struct AvailabilityClusterModelRequest: Encodable, Sendable, CustomStringConvertible {
    let topLeft: GeoPoint
    let bottomRight: GeoPoint
    let selectedActivityType: String
    let selectedStartTime: Date
    let selectedEndTime: Date
    let precision: Int

    func toDict() -> [String: String] {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        return [
            "topLeftLatitude": String(topLeft.latitude),
            "topLeftLongitude": String(topLeft.longitude),
            "bottomRightLatitude": String(bottomRight.latitude),
            "bottomRightLongitude": String(bottomRight.longitude),
            "selectedActivityType": selectedActivityType,
            "selectedStartTime": formatter.string(from: selectedStartTime),
            "selectedEndTime": formatter.string(from: selectedEndTime),
            "precision": String(precision)
        ]
    }

    // MARK: - CustomStringConvertible
    var description: String {
        let dict = toDict()
        return dict
            .map { "\($0.key): \($0.value)" }
            .joined(separator: ", ")
    }
}
