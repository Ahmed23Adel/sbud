//
//  MainRoute.swift
//  sbud
//
//  Created by ahmed on 10/12/2025.
//

import Foundation

enum MainRoute: Equatable, Hashable {
    case loadingPage
    case profileSetup
    case signUp
    case signIn
    case homePage
    case profilePage(userId: String)
    case myEvents(userId: String)
    case editMyEvent(userId: String)
    case settingsPage
    case friendList(userId: String)
    case friendRequests
}
