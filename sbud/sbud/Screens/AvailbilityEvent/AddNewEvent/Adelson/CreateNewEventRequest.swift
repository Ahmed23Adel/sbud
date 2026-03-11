//
//  CreateNewEventRequest.swift
//  sbud
//
//  Created by ahmed on 11/03/2026.
//

import Foundation
import FirebaseFirestore

enum GymDayType: String, Encodable{
    case push = "Push"
    case pull = "Pull"
    case leg = "Leg"
    case arm = "Arm"
}
protocol RequestActivityDetails: Encodable, Sendable{
    var activityType: String { get set }
}

nonisolated struct RequestActivityDetailsRunning: RequestActivityDetails{
    var activityType = "Running"
    var targetDistanceInKm: Double
    var targetPace: Double
}

nonisolated struct RequestActivityDetailsCycling: RequestActivityDetails{
    var activityType = "Cycling"
    var dayType: Double
    
}

nonisolated struct RequestActivityDetailsGym: RequestActivityDetails{
    var activityType = "Gym"
    var dayTyp: GymDayType
}

nonisolated struct DateLocation: Encodable, Sendable {
    var startDateTime: String
    var endDateTime: String
    var locations: [GeoPoint]
}

struct CreateNewEventRequest: Encodable, Sendable {
    // bcz this is protocol, it need encode func
    var activityDetails: any RequestActivityDetails
    var eventImage: String
    var isDateConfirmed: Bool
    var isLocationConfirmed: Bool
    var isPublic: Bool
    var joiningCondition: String
    var maxAllowedToJoin: Int
    var notes: String
    var dateLocations: [DateLocation]

    enum CodingKeys: String, CodingKey {
        case activityDetails, eventImage, isDateConfirmed, isLocationConfirmed
        case isPublic, joiningCondition, maxAllowedToJoin, notes, dateLocations
    }

    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(activityDetails, forKey: .activityDetails)
        try container.encode(eventImage, forKey: .eventImage)
        try container.encode(isDateConfirmed, forKey: .isDateConfirmed)
        try container.encode(isLocationConfirmed, forKey: .isLocationConfirmed)
        try container.encode(isPublic, forKey: .isPublic)
        try container.encode(joiningCondition, forKey: .joiningCondition)
        try container.encode(maxAllowedToJoin, forKey: .maxAllowedToJoin)
        try container.encode(notes, forKey: .notes)
        try container.encode(dateLocations, forKey: .dateLocations)
    }
}
