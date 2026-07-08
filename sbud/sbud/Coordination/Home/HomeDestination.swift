//
//  HomeDestination.swift
//  sbud
//
//  Created by ahmed on 21/05/2026.
//

import Foundation
//  Scaffold for the Home tab coordinator.
//  Add routes, push destinations, and sheet types here as the tab is built out.
//  Uses the same pattern as AvailabilityCoordinator.
//
//
//  HomeDestination.swift
//  sbud
//
//  Created by ahmed on 21/05/2026.
//

import Foundation
//  Scaffold for the Home tab coordinator.
//  Add routes, push destinations, and sheet types here as the tab is built out.
//  Uses the same pattern as AvailabilityCoordinator.
//
import SwiftUI
import Combine

enum HomeDestination: Hashable, Equatable {
    case myEventDetail(eventId: String)
    case othersEventDetail(eventId: String)
    case profileView(userId: String)
    case othersEvents(userId: String)
    case myEvents(userId: String)
    case myEventDetails(eventId: String)
    case othersEventDetails(eventId: String)
    case friendsList(userId: String)
    case chat(user: UserProfile, eventId: String, eventTitle: String)

    static func == (lhs: HomeDestination, rhs: HomeDestination) -> Bool {
        switch (lhs, rhs) {
        case (.myEventDetail(let l), .myEventDetail(let r)): return l == r
        case (.othersEventDetail(let l), .othersEventDetail(let r)): return l == r
        case (.profileView(let l), .profileView(let r)): return l == r
        case (.othersEvents(let l), .othersEvents(let r)): return l == r
        case (.myEvents(let l), .myEvents(let r)): return l == r
        case (.myEventDetails(let l), .myEventDetails(let r)): return l == r
        case (.othersEventDetails(let l), .othersEventDetails(let r)): return l == r
        case (.friendsList(let l), .friendsList(let r)): return l == r
        case (.chat(let u1, let e1, let t1), .chat(let u2, let e2, let t2)):
            return u1.id == u2.id && e1 == e2 && t1 == t2
        default: return false
        }
    }

    func hash(into hasher: inout Hasher) {
        switch self {
        case .myEventDetail(let id): hasher.combine(0); hasher.combine(id)
        case .othersEventDetail(let id): hasher.combine(1); hasher.combine(id)
        case .profileView(let id): hasher.combine(2); hasher.combine(id)
        case .othersEvents(let id): hasher.combine(3); hasher.combine(id)
        case .myEvents(let id): hasher.combine(4); hasher.combine(id)
        case .myEventDetails(let id): hasher.combine(5); hasher.combine(id)
        case .othersEventDetails(let id): hasher.combine(6); hasher.combine(id)
        case .friendsList(let id): hasher.combine(7); hasher.combine(id)
        case .chat(let user, let eventId, _): hasher.combine(8); hasher.combine(user.id); hasher.combine(eventId)
        }
    }
}

enum HomeSheet: Identifiable {
    var id: String { "placeholder" }
}
