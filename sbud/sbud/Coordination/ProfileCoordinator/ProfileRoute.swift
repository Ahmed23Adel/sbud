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
    case hostsRequests
    case myEvents
    case othersEvents
    case friendsList
    case editMyEvent
    case viewMyEventDetails (eventId: String)
}


enum ProfileSheetType: Equatable, Hashable, Identifiable{
    case hosts(eventId: String)
    
    var id: String {
        switch self {
            case .hosts(let eventId): return "hosts-\(eventId)"
        }
    }
}
