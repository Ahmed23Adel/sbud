//
//  LocalOnGoingSession.swift
//  sbud
//
//  Created by ahmed on 16/05/2026.
//

import Foundation
import SwiftData

@Model
class LocalOnGoingSession{
    var id: UUID
    var creatorId: String
    var eventId: String
    var startDateTime: Date
    var activityType: ActivityType
    
    init(creatorId: String, eventId: String, startDateTime: Date, activityType: ActivityType) {
        self.id = UUID()
        self.creatorId = creatorId
        self.eventId = eventId
        self.startDateTime = startDateTime
        self.activityType = activityType
    }
}
