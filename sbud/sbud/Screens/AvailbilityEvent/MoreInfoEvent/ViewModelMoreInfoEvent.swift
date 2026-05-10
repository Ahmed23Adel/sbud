//
//  ViewModelMoreInfoEvent.swift
//  sbud
//
//  Created by ahmed on 02/02/2026.
//

import Foundation
import OSLog

@Observable
class ViewModelMoreInfoEvent {
    let eventId: String
    let logger = Logger(subsystem: "sBud", category: "MoreInfo")

    var role: EventUserRole? = nil
    var isLoading = false

    init(eventId: String) {
        self.eventId = eventId
        Task { await loadRole() }
    }

    private func loadRole() async {
        await MainActor.run { isLoading = true }
        let resolvedRole = await EventRoleService.getRole(eventId: eventId)
        print("🔑 ROLE:", resolvedRole)  
        await MainActor.run {
            role = resolvedRole
            isLoading = false
        }
    }
}
