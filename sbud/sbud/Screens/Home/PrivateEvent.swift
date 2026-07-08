//
//  PrivateEvent.swift
//  sbud
//
//  Created by Erdal on 2.06.2026.
//

import Foundation
import SwiftUI

nonisolated struct PrivateEvent: Decodable, Identifiable, Sendable {
    var eventId: String
    var title: String
    var activityType: String
    var eventImage: String?
    var startDateTime: String?
    var joiningCondition: String
    var userStatus: String?

    var id: String { eventId }

    var activityTypeEnum: ActivityType {
        ActivityType(rawValue: activityType) ?? .running
    }

    var startDate: Date? {
        guard let s = startDateTime else { return nil }
        let f = ISO8601DateFormatter()
        f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
        if let d = f.date(from: s) { return d }
        f.formatOptions = [.withInternetDateTime]
        return f.date(from: s)
    }

    var formattedDate: String {
        guard let date = startDate else { return "TBD" }
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
