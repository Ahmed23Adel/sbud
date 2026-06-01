//
//  HomeRequester.swift
//  sbud
//
//  Created by Erdal on 1.06.2026.
//

import Foundation
import AdelsonAuthManager
import AdelsonApiCaller
import SwiftUI

// MARK: - Response Model

nonisolated struct HomeResponse: Decodable, Sendable {
    var upcoming: [UpcomingEvent]
    var recommended: [RecommendedEvent]
    var friendsActivity: [FriendActivityItem]
    var meetPeople: [MeetPersonItem]
}

// MARK: - FriendActivityItem

nonisolated struct FriendActivityItem: Decodable, Identifiable, Sendable {
    var userId: String
    var name: String
    var profileImageUrl: String?
    var eventId: String
    var eventTitle: String
    var activityType: String
    var participationRole: String
    var creatorId: String
    var joinedAt: String?

    var id: String { userId + eventId }

    var activityTypeEnum: ActivityType {
        ActivityType(rawValue: activityType) ?? .running
    }

    var roleLabel: String {
        switch participationRole {
        case "hosted":  return "Hosted"
        case "created": return "Created"
        default:        return "Joined"
        }
    }

    var roleColor: Color {
        switch participationRole {
        case "hosted", "created": return Color("palelime")
        default: return Color(red: 0.0, green: 227.0/255.0, blue: 253.0/255.0)
        }
    }

    var isCurrentUserCreator: Bool {
        let currentUserId = ProfileManager.shared.getLocalProfile()?.id ?? ""
        return !currentUserId.isEmpty && creatorId == currentUserId
    }
}

// MARK: - MeetPersonItem

nonisolated struct MeetPersonItem: Decodable, Identifiable, Sendable {
    var userId: String
    var name: String
    var surName: String
    var profileImageUrl: String?
    var preferredActivity: String

    var id: String { userId }
    var fullName: String { "\(name) \(surName)".trimmingCharacters(in: .whitespaces) }

    var activityTypeEnum: ActivityType {
        ActivityType(rawValue: preferredActivity) ?? .running
    }
}

// MARK: - Requester

class HomeRequester {
    func fetchHome(lat: Double? = nil, lon: Double? = nil) async throws -> HomeResponse {
        let caller = AdelsonFirebaseApiCaller<HomeResponse>()
        var params: [String: String] = [:]
        if let lat = lat { params["lat"] = String(lat) }
        if let lon = lon { params["lon"] = String(lon) }
        return try await caller.callGet(
            url: "events/home",
            queryParams: params,
            config: AdelsonFirebaseAuthConfig.shared
        )
    }
}
