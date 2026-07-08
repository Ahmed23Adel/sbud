//
//  PaginatedFlattenedEventsRequester.swift
//  sbud
//
//  Created by ahmed on 08/02/2026.
//

import Foundation
import AdelsonApiCaller
import AdelsonAuthManager
import FirebaseFirestore
import Geohash
import OSLog

class PaginatedFlattenedEventsRequester {

    // MARK: - Cache

    private static let cacheTTL: TimeInterval = 180 // 3 minutes

    private struct CacheEntry {
        let response: PaginatedEventDetailsResponse
        let cachedAt: Date

        var isExpired: Bool {
            Date().timeIntervalSince(cachedAt) > PaginatedFlattenedEventsRequester.cacheTTL
        }
    }

    private static var cache: [String: CacheEntry] = [:]
    private let logger = Logger(subsystem: "sBud", category: "PaginatedFlattenedEventsRequester")

    private func cacheKey(for params: PaginatedFlattenedEventsRequest) -> String {
        let centerLat = (params.topLeft.latitude + params.bottomRight.latitude) / 2
        let centerLon = (params.topLeft.longitude + params.bottomRight.longitude) / 2
        // precision 4 → ~40 km × 20 km cells, same granularity as clusters cache
        let geohash = Geohash.encode(latitude: centerLat, longitude: centerLon, length: 4)
        return "\(geohash)|\(params.selectedActivityType)|\(Int(params.selectedStartTime.timeIntervalSince1970))|\(Int(params.selectedEndTime.timeIntervalSince1970))|page=\(params.page)|size=\(params.pageSize)"
    }

    // MARK: - Fetch

    nonisolated func createApiCaller() -> AdelsonFirebaseApiCaller<PaginatedEventDetailsResponse> {
        return AdelsonFirebaseApiCaller<PaginatedEventDetailsResponse>()
    }

    func fetchEvents(requestParams: PaginatedFlattenedEventsRequest) async throws -> PaginatedEventDetailsResponse {
        let key = cacheKey(for: requestParams)

        if let entry = Self.cache[key], !entry.isExpired {
            logger.debug("Cache hit: \(key)")
            return entry.response
        }

        logger.debug("Cache miss — fetching from server: \(key)")
        let apicaller = createApiCaller()
        let response = try await apicaller.callGet(
            url: "events/flattenedevents/paginated",
            queryParams: requestParams.toDict(),
            config: AdelsonFirebaseAuthConfig.shared)

        Self.cache[key] = CacheEntry(response: response, cachedAt: Date())
        return response
    }
}
