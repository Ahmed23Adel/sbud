//
//  MainRoute.swift
//  sbud
//
//  Created by ahmed on 10/12/2025.
//

import Foundation

enum MainRoute : Equatable{
    case signUp
    case signIn
    case homePage
    case phoneLogin
    case otpVerification(verificationID: String, phoneNumber: String)
    case completeProfile(phoneNumber: String)
}
