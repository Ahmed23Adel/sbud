//
//  UpdateEventRequest.swift
//  sbud
//
//  Created by Erdal on 1.06.2026.
//

import Foundation
import FirebaseFirestore

nonisolated struct UpdateEventRequest: Encodable, Sendable {
    var activityDetails: any ExtraArgsHolderForSport
    var title: String
    var eventImage: String
    var isPublic: Bool
    var joiningCondition: JoinCondition
    var maxAllowedToJoin: Int
    var notes: String
    var dateLocations: [DateLocations]

    enum CodingKeys: String, CodingKey {
        case activityDetails, eventImage
        case isPublic, joiningCondition, maxAllowedToJoin, notes, dateLocations, title
    }

    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(title, forKey: .title)
        try container.encode(activityDetails, forKey: .activityDetails)
        try container.encode(eventImage, forKey: .eventImage)
        try container.encode(isPublic, forKey: .isPublic)
        try container.encode(joiningCondition, forKey: .joiningCondition)
        try container.encode(maxAllowedToJoin, forKey: .maxAllowedToJoin)
        try container.encode(notes, forKey: .notes)
        try container.encode(dateLocations, forKey: .dateLocations)
    }
}
