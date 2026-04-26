//
//  MainRoute.swift
//  sbud
//
//  Created by ahmed on 10/12/2025.
//

import Foundation

enum MainRoute: Equatable {
    case loadingPage
    case profileSetup
    case signUp
    case signIn
    case homePage
    case profilePage(userId: String)
}
