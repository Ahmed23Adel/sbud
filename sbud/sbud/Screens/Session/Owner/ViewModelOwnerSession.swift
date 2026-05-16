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
    var mainCoordinator: MainCoordinator?
    let logger = Logger(subsystem: "sbud", category: "ViewModelOwnerSession")
    let eventDetails: EventFullDetails
    var isShowAlert = false
    var alertMsg = ""
    private var context: ModelContext?
    var startDateTime = Date()
    var isSessionCreated: Bool
    
    var metricsCollector: MetricsCollector?
    
    var isLoading = false
    var isShowEndConfirm = false
    init(eventDetails: EventFullDetails, isSessionCreated: Bool){
        self.eventDetails = eventDetails
        self.isSessionCreated = isSessionCreated
        initMetricsCollector()
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
    
    func setMainCoordinator(_ mainCoordinator: MainCoordinator){
        self.mainCoordinator = mainCoordinator
    }
    
    private func initMetricsCollector(){
        switch eventDetails.activityType{
            
        case .running:
            metricsCollector = MetricsCollectorRun(isCreator: true)
            (metricsCollector as! MetricsCollectorRun).startSession()
        case .cycling:
            metricsCollector = MetricsCollectorCycling(isCreator: true)
            (metricsCollector as! MetricsCollectorCycling).startSession()
        case .gym:
            metricsCollector = MetricsCollectorGym(isCreator: true)
            (metricsCollector as! MetricsCollectorGym).startSession()
        case .skiing:
            metricsCollector = MetricsCollectorSkiing(isCreator: true)
            (metricsCollector as! MetricsCollectorSkiing).startSession()
        case .swimming:
            metricsCollector = MetricsCollectorSwimming(isCreator: true)
            (metricsCollector as! MetricsCollectorSwimming).startSession()
        case .hiking:
            metricsCollector = MetricsCollectorHiking(isCreator: true)
            (metricsCollector as! MetricsCollectorHiking).startSession()
        case .yoga:
            metricsCollector = MetricsCollectorYoga(isCreator: true)
            (metricsCollector as! MetricsCollectorYoga).startSession()
        case .tennis:
            metricsCollector = MetricsCollectorTennis(isCreator: true)
            (metricsCollector as! MetricsCollectorTennis).startSession()
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
    
    
    
    func endSession(){
        isLoading = true
        Task {
            do {
                try await metricsCollector?.endSession(event: eventDetails)
                let repo = OnGoingSessionRepository()
                try await repo.deleteByEventId(eventDetails.id)
                deleteLocalSession()
                await MainActor.run{
                    isLoading = false
                }
                logger.info("navigating to home ")
                print("main coord", mainCoordinator)
                mainCoordinator?.navigateTo(.homePage)
               
            } catch {
                logger.fault("Error with ending session: \(error)")
                showError("Error with ending the session, please try again")
            }
            
        }
    }
    
    private func deleteLocalSession() {
        let eventId = eventDetails.id
        let descriptor = FetchDescriptor<LocalOnGoingSession>(
            predicate: #Predicate { $0.eventId == eventId }
        )
        if let sessions = try? context?.fetch(descriptor) {
            sessions.forEach { context?.delete($0) }
        }
    }
}

