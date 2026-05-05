//
//  ProfileRoute.swift
//  sbud
//
//  Created by ahmed on 01/05/2026.
//

import Foundation

enum ProfileRoute: Equatable, Hashable{
    case myProfile
    case othersProfile
}


enum ProfileRoutePushed: Equatable, Hashable{
    case settings
    case friendRequest
    case myEvents
    case othersEvents
    case friendsList
    case editMyEvent
    case viewMyEventDetails (eventId: String)
    case eventConversations(eventId: String, eventTitle: String)
    case scannedProfile(userId: String)
}


enum ProfileSheetType: Equatable, Hashable, Identifiable{
    case hosts(eventId: String)
    case qrCode
    
    var id: String {
        switch self {
            case .hosts(let eventId): return "hosts-\(eventId)"
            case .qrCode:             return "qrCode"
        }
    }
}
