//
//  PaginatedFlattenedEventResponse.swift
//  sbud
//
//  Created by ahmed on 08/02/2026.
//

import Foundation
import FirebaseFirestore

nonisolated struct PaginatedEventDetailsResponse: Decodable, Sendable {
    let events: [PaginatedEvent]
    let page: Int
    let pageSize: Int
    let totalCount: Int
    let totalPages: Int
    let hasNext: Bool
    let hasPrevious: Bool

    enum CodingKeys: String, CodingKey {
        case events
        case page
        case pageSize = "page_size"
        case totalCount = "total_count"
        case totalPages = "total_pages"
        case hasNext = "has_next"
        case hasPrevious = "has_previous"
    }
}
// MARK: - PaginatedEvent

struct PaginatedEvent: Decodable, Sendable {
    let createdAt: Double
    let endDateTime: Double
    let startDateTime: Double
    let isDateConfirmed: Bool
    let isPublic: Bool
    let isLocationConfirmed: Bool
    let eventId: String
    let eventImage: String
    let activityType: ActivityType
    let creatorName: String
    let numFlattenedEvents: Int

    enum CodingKeys: String, CodingKey {
        case createdAt
        case endDateTime
        case startDateTime
        case isDateConfirmed
        case isPublic
        case isLocationConfirmed
        case eventId
        case eventImage
        case activityType
        case creatorName
        case numFlattenedEvents = "NumFlattenedEvents"
    }

    var startDate: Date { Date(timeIntervalSince1970: startDateTime) }
    var endDate: Date { Date(timeIntervalSince1970: endDateTime) }
    var createdAtDate: Date { Date(timeIntervalSince1970: createdAt) }
}
