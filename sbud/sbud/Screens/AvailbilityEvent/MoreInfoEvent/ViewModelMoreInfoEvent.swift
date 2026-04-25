//
//  ViewModelMoreInfoEvent.swift
//  sbud
//
//  Created by ahmed on 02/02/2026.
//

import Foundation
import Combine
import OSLog

@Observable
class ViewModelMoreInfoEvent: ObservableObject {
    let event: AvailabilityEvent
    let logger = Logger(subsystem: "sBud", category: "MoreInfo")

    var fullDetails: EventFullDetails? = nil
    var isLoading: Bool = false
    var isErrorLoading: Bool = false

    init(event: AvailabilityEvent) {
        logger.info("Selected activity: \(event.id)")
        self.event = event

        #if DEBUG
        if let existing = event.fullDatailedEvent {
            fullDetails = existing
            return
        }
        #endif

        Task { await loadDetails() }
    }

    private func loadDetails() async {
        await MainActor.run { isLoading = true }
        do {
            let requester = EventByIdRequester()
            let details = try await requester.fetchEvent(eventId: event.eventId)
            await MainActor.run {
                fullDetails = details
                isLoading = false
                isErrorLoading = false
            }
            logger.log("Full event loaded \(self.event.eventId)")
        } catch {
            logger.error("Error: \(error)")
            await MainActor.run {
                isErrorLoading = true
                isLoading = false
            }
            PopUpGenerator.shared.show(msg: "Error loading the event", type: .error)
        }
    }
}
