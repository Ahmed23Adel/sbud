//
//  JoinedEvent.swift
//  sbud
//
//  Created by ahmed on 22/05/2026.
//

import Foundation
enum ParticipationStatus: String, Codable {
    case host = "host"
    case participant = "participant"
}

struct JoinedEvent: Codable, Identifiable {
    var id = UUID()
    var activityType: ActivityType = .running
    var title: String = ""
    var eventImage: String = ""
    var status: UsersEventStatus = .proposed
    var eventId: String = ""
    var participationStatus: ParticipationStatus = .participant
    var userId: String = ""
    var userFirstName: String = ""
    var userLastName: String = ""
    var userProfileImageUrl: String = ""
    var joinedAt: Date = .now

    enum CodingKeys: String, CodingKey {
        case activityType
        case title
        case eventImage
        case status
        case eventId
        case participationStatus
        case userId
        case userFirstName
        case userLastName
        case userProfileImageUrl
        case joinedAt
    }
    
    func toUserEvent()-> UsersEvent{
        UsersEvent(
            id: UUID(),
            activityType: activityType,
            title: title,
            eventImage: eventImage,
            status: status,
            eventId: eventId)
    }
}
