//
//  ViewModelSessionSummaryTimeBased.swift
//  sbud
//
//  Created by ahmed on 24/05/2026.
//

import Foundation
import Observation
import SwiftUI

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
                profileImageUrl: profile?.profileImageUrl
            )
        }
    }
}
