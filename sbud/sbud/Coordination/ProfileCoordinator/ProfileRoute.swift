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
}
