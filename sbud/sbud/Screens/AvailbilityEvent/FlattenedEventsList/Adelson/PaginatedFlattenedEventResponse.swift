//
//  PaginatedFlattenedEventResponse.swift
//  sbud
//
//  Created by ahmed on 08/02/2026.
//

import Foundation
import FirebaseFirestore

nonisolated(unsafe) struct PaginatedFlattenedEventResponse: Decodable, Sendable {
    
    let events: [Event]
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
