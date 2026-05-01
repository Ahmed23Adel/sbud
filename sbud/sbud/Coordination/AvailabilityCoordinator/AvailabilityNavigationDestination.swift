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
    case chat(user: UserProfile, eventId: String) // NUOVO CASO

    // To conform chat to Equatable (it s necessarly to management of UserProfile)
    static func == (lhs: AvailabilityNavigationDestination, rhs: AvailabilityNavigationDestination) -> Bool {
        switch (lhs, rhs) {
        case (.moreInfoEvent(let l), .moreInfoEvent(let r)): return l == r
        case (.addNewEvent, .addNewEvent): return true
        case (.creatorProfile(let l), .creatorProfile(let r)): return l == r
        case (.chat(let u1, let e1), .chat(let u2, let e2)): return u1.id == u2.id && e1 == e2
        default: return false
        }
    }
    
    //hashable
    func hash(into hasher: inout Hasher) {
        switch self {
        case .moreInfoEvent(let eventId):
            hasher.combine(eventId)
        case .addNewEvent:
            hasher.combine("addNewEvent")
        case .creatorProfile(let userId):
            hasher.combine(userId)
        case .chat(let user, let eventId): //Management chat hash
            hasher.combine("chat")
            hasher.combine(user.id)
            hasher.combine(eventId)
        }
    }
}
