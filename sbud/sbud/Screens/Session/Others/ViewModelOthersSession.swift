//
//  ViewModelOthersSession.swift
//  sbud
//
//  Created by ahmed on 16/05/2026.
//

import Foundation
import OSLog
import SwiftData
import FirebaseFirestore
import FirebaseAnalytics

@Observable
class ViewModelOthersSession {

    // MARK: - Public state
    var mainCoordinator: MainCoordinator?
    let eventDetails: EventFullDetails
    var isSessionCreated: Bool
    var startDateTime = Date()
    var metricsCollector: MetricsCollector?
    var isLoading = false

    // Alert / confirmation state
    var isShowAlert = false
    var alertMsg = ""
    var isShowSimpleConfirm = false       // creator already ended → plain "Are you sure?"
    var isShowEarlyEndWarning = false     // creator hasn't ended → warn about exclusion

    // MARK: - Private
    private var context: ModelContext?
    private let logger = Logger(subsystem: "sbud", category: "ViewModelOthersSession")

    // MARK: - Init

    init(eventDetails: EventFullDetails, isSessionCreated: Bool) {
        self.eventDetails = eventDetails
        self.isSessionCreated = isSessionCreated
        Analytics.logEvent(AnalyticsEventScreenView, parameters: [
            AnalyticsParameterScreenName: "LiveSession_Participant",
            "activity_type": eventDetails.activityType.rawValue,
            "event_id": eventDetails.id
        ])
        initMetricsCollector()
    }

    // MARK: - Setup

    func setMainCoordinator(_ coordinator: MainCoordinator) {
        mainCoordinator = coordinator
    }

    func setModelContext(context: ModelContext) {
        self.context = context
    }

    private func initMetricsCollector() {
        logger.info("in initMetricsCollector: eventDetails.numSessions\(self.eventDetails.numSessions)")
        switch eventDetails.activityType {
        case .running:
            metricsCollector = MetricsCollectorRun(isCreator: false, numSessions: eventDetails.numSessions)
            (metricsCollector as! MetricsCollectorRun).startSession(eventId: eventDetails.id)
        case .cycling:
            metricsCollector = MetricsCollectorCycling(isCreator: false, numSessions: eventDetails.numSessions)
            (metricsCollector as! MetricsCollectorCycling).startSession(eventId: eventDetails.id)
        case .gym:
            metricsCollector = MetricsCollectorGym(isCreator: false, numSessions: eventDetails.numSessions)
            (metricsCollector as! MetricsCollectorGym).startSession(eventId: eventDetails.id)
        case .skiing:
            metricsCollector = MetricsCollectorSkiing(isCreator: false, numSessions: eventDetails.numSessions)
            (metricsCollector as! MetricsCollectorSkiing).startSession(eventId: eventDetails.id)
        case .swimming:
            metricsCollector = MetricsCollectorSwimming(isCreator: false, numSessions: eventDetails.numSessions)
            (metricsCollector as! MetricsCollectorSwimming).startSession(eventId: eventDetails.id)
        case .hiking:
            metricsCollector = MetricsCollectorHiking(isCreator: false, numSessions: eventDetails.numSessions)
            (metricsCollector as! MetricsCollectorHiking).startSession(eventId: eventDetails.id)
        case .yoga:
            metricsCollector = MetricsCollectorYoga(isCreator: false, numSessions: eventDetails.numSessions)
            (metricsCollector as! MetricsCollectorYoga).startSession(eventId: eventDetails.id)
        case .tennis:
            metricsCollector = MetricsCollectorTennis(isCreator: false, numSessions: eventDetails.numSessions)
            (metricsCollector as! MetricsCollectorTennis).startSession(eventId: eventDetails.id)
        }
    }

    // MARK: - Local session persistence (mirrors owner behaviour)

    func saveSessionLocally() {
        logger.info("Saving participant session locally...")
        let userId = ProfileManager.shared.getLocalProfile()!.id
        let session = LocalOnGoingSession(
            creatorId: userId,
            eventId: eventDetails.id,
            startDateTime: Date(),
            activityType: eventDetails.activityType
        )
        context?.insert(session)
    }

    func readLocalSessionDetails() {
        logger.info("Reading from local db")
        let eventId = eventDetails.id
        var descriptor = FetchDescriptor<LocalOnGoingSession>(
            predicate: #Predicate { $0.eventId == eventId }
        )
        descriptor.fetchLimit = 1

        guard let result = try? context?.fetch(descriptor).first else { return }
        logger.info("Start datetime read: \(result.startDateTime)")
        startDateTime = result.startDateTime

        // For time-only collectors, rewind the elapsed timer to
        // account for time before the crash/relaunch
        switch metricsCollector {
        case let gym as MetricsCollectorGym:
            gym.restoreStartDate(result.startDateTime)
        case let swim as MetricsCollectorSwimming:
            swim.restoreStartDate(result.startDateTime)
        case let yoga as MetricsCollectorYoga:
            yoga.restoreStartDate(result.startDateTime)
        case let tennis as MetricsCollectorTennis:
            tennis.restoreStartDate(result.startDateTime)
        default:
            break
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

    // MARK: - End session flow

    /// Called by the "End session" button — checks Firestore first, then shows the right dialog.
    func onEndSessionTapped() {
        isLoading = true
        Task {
            do {
                let creatorHasEnded = try await checkIfCreatorHasEnded()
                await MainActor.run {
                    isLoading = false
                    if creatorHasEnded {
                        isShowSimpleConfirm = true
                    } else {
                        isShowEarlyEndWarning = true
                    }
                }
            } catch {
                logger.fault("Failed to check creator end status: \(error)")
                await MainActor.run {
                    isLoading = false
                    isShowSimpleConfirm = true
                }
            }
        }
    }

    private func checkIfCreatorHasEnded() async throws -> Bool {
        let db = Firestore.firestore()
        let snapshot = try await db.collection("Events").document(eventDetails.id).getDocument()
        return snapshot.data()?["finalEndDateTime"] != nil
    }

    /// Called after the user confirms either dialog.
    func endSession() {
        isLoading = true
        Task {
            do {
                try await metricsCollector?.endSession(event: eventDetails)
                deleteLocalSession()
                await MainActor.run {
                    isLoading = false
                    mainCoordinator?.goToSessionSummary(eventDetails: eventDetails)
                }
            } catch {
                logger.fault("Error ending participant session: \(error)")
                await MainActor.run {
                    isLoading = false
                    showError("Error ending the session, please try again")
                }
            }
        }
    }

    // MARK: - Helpers

    private func showError(_ message: String) {
        alertMsg = message
        isShowAlert = true
    }
}
