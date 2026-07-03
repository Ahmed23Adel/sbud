//
//  HostingEventsRequester.swift
//  sbud
//
//  Created by Erdal on 11.05.2026.
//

import Foundation
import AdelsonAuthManager
import AdelsonApiCaller

nonisolated struct HostingEvent: Decodable, Identifiable, Sendable {
    var eventId: String
    var title: String
    var activityType: String
    var eventImage: String
    var status: String

    var id: String { eventId }

    var usersEventStatus: UsersEventStatus {
        UsersEventStatus(rawValue: status.capitalized) ?? .proposed
    }

    var activityTypeEnum: ActivityType {
        ActivityType(rawValue: activityType) ?? .running
    }
}

class HostingEventsRequester {

    func fetchHostingEvents() async throws -> [HostingEvent] {
        let caller = AdelsonFirebaseApiCaller<[HostingEvent]>()
        return try await caller.callGet(
            url: "events/hosting",
            queryParams: [:],
            config: AdelsonFirebaseAuthConfig.shared
        )
    }
}
