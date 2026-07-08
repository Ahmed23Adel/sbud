//
//  SearchEventRequest.swift
//  sbud
//
//  Created by ahmed on 26/05/2026.
//

import Foundation
import FirebaseFirestore

enum SearchEventRequestType: Sendable {
    case basic(query: String, page: Int, pageSize: Int)
    case filtered(
        topLeft: GeoPoint,
        bottomRight: GeoPoint,
        activityType: String,
        startTime: Date,
        endTime: Date,
        query: String,
        extraFilters: [String: String],
        page: Int,
        pageSize: Int
    )

    func toDict() -> [String: String] {
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]

        switch self {
        case .basic(let query, let page, let pageSize):
            return [
                "query": query,
                "page": String(page),
                "page_size": String(pageSize)
            ]

        case .filtered(let topLeft, let bottomRight, let activityType, let startTime, let endTime, let query, let extraFilters, let page, let pageSize):
            var base: [String: String] = [
                "topLeftLatitude": String(topLeft.latitude),
                "topLeftLongitude": String(topLeft.longitude),
                "bottomRightLatitude": String(bottomRight.latitude),
                "bottomRightLongitude": String(bottomRight.longitude),
                "selectedActivityType": activityType,
                "selectedStartTime": formatter.string(from: startTime),
                "selectedEndTime": formatter.string(from: endTime),
                "query": query,
                "page": String(page),
                "page_size": String(pageSize)
            ]
            base.merge(extraFilters) { _, new in new }
            return base
        }
    }

    var endpoint: String {
        switch self {
        case .basic:
            return "events/search/title"
        case .filtered:
            return "events/search/filtered"
        }
    }
}
