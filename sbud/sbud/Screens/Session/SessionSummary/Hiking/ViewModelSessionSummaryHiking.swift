//
//  ViewModelSessionSummaryHiking.swift
//  sbud
//
//  Created by ahmed on 24/05/2026.
//

import Foundation
import Observation
import SwiftUI

@Observable
class ViewModelSessionSummaryHiking: SessionSummaryViewModel {

    typealias Metric = MetricsCollectedHiking

    // MARK: - SessionSummaryViewModel requirements

    var sessions: [SessionHistoryEntry] = []
    var selectedSessionIndex: Int = 0
    var allMetrics: [MetricsCollectedHiking] = []
    var profiles: [String: UserProfile] = [:]
    var isLoading = false
    var errorMessage: String?

    let eventId: String
    let metricsRepo: ActivityMetricsRepository<MetricsCollectedHiking>
    let userRepo = UserRepository()

    // MARK: - Init

    init(eventId: String, numSessions: Int,
         repo: ActivityMetricsRepository<MetricsCollectedHiking> = ActivityMetricsRepository()) {
        self.eventId    = eventId
        self.metricsRepo = repo
    }

    // MARK: - Participant summaries

    var participantSummaries: [ParticipantSummary] {
        sessionMetrics.enumerated().map { index, m in
            let elapsed  = m.endDateTime.timeIntervalSince(m.startDateTime)
            let pace     = m.totalDistance > 0 ? (elapsed / 60) / (m.totalDistance / 1000) : 0
            let bestPace = m.splits.map(\.paceMinPerKm).min() ?? 0
            let profile  = m.userId.flatMap { profiles[$0] }
            let name     = profile.map { "\($0.name) \($0.surName)".trimmingCharacters(in: .whitespaces) }

            let displaySplits: [DisplaySplit] = m.splits.map { s in
                DisplaySplit(number: s.number, chartValue: s.paceMinPerKm,
                             displayText: SummaryFormatters.pace(s.paceMinPerKm), isSpeed: false)
            }

            return ParticipantSummary(
                id: m.userId ?? "unknown_\(index)",
                displayIndex: index + 1,
                elapsedSeconds: elapsed,
                metricsCreatorType: m.metricsCreatorType,
                endedBeforeCreator: m.endedBeforeCreator,
                userName: name,
                profileImageUrl: profile?.profileImageUrl,
                totalDistanceKm: m.totalDistance / 1000,
                track: m.track,
                avgPaceMinPerKm: pace,
                bestSplitPace: bestPace,
                elevationGainM: m.elevationGain,
                elevationLossM: m.elevationLoss,
                maxAltitudeM: m.maxAltitude,
                splits: displaySplits
            )
        }
    }

    // MARK: - Aggregate metrics

    var avgPaceMinPerKm: Double {
        let v = participantSummaries.compactMap { $0.avgPaceMinPerKm > 0 ? $0.avgPaceMinPerKm : nil }
        guard !v.isEmpty else { return 0 }
        return v.reduce(0, +) / Double(v.count)
    }

    var bestPaceMinPerKm: Double {
        participantSummaries.map(\.avgPaceMinPerKm).filter { $0 > 0 }.min() ?? 0
    }

    var avgDistanceKm: Double {
        guard !participantSummaries.isEmpty else { return 0 }
        return participantSummaries.map(\.totalDistanceKm).reduce(0, +) / Double(participantSummaries.count)
    }

    // MARK: - Insights

    var paceInsights: MetricInsights? {
        makeInsights(values: participantSummaries.compactMap { s in
            s.avgPaceMinPerKm > 0 ? (s, s.avgPaceMinPerKm) : nil
        })
    }

    var distanceInsights: MetricInsights? {
        makeInsights(values: participantSummaries.compactMap { s in
            s.totalDistanceKm > 0 ? (s, s.totalDistanceKm) : nil
        })
    }

    var elevationGainInsights: MetricInsights? {
        makeInsights(values: participantSummaries.compactMap { s in
            s.elevationGainM > 0 ? (s, s.elevationGainM) : nil
        })
    }

    var elevationLossInsights: MetricInsights? {
        makeInsights(values: participantSummaries.compactMap { s in
            s.elevationLossM > 0 ? (s, s.elevationLossM) : nil
        })
    }

    private func makeInsights(values: [(ParticipantSummary, Double)]) -> MetricInsights? {
        guard !values.isEmpty else { return nil }
        let avg = values.map(\.1).reduce(0, +) / Double(values.count)
        let lo  = values.min(by: { $0.1 < $1.1 })!
        let hi  = values.max(by: { $0.1 < $1.1 })!
        return MetricInsights(
            avg: avg,
            min: .init(name: lo.0.displayName, profileImageUrl: lo.0.profileImageUrl, value: lo.1, color: lo.0.color),
            max: .init(name: hi.0.displayName, profileImageUrl: hi.0.profileImageUrl, value: hi.1, color: hi.0.color)
        )
    }
}
