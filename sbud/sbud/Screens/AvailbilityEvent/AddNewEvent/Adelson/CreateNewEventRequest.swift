//
//  CreateNewEventRequest.swift
//  sbud
//
//  Created by ahmed on 11/03/2026.
//

import Foundation
import FirebaseFirestore

enum GymDayType: String, Encodable, CaseIterable{
    case push = "Push"
    case pull = "Pull"
    case leg = "Leg"
    case arm = "Arm"
}

enum JoinCondition: String, Encodable, CaseIterable {
    case autoJoin = "Auto join"
    case requestFromCreator = "Ask from creator"
    case requestFromHost = "Ask from hosts"
    
    
    func encode(to encoder: any Encoder) throws {
        var container = encoder.singleValueContainer()
        switch self {
        case .autoJoin:
            try container.encode("autoJoin")
        case .requestFromCreator:
            try container.encode("requestFromCreator")
        case .requestFromHost:
            try container.encode("requestFromHost")
        }
    }
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
    var powerInWatt: Double
    var cadenceInRPM: Double
    
}

nonisolated struct RequestActivityDetailsGym: RequestActivityDetails{
    var activityType = "Gym"
    var dayTyp: GymDayType
}

nonisolated struct DateLocations: Encodable, Sendable {
    var id = UUID()
    var startDateTime: Date
    var endDateTime: Date
    var locations: [GeoPoint]
    
    enum CodingKeys: String, CodingKey {
        case startDateTime
        case endDateTime
        case locations
    }
    
    func encode(to encoder: any Encoder) throws {
        let formatter = ISO8601DateFormatter()
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(formatter.string(from: startDateTime), forKey: .startDateTime)
        try container.encode(formatter.string(from: endDateTime), forKey: .endDateTime)
        try container.encode(locations, forKey: .locations)
    }
}

nonisolated struct CreateNewEventRequest: Encodable, Sendable {
    // bcz this is protocol, it need encode func
    var activityDetails: any RequestActivityDetails
    var title: String
    var eventImage: String
    var isDateConfirmed = false
    var isLocationConfirmed = false
    var isPublic: Bool
    var joiningCondition: JoinCondition
    var maxAllowedToJoin: Int
    var notes: String
    var dateLocations: [DateLocations]

    enum CodingKeys: String, CodingKey {
        case activityDetails, eventImage, isDateConfirmed, isLocationConfirmed
        case isPublic, joiningCondition, maxAllowedToJoin, notes, dateLocations, title
    }

    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(title, forKey: .title)
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
