//
//  FlattenedEventsRequest.swift
//  sbud
//
//  Created by ahmed on 01/02/2026.
//

import Foundation
import FirebaseFirestore

struct FlattenedEventsRequest: Encodable, Sendable {
    let topLeft: GeoPoint
    let bottomRight: GeoPoint
    let selectedActivityType: String
    let selectedStartTime: Date
    let selectedEndTime: Date

    func toDict() -> [String: String] {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        let startString = formatter.string(from: selectedStartTime)
        let endString = formatter.string(from: selectedEndTime)
        let dict = [
            "topLeftLatitude": String(topLeft.latitude),
            "topLeftLongitude": String(topLeft.longitude),
            "bottomRightLatitude": String(bottomRight.latitude),
            "bottomRightLongitude": String(bottomRight.longitude),
            "selectedActivityType": selectedActivityType,
            "selectedStartTime": startString,
            "selectedEndTime": endString
        ]
        return dict
    }
}
