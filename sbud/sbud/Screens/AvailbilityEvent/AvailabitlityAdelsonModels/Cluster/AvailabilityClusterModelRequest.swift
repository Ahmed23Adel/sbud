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

nonisolated(unsafe) struct AvailabilityClusterModelRequest: Encodable, Sendable {
    let topLeft: GeoPoint
    let bottomRight: GeoPoint
    let selectedActivityType: String
    let selectedStartTime: Date
    let selectedEndTime: Date
    let precision: Int

    func toDict() -> [String: String] {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        let startString = formatter.string(from: selectedStartTime)
        let endString = formatter.string(from: selectedEndTime)
        return [
            "topLeftLatitude": String(topLeft.latitude),
            "topLeftLongitude": String(topLeft.longitude),
            "bottomRightLatitude": String(bottomRight.latitude),
            "bottomRightLongitude": String(bottomRight.longitude),
            "selectedActivityType": selectedActivityType,
            "selectedStartTime": startString,
            "selectedEndTime": endString,
            "precision": String(precision)

        ]
    }
}
