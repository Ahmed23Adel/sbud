//
//  UserStatsRequester.swift
//  sbud
//
//  Created by Erdal on 2.07.2026.
//

import Foundation
import AdelsonAuthManager
import AdelsonApiCaller
internal import Alamofire

// MARK: - Response Models

nonisolated struct ActivityStat: Codable, Sendable {
    var sessionCount: Int
    var totalDistanceKm: Double
    var totalDurationHours: Double
    var personalBestDistanceKm: Double?
    var personalBestDurationSecs: Double?
}

nonisolated struct UserStatsResponse: Decodable, Sendable {
    var totalSessions: Int?
    var totalDistanceKm: Double?
    var totalDurationHours: Double?
    var avgIntensity: Int?
    var favoriteActivity: String?
    var currentStreakDays: Int?
    var lastActivityDate: String?
    var lastActivityName: String?
    var monthlySessionCount: Int?
    var monthlySessionMonth: String?
    var activityStats: [String: ActivityStat]?
}

nonisolated struct RecalculateStatsResponse: Decodable, Sendable {
    var status: String
    var stats: UserStatsResponse
}

// MARK: - Requester

class UserStatsRequester {

    /// Fetch pre-computed stats for any user (own or other).
    func fetchStats(userId: String) async throws -> UserStatsResponse {
        let caller = AdelsonFirebaseApiCaller<UserStatsResponse>()
        return try await caller.callGet(
            url: "users/\(userId)/stats",
            queryParams: [:],
            config: AdelsonFirebaseAuthConfig.shared
        )
    }

    /// Recompute stats from raw metrics. Call after every session upload.
    @discardableResult
    func recalculate() async throws -> UserStatsResponse {
        let caller = AdelsonFirebaseApiCaller<RecalculateStatsResponse>()
        let response = try await caller.call(
            url: "users/me/stats/recalculate",
            params: EmptyRequest(),
            method: .post,
            config: AdelsonFirebaseAuthConfig.shared
        )
        return response.stats
    }
}
