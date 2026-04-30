//
//  FlattenedEventsRequest.swift
//  sbud
//
//  Created by ahmed on 01/02/2026.
//

import Foundation
import FirebaseFirestore

struct FlattenedEventsRequest: Encodable, Sendable, CustomStringConvertible {
    let topLeft: GeoPoint
    let bottomRight: GeoPoint
    let selectedActivityType: String
    let selectedStartTime: Date
    let selectedEndTime: Date

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
            "selectedEndTime": formatter.string(from: selectedEndTime)
        ]
    }

    // MARK: - CustomStringConvertible
    var description: String {
        toDict()
            .map { "\($0.key): \($0.value)" }
            .joined(separator: ", ")
    }
}
