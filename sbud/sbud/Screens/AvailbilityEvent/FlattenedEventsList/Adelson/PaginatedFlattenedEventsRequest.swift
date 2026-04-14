//
//  FlattenedEventsPaginatedRequest.swift
//  sbud
//
//  Created by ahmed on 08/02/2026.
//

import Foundation
import FirebaseFirestore

struct PaginatedFlattenedEventsRequest: Encodable, Sendable, Decodable {
    let topLeft: GeoPoint
    let bottomRight: GeoPoint
    let selectedActivityType: String
    let selectedStartTime: Date
    let selectedEndTime: Date
    let page: Int
    let pageSize: Int

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
            "selectedEndTime": endString,
            "page": String(page),
            "page_size": String(pageSize)
        ]
        return dict
    }
}
