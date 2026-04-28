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


    func hash(into hasher: inout Hasher) {
        switch self {
        case .moreInfoEvent(let eventId):
            hasher.combine(eventId)
        case .addNewEvent:
            hasher.combine("addNewEvent")
        }
    }
}
