//
//  UsersEvent.swift
//  sbud
//
//  Created by ahmed on 30/04/2026.
//

import Foundation

enum UsersEventStatus: String, Codable {
    case proposed = "Proposed"
    case confirmed = "Confirmed"
    case completed = "Completed"
}

struct UsersEvent: Codable, Identifiable {
    var id = UUID()
    var activityType: ActivityType = .running
    var title: String = ""
    var eventImage: String = ""
    var status: UsersEventStatus = .proposed
    var eventId = ""

    enum CodingKeys: String, CodingKey {
        case activityType
        case title
        case eventImage
        case status
    }
}
