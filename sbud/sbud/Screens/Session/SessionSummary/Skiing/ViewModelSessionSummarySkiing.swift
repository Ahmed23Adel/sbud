//
//  ViewModelSessionSummarySkiing.swift
//  sbud
//
//  Created by ahmed on 24/05/2026.
//

import Foundation
import Observation
import SwiftUI
import FirebaseAnalytics
import FirebaseAuth

@Observable
class ViewModelSessionSummarySkiing: SessionSummaryViewModel {

    typealias Metric = MetricsCollectedSkiing

    // MARK: - SessionSummaryViewModel requirements

    var sessions: [SessionHistoryEntry] = []
    var selectedSessionIndex: Int = 0
    var allMetrics: [MetricsCollectedSkiing] = []
    var profiles: [String: UserProfile] = [:]
    var isLoading = false
    var errorMessage: String?

    let eventId: String
    let metricsRepo: ActivityMetricsRepository<MetricsCollectedSkiing>
    let userRepo = UserRepository()

    // MARK: - Init

    init(eventId: String, numSessions: Int,
         repo: ActivityMetricsRepository<MetricsCollectedSkiing> = ActivityMetricsRepository()) {
        self.eventId    = eventId
        self.metricsRepo = repo
        Analytics.logEvent(AnalyticsEventScreenView, parameters: [
            AnalyticsParameterScreenName: "SessionSummary_Skiing",
            "event_id": eventId
        ])
    }

    // MARK: - Participant summaries

    var participantSummaries: [ParticipantSummary] {
        sessionMetrics.enumerated().map { index, m in
            let elapsed   = m.endDateTime.timeIntervalSince(m.startDateTime)
            let speed     = elapsed > 0 ? (m.totalDistance / 1000) / (elapsed / 3600) : 0
            let bestSpeed = m.splits.map(\.speedKmH).max() ?? 0
            let profile   = m.userId.flatMap { profiles[$0] }
            let name      = profile.map { "\($0.name) \($0.surName)".trimmingCharacters(in: .whitespaces) }

            let displaySplits: [DisplaySplit] = m.splits.map { s in
                DisplaySplit(number: s.number, chartValue: s.speedKmH,
                             displayText: SummaryFormatters.speed(s.speedKmH), isSpeed: true)
            }

            return ParticipantSummary(
                id: m.userId ?? "unknown_\(index)",
                displayIndex: index + 1,
                elapsedSeconds: elapsed,
                metricsCreatorType: m.metricsCreatorType,
                endedBeforeCreator: m.endedBeforeCreator,
                userName: name,
                profileImageUrl: profile?.profileImageUrl,
                receivedFeedbacks: profile?.receivedFeedbacks,
                totalDistanceKm: m.totalDistance / 1000,
                track: m.track,
                avgSpeedKmH: speed,
                bestSplitSpeedKmH: bestSpeed,
                elevationGainM: m.elevationGain,
                verticalDropM: m.verticalDrop,
                numberOfRuns: m.numberOfRuns,
                splits: displaySplits
            )
        }
    }

    // MARK: - Aggregate metrics

    var avgSpeedKmH: Double {
        let v = participantSummaries.compactMap { $0.avgSpeedKmH > 0 ? $0.avgSpeedKmH : nil }
        guard !v.isEmpty else { return 0 }
        return v.reduce(0, +) / Double(v.count)
    }

    var avgVerticalDropM: Double {
        guard !participantSummaries.isEmpty else { return 0 }
        return participantSummaries.map(\.verticalDropM).reduce(0, +) / Double(participantSummaries.count)
    }

    // MARK: - Insights

    var speedInsights: MetricInsights? {
        makeInsights(values: participantSummaries.compactMap { s in
            s.avgSpeedKmH > 0 ? (s, s.avgSpeedKmH) : nil
        })
    }

    var verticalDropInsights: MetricInsights? {
        makeInsights(values: participantSummaries.compactMap { s in
            s.verticalDropM > 0 ? (s, s.verticalDropM) : nil
        })
    }

    var numberOfRunsInsights: MetricInsights? {
        makeInsights(values: participantSummaries.compactMap { s in
            s.numberOfRuns > 0 ? (s, Double(s.numberOfRuns)) : nil
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
