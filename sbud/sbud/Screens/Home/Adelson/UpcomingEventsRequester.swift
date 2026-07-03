//
//  UpcomingEventsRequester.swift
//  sbud
//
//  Created by Erdal on 1.06.2026.
//

import Foundation
import AdelsonAuthManager
import AdelsonApiCaller

enum UpcomingEventRole: String, Decodable {
    case creator, host, participant
}

nonisolated struct UpcomingEvent: Decodable, Identifiable, Sendable {
    var eventId: String
    var title: String
    var activityType: String
    var eventImage: String
    var status: String
    var isDateConfirmed: Bool
    var startDateTime: String
    var role: UpcomingEventRole

    var id: String { eventId }

    var activityTypeEnum: ActivityType {
        ActivityType(rawValue: activityType) ?? .running
    }

    var startDate: Date? {
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let d = f.date(from: startDateTime) { return d }
        f.formatOptions = [.withInternetDateTime]
        return f.date(from: startDateTime)
    }

    var isConfirmed: Bool { status.lowercased() == "confirmed" }

    var formattedDate: String {
        guard let date = startDate else { return "" }
        let tz = TimeZone.current
        var cal = Calendar.current
        cal.timeZone = tz
        let f = DateFormatter()
        f.timeZone = tz
        if cal.isDateInToday(date) {
            f.dateFormat = "HH:mm 'TODAY'"
        } else if cal.isDateInTomorrow(date) {
            f.dateFormat = "HH:mm 'TOMORROW'"
        } else {
            f.dateFormat = "dd MMM, HH:mm"
        }
        return f.string(from: date).uppercased()
    }
}

class UpcomingEventsRequester {
    func fetchUpcomingEvents() async throws -> [UpcomingEvent] {
        let caller = AdelsonFirebaseApiCaller<[UpcomingEvent]>()
        return try await caller.callGet(
            url: "events/upcoming",
            queryParams: [:],
            config: AdelsonFirebaseAuthConfig.shared
        )
    }
}
