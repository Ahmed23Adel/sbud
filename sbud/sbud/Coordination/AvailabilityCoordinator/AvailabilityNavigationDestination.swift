//
//  AvailabilityNavigationDestination.swift
//  sbud
//
//  Created by ahmed on 03/02/2026.
//

import Foundation

enum AvailabilityNavigationDestination: Hashable {
    case moreInfoEvent(AvailabilityEvent)
    case addNewEvent

    static func == (lhs: AvailabilityNavigationDestination,
                    rhs: AvailabilityNavigationDestination)
    -> Bool {
        switch (lhs, rhs) {
        case (.moreInfoEvent(let a), .moreInfoEvent(let b)):
            return a.id == b.id
        case (.addNewEvent, .addNewEvent):
            return true
        default:
            return false
        }
    }

    func hash(into hasher: inout Hasher) {
        switch self {
        case .moreInfoEvent(let event):
            hasher.combine(event.id)
        case .addNewEvent:
            hasher.combine("addNewEvent")
        }
    }
}
