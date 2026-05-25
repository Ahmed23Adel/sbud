//
//  AvailabilityRoute.swift
//  sbud
//
//  Created by ahmed on 27/12/2025.
//

import Foundation

//  Route types for the Availability tab.
//  AvailabilityRoute (the old unused enum) is removed.
//  All navigation goes through AvailabilityDestination (push) and AvailabilitySheet (sheet).
//

import Combine
import SwiftUI

// MARK: - Push Destinations

enum AvailabilityDestination: Hashable, Equatable {
    case moreInfoEvent(eventId: String)
    case addNewEvent
    case profile(userId: String)
    case chat(user: UserProfile, eventId: String, eventTitle: String)

    // Custom Equatable because UserProfile may not synthesize it
    static func == (lhs: AvailabilityDestination, rhs: AvailabilityDestination) -> Bool {
        switch (lhs, rhs) {
        case (.moreInfoEvent(let l), .moreInfoEvent(let r)):   return l == r
        case (.addNewEvent, .addNewEvent):                      return true
        case (.profile(let l), .profile(let r)):               return l == r
        case (.chat(let u1, let e1, let t1), .chat(let u2, let e2, let t2)):
            return u1.id == u2.id && e1 == e2 && t1 == t2
        default: return false
        }
    }

    func hash(into hasher: inout Hasher) {
        switch self {
        case .moreInfoEvent(let eventId):
            hasher.combine(0); hasher.combine(eventId)
        case .addNewEvent:
            hasher.combine(1)
        case .profile(let userId):
            hasher.combine(2); hasher.combine(userId)
        case .chat(let user, let eventId, let eventTitle):
            hasher.combine(3); hasher.combine(user.id)
            hasher.combine(eventId); hasher.combine(eventTitle)
        }
    }
}

// MARK: - Sheet Types

enum AvailabilitySheet: Identifiable, Equatable {
    case filter(availabilityFiltersResults: Binding<AvailabilityFiltersResults>)

    var id: String {
        switch self {
        case .filter:
            return "filter"
        }
    }

    static func == (lhs: AvailabilitySheet, rhs: AvailabilitySheet) -> Bool {
        switch (lhs, rhs) {
        case (.filter, .filter):
            return true
        }
    }
}
