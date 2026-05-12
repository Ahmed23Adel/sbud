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
    let extraFilters: [String: String]          // ← new

    init(
        topLeft: GeoPoint,
        bottomRight: GeoPoint,
        selectedActivityType: String,
        selectedStartTime: Date,
        selectedEndTime: Date,
        extraFilters: [String: String] = [:]    // ← default empty so nothing breaks
    ) {
        self.topLeft = topLeft
        self.bottomRight = bottomRight
        self.selectedActivityType = selectedActivityType
        self.selectedStartTime = selectedStartTime
        self.selectedEndTime = selectedEndTime
        self.extraFilters = extraFilters
    }

    func toDict() -> [String: String] {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        var base: [String: String] = [
            "topLeftLatitude":      String(topLeft.latitude),
            "topLeftLongitude":     String(topLeft.longitude),
            "bottomRightLatitude":  String(bottomRight.latitude),
            "bottomRightLongitude": String(bottomRight.longitude),
            "selectedActivityType": selectedActivityType,
            "selectedStartTime":    formatter.string(from: selectedStartTime),
            "selectedEndTime":      formatter.string(from: selectedEndTime)
        ]
        base.merge(extraFilters) { _, new in new }  // extra filters win on key collision
        return base
    }

    var description: String {
        toDict().map { "\($0.key): \($0.value)" }.joined(separator: ", ")
    }
}
