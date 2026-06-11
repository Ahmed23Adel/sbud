//
//  RecommendedEventsRequester.swift
//  sbud
//
//  Created by Erdal on 1.06.2026.
//

import Foundation
import AdelsonAuthManager
import AdelsonApiCaller

nonisolated struct RecommendedEvent: Codable, Identifiable, Sendable {
    var eventId: String
    var title: String
    var activityType: String
    var eventImage: String
    var notes: String
    var joiningCondition: String
    var userStatus: String?

    var id: String { eventId }

    var activityTypeEnum: ActivityType {
        ActivityType(rawValue: activityType) ?? .running
    }

    var hasJoined: Bool {
        guard let status = userStatus else { return false }
        return ["pending", "waitlisted", "confirmed"].contains(status)
    }

    var joinButtonLabel: String {
        guard let status = userStatus else {
            return joiningCondition == "autoJoin" ? "JOIN THE EVENT" : "REQUEST TO JOIN"
        }
        switch status {
        case "pending":    return "REQUEST SENT"
        case "waitlisted": return "ON WAITLIST"
        case "confirmed":  return "JOINED ✓"
        default:           return joiningCondition == "autoJoin" ? "JOIN THE EVENT" : "REQUEST TO JOIN"
        }
    }
}

class RecommendedEventsRequester {
    func fetchRecommendedEvents(lat: Double? = nil, lon: Double? = nil) async throws -> [RecommendedEvent] {
        let caller = AdelsonFirebaseApiCaller<[RecommendedEvent]>()
        var params: [String: String] = [:]
        if let lat = lat { params["lat"] = String(lat) }
        if let lon = lon { params["lon"] = String(lon) }
        return try await caller.callGet(
            url: "events/recommended",
            queryParams: params,
            config: AdelsonFirebaseAuthConfig.shared
        )
    }
}
