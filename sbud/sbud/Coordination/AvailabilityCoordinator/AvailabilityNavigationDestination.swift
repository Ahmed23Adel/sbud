//
//  AvailabilityNavigationDestination.swift
//  sbud
//
//  Created by ahmed on 03/02/2026.
//

import Foundation

enum AvailabilityNavigationDestination: Hashable {
    case moreInfoEvent(String)
    case addNewEvent
    case creatorProfile(userId: String)

    func hash(into hasher: inout Hasher) {
        switch self {
        case .moreInfoEvent(let eventId):
            hasher.combine(eventId)
        case .addNewEvent:
            hasher.combine("addNewEvent")
        case .creatorProfile(let userId):
            hasher.combine(userId)
        }
    }
}
