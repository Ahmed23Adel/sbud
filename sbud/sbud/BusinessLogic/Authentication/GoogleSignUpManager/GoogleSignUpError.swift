//
//  GoogleSignUpError.swift
//  sbud
//
//  Created by ahmed on 09/12/2025.
//

import Foundation

enum GoogleSignUpError: Error{
    case missingClientID
    case cannotGetRootViewController
    case cannotFindIdToken
}
