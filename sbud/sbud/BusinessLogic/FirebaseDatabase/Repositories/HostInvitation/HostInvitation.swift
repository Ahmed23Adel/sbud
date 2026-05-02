//
//  HostInvitation.swift
//  sbud
//
//  Created by ahmed on 01/05/2026.
//

import Foundation


struct HostInvitation{
    var id = UUID()
    var invitedAt: Date
    var respondedAt: Date?
    var status: String
}
