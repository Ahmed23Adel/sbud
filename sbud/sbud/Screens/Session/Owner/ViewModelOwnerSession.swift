//
//  ViewModeOwnerSession.swift
//  sbud
//
//  Created by ahmed on 15/05/2026.
//

import Foundation
import OSLog
import SwiftData
@Observable
class ViewModelOwnerSession{
    let logger = Logger(subsystem: "sbud", category: "ViewModelOwnerSession")
    let eventDetails: EventFullDetails
    var isShowAlert = false
    var alertMsg = ""
    private var context: ModelContext?
    var startDateTime = Date()
    var isSessionCreated: Bool
    
    init(eventDetails: EventFullDetails, isSessionCreated: Bool){
        self.eventDetails = eventDetails
        self.isSessionCreated = isSessionCreated
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
    
    func setModelContext(context: ModelContext){
        self.context = context
    }
    private func createSession() async throws  {
        logger.info("creating session doc...")
        let creatorId = ProfileManager.shared.getLocalProfile()!.id
        let session = OnGoingSession(
            eventId: eventDetails.id,
            startDateTime: Date(),
            creatorId: creatorId,
            activityType: eventDetails.activityType
        )
        let repo = OnGoingSessionRepository()
        try await repo.create(session)
        
        
    }
    
    
    func saveSessoinLocally(){
        logger.info("Saving session locally...")
        let creatorId = ProfileManager.shared.getLocalProfile()!.id
        let session = LocalOnGoingSession(
            creatorId: creatorId,
            eventId: eventDetails.id,
            startDateTime: Date(),
            activityType: eventDetails.activityType
        )
        context?.insert(session)
        
    }
    
    func readLocalSessionDetails(){
        logger.info("Reading from local db")
        let eventId = eventDetails.id
        var descriptor = FetchDescriptor<LocalOnGoingSession>(
            predicate: #Predicate {
                $0.eventId == eventId
            }
        )
        descriptor.fetchLimit = 1
        let result = try? context?.fetch(descriptor).first
        if let result {
            logger.info("StartDate time read: \(result.startDateTime)")
            startDateTime = result.startDateTime
        }
        
    }
    private func showError(_ message: String) {
        alertMsg = message
        isShowAlert = true
    }
    
    
}

