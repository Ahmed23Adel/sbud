//
//  ViewModelSessionSummaryTimeBased.swift
//  sbud
//
//  Created by ahmed on 24/05/2026.
//

import Foundation
import Observation
import SwiftUI
import FirebaseAnalytics
import FirebaseAuth

/// Generic ViewModel for time-only activities: Gym, Swimming, Tennis, Yoga.
/// No GPS or split data — only duration metrics.
@Observable
class ViewModelSessionSummaryTimeBased<M: SessionMetricsBase>: SessionSummaryViewModel {

    typealias Metric = M

    // MARK: - SessionSummaryViewModel requirements

    var sessions: [SessionHistoryEntry] = []
    var selectedSessionIndex: Int = 0
    var allMetrics: [M] = []
    var profiles: [String: UserProfile] = [:]
    var isLoading = false
    var errorMessage: String?

    let eventId: String
    let metricsRepo: ActivityMetricsRepository<M>
    let userRepo = UserRepository()

    // MARK: - Init

    init(eventId: String, numSessions: Int,
         repo: ActivityMetricsRepository<M> = ActivityMetricsRepository()) {
        self.eventId    = eventId
        self.metricsRepo = repo
        Analytics.logEvent(AnalyticsEventScreenView, parameters: [
            AnalyticsParameterScreenName: "SessionSummary_TimeBased",
            "event_id": eventId
        ])
    }

    // MARK: - Participant summaries

    var participantSummaries: [ParticipantSummary] {
        sessionMetrics.enumerated().map { index, m in
            let elapsed = m.endDateTime.timeIntervalSince(m.startDateTime)
            let profile = m.userId.flatMap { profiles[$0] }
            let name    = profile.map { "\($0.name) \($0.surName)".trimmingCharacters(in: .whitespaces) }

            return ParticipantSummary(
                id: m.userId ?? "unknown_\(index)",
                displayIndex: index + 1,
                elapsedSeconds: elapsed,
                metricsCreatorType: m.metricsCreatorType,
                endedBeforeCreator: m.endedBeforeCreator,
                userName: name,
                profileImageUrl: profile?.profileImageUrl,
                receivedFeedbacks: profile?.receivedFeedbacks
            )
        }
    }
    
    func voteForFeedback(targetUserId: String, tag: String) async {
        guard let myUserId = FirebaseAuth.Auth.auth().currentUser?.uid else { return }
        guard var targetProfile = profiles[targetUserId] else { return }
        
        
        var currentFeedbacks = targetProfile.receivedFeedbacks ?? [:]
        
        
        if currentFeedbacks[myUserId] == tag { return }
        
       
        currentFeedbacks[myUserId] = tag
        targetProfile.receivedFeedbacks = currentFeedbacks
        
        self.profiles[targetUserId] = targetProfile
        
        // Forza l'aggiornamento della UI
        let updatedProfiles = self.profiles
        self.profiles = updatedProfiles
        
        //
        do {
            try await userRepo.giveFeedback(to: targetUserId, tag: tag, voterId: myUserId)
        } catch {
            print("Errore invio feedback: \(error)")
        }
    }
}
