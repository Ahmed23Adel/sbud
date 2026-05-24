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

    // MARK: - Refresh

    /// Re-fetches event details and re-checks whether an active session exists.
    /// Called by pull-to-refresh in the view.
    func refresh() async {
        await loadDetails()
        await checkSession()
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
    
    private func isSessionCreated(eventId: String) {
        Task { await checkSession() }
    }

    /// Async version used by both the init-time check and pull-to-refresh.
    private func checkSession() async {
        let repo = OnGoingSessionRepository()
        var queryRef = repo.initQueryBuilderObject()
        queryRef = queryRef.appendFilter(Filter(field: repo.constants.eventId, operation: .isEqualTo, value: eventId))
        do {
            let sessions = try await repo.fetch(query: queryRef)
            logger.info("sessions count: \(sessions.count)")
            isShowJoinSessionButton = sessions.count != 0
        } catch {
            logger.error("Error checking session status: \(error)")
        }
    }
}
