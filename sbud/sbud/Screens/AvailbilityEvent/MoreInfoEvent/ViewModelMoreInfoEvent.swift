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
    let eventId: String
    let logger = Logger(subsystem: "sBud", category: "MoreInfo")

    var fullDetails: EventFullDetails? = nil
    var isLoading: Bool = false
    var isErrorLoading: Bool = false

    init(eventId: String) {
        logger.info("Selected activity: \(eventId)")
        self.eventId = eventId

//        #if DEBUG
//        if let existing = event.fullDatailedEvent {
//            fullDetails = existing
//            return
//        }
//        #endif
        Task { await loadDetails() }
    }

    private func loadDetails() async {
        await MainActor.run { isLoading = true }
        do {
            let requester = EventByIdRequester()
            let details = try await requester.fetchEvent(eventId: eventId)
            await MainActor.run {
                fullDetails = details
                isLoading = false
                isErrorLoading = false
            }
            logger.log("Full event loaded \(self.eventId)")
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
