//
//  ViewModeOwnerSession.swift
//  sbud
//
//  Created by ahmed on 15/05/2026.
//

import Foundation
import OSLog

@Observable
class ViewModelOwnerSession{
    let logger = Logger(subsystem: "sbud", category: "ViewModelOwnerSession")
    let eventId: String
    
    var isShowAlert = false
    var alertMsg = ""
    
    init(eventId: String, isSessionCreated: Bool){
        self.eventId = eventId
        Task {
            do {
                if !isSessionCreated {
                    try await createSession()
                }
            } catch {
                showError("Error occured while starting the session, pleaes try again")
                logger.fault("Error with pinging: \(error)")
            }
        }
    }
    
    private func createSession() async throws  {
        logger.info("creating session doc...")
        let creatorId = ProfileManager.shared.getLocalProfile()!.id
        let session = OnGoingSession(eventId: eventId, startDateTime: Date(), creatorId: creatorId)
        let repo = OnGoingSessionRepository()
        try await repo.create(session)
    }
    
    private func showError(_ message: String) {
        alertMsg = message
        isShowAlert = true
    }
}

