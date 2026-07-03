//
//  SearchEventResponse.swift
//  sbud
//
//  Created by ahmed on 26/05/2026.
//

import Foundation

nonisolated struct SearchEventResponse: Decodable, Sendable {
    let events: [SearchEventResponseItem]
    let page: Int?
    let pageSize: Int?
    let totalCount: Int?
    let totalPages: Int?
    let hasNext: Bool?
    let hasPrevious: Bool?

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

nonisolated struct SearchEventResponseItem: Decodable, Sendable {
    let title: String
    let eventImage: String
    let creatorName: String?
    let creatorId: String?
    let activityType: String
    let startDateTime: Date
    let endDateTime: Date
    let isDateConfirmed: Bool
    let isPublic: Bool
    let eventId: String
    let id: String?
    let numFlattenedEvents: Int?
    let numSession: Int?

    enum CodingKeys: String, CodingKey {
        case title
        case eventImage
        case creatorName
        case creatorId
        case activityType
        case startDateTime
        case endDateTime
        case isDateConfirmed
        case isPublic
        case eventId
        case id
        case numFlattenedEvents = "NumFlattenedEvents"
        case numSession = "numSessions"
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        title = try container.decode(String.self, forKey: .title)
        eventImage = try container.decodeIfPresent(String.self, forKey: .eventImage) ?? ""
        creatorName = try container.decodeIfPresent(String.self, forKey: .creatorName)
        creatorId = try container.decodeIfPresent(String.self, forKey: .creatorId)
        activityType = try container.decode(String.self, forKey: .activityType)
        isDateConfirmed = try container.decodeIfPresent(Bool.self, forKey: .isDateConfirmed) ?? false
        isPublic = try container.decodeIfPresent(Bool.self, forKey: .isPublic) ?? true

        let startInterval = try container.decodeIfPresent(Double.self, forKey: .startDateTime) ?? Date().timeIntervalSince1970
        startDateTime = Date(timeIntervalSince1970: startInterval)

        let endInterval = try container.decodeIfPresent(Double.self, forKey: .endDateTime) ?? Date().timeIntervalSince1970
        endDateTime = Date(timeIntervalSince1970: endInterval)

        // Try eventId first (filtered response), then id (basic response)
        if let eventIdValue = try container.decodeIfPresent(String.self, forKey: .eventId) {
            eventId = eventIdValue
        } else if let idValue = try container.decodeIfPresent(String.self, forKey: .id) {
            eventId = idValue
        } else {
            throw DecodingError.keyNotFound(CodingKeys.eventId, DecodingError.Context(codingPath: decoder.codingPath, debugDescription: "Missing eventId or id"))
        }

        id = try container.decodeIfPresent(String.self, forKey: .id)

        numFlattenedEvents = try container.decodeIfPresent(Int.self, forKey: .numFlattenedEvents)
        numSession = try container.decodeIfPresent(Int.self, forKey: .numSession)
    }

    func toSearchEventResult() -> SearchEventResult {
        let identifier = id ?? eventId
        let flattenedCount = numFlattenedEvents ?? 1

        return SearchEventResult(
            id: identifier,
            title: title,
            eventImage: eventImage,
            creatorName: creatorName ?? "Unknown",
            activityType: activityType,
            startDateTime: startDateTime,
            endDateTime: endDateTime,
            isDateConfirmed: isDateConfirmed,
            isPublic: isPublic,
            numFlattenedEvents: flattenedCount,
            eventId: eventId,
            creatorId: creatorId
        )
    }
}
