//
//  ViewModelOthersEventDetails.swift
//  sbud
//
//  Created by ahmed on 15/05/2026.
//

import Foundation
import OSLog
import FirebaseFirestore

@Observable
class ViewModelOthersEventDetails{
    let logger = Logger(subsystem: "sBud", category: "ViewModelOthersEventDetails")
    
    
    var myEventDertails: EventFullDetails? = nil
    var isLoading: Bool = false
    var eventId: String
    
    var isShowJoinSessionButton = false
    init(eventId: String) {
        logger.info("eventId: \(eventId)")
        self.eventId = eventId
        Task { await loadDetails() }
        isSessionCreated(eventId: eventId)
    }

    private func loadDetails() async {
        await MainActor.run { isLoading = true }
        do {
            let requester = EventByIdRequester()
            let details = try await requester.fetchEvent(eventId: eventId)
            await MainActor.run {
                myEventDertails = details
                isLoading = false
            }
            logger.log("Full others event loaded \(self.eventId)")
        } catch {
            logger.error("Error: \(error)")
            await MainActor.run { isLoading = false }
            PopUpGenerator.shared.show(msg: "Error loading the event", type: .error)
        }
    }
    
    private func isSessionCreated(eventId: String){
        Task {
            let repo = OnGoingSessionRepository()
            var queryRef = repo.initQueryBuilderObject()
            queryRef = queryRef.appendFilter(Filter(field: repo.constants.eventId, operation: .isEqualTo, value: eventId))
            let sessions = try await repo.fetch(query: queryRef)
            logger.info("sessions count: \(sessions.count)")
            if sessions.count == 0 {
                isShowJoinSessionButton = false
            } else {
                isShowJoinSessionButton = true
            }
        }
    }
}
