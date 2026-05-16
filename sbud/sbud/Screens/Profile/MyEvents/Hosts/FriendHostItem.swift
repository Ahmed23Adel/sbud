//
//  FriendHostItem.swift
//  sbud
//
//  Created by ahmed on 02/05/2026.
//

import Foundation

enum FriendHostState {
    case host          // accepted
    case pending       // invitation sent, not responded
    case rejected      // invitation declined
    case notInvited    // friend with no invitation doc
}

struct FriendHostItem: Identifiable {
    let id: String          // userId
    let profile: UserProfile
    let invitation: HostInvitation?
    
    var state: FriendHostState {
        guard let inv = invitation else { return .notInvited }
        switch inv.status {
        case .accepted: return .host
        case .pending:  return .pending
        case .rejected: return .rejected
        case .notInvited: return .notInvited
        }
    }
}
