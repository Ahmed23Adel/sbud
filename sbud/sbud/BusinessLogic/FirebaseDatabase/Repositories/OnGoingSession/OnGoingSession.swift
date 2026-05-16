//
//  OnGoingSession.swift
//  sbud
//
//  Created by ahmed on 15/05/2026.
//

import Foundation

struct OnGoingSession: Codable, Identifiable {
    var id = UUID().uuidString
    var eventId: String
    var startDateTime: Date
    var numberOfParticipants = 0
    var creatorId: String
    var activityType: ActivityType
}
