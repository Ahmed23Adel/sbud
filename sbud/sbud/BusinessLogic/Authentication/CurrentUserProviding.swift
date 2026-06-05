//
//  CurrentUserProviding.swift
//  sbud
//

import Foundation
import FirebaseAuth

protocol CurrentUserProviding {
    var currentUserId: String? { get }
}

struct FirebaseCurrentUserProvider: CurrentUserProviding {
    var currentUserId: String? { Auth.auth().currentUser?.uid }
}
