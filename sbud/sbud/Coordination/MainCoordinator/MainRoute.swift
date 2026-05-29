//
//  MainRoute.swift
//  sbud
//
//  Created by ahmed on 10/12/2025.
//

import Foundation
//
//  Root-level routes. Each case represents a full-screen state
//  managed by MainCoordinator. No dead cases, no unused associated values.
//

import Foundation

enum MainRoute: Equatable, Hashable {
    case loading
    case signUp
    case signIn
    case profileSetup
    case home
    case creatorSession(eventDetails: EventFullDetails, isSessionCreated: Bool)
    case othersSession(eventDetails: EventFullDetails, isSessionCreated: Bool)
    case sessionSummary(eventDetails: EventFullDetails)
}
