//
//  HostInvitation.swift
//  sbud
//
//  Created by ahmed on 01/05/2026.
//

import Foundation

enum HostInvitationStatus: String{
    case pending
    case accepted
    case rejected
    case notInvited 
}

struct HostInvitation{
    var id = UUID()
    var invitedAt: Date
    var respondedAt: Date?
    var status: HostInvitationStatus
    var userId: String
    
}
