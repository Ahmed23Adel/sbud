//
//  ProfileRoute.swift
//  sbud
//
//  Created by ahmed on 01/05/2026.

//  Route types used exclusively by ProfileCoordinator.
//  No dead cases. editMyEvent removed — was never handled.
//

import Foundation

// MARK: - Root Route (which profile context we're in)

enum ProfileRoute: Equatable, Hashable {
    case myProfile
    case othersProfile
}

// MARK: - Pushed Routes (NavigationStack destinations)

enum ProfileRoutePushed: Equatable, Hashable {
    case settings
    case friendRequests
    case hostRequests
    case myEvents
    case othersEvents
    case friendsList
    case myEventDetails(eventId: String)
    case othersEventDetails(eventId: String)
    case othersProfile(userId: String)
    case scannedProfile(userId: String)
    case eventConversations(eventId: String, eventTitle: String)
}

// MARK: - Sheet Types

enum ProfileSheetType: Identifiable, Equatable, Hashable {
    case hosts(eventId: String)
    case qrCode

    var id: String {
        switch self {
        case .hosts(let eventId): return "hosts-\(eventId)"
        case .qrCode:             return "qrCode"
        }
    }
}
