//
//  ViewModelSessionSummaryRunning.swift
//  sbud
//
//  Created by ahmed on 24/05/2026.
//

import Foundation
import Observation
import SwiftUI

@Observable
class ViewModelSessionSummaryRunning {

    // MARK: - Public state

    var sessions: [SessionHistoryEntry] = []
    var selectedSessionIndex: Int = 0
    var allMetrics: [MetricsCollectedRun] = []
    var isLoading = false
    var errorMessage: String?

    // MARK: - Derived state for selected session

    var sessionMetrics: [MetricsCollectedRun] {
        allMetrics.filter { $0.numSession == selectedSessionIndex }
    }

    var participantCount: Int { sessionMetrics.count }

    var avgPaceMinPerKm: Double {
        let valid = sessionMetrics.compactMap { m -> Double? in
            guard m.totalDistance > 0 else { return nil }
            let elapsed = m.endDateTime.timeIntervalSince(m.startDateTime)
            return (elapsed / 60) / (m.totalDistance / 1000)
        }
        guard !valid.isEmpty else { return 0 }
        return valid.reduce(0, +) / Double(valid.count)
    }

    var minPaceMinPerKm: Double {
        sessionMetrics.compactMap { m -> Double? in
            guard m.totalDistance > 0 else { return nil }
            let elapsed = m.endDateTime.timeIntervalSince(m.startDateTime)
            return (elapsed / 60) / (m.totalDistance / 1000)
        }.min() ?? 0
    }

    var maxPaceMinPerKm: Double {
        sessionMetrics.compactMap { m -> Double? in
            guard m.totalDistance > 0 else { return nil }
            let elapsed = m.endDateTime.timeIntervalSince(m.startDateTime)
            return (elapsed / 60) / (m.totalDistance / 1000)
        }.max() ?? 0
    }

    var avgDistanceKm: Double {
        guard !sessionMetrics.isEmpty else { return 0 }
        return sessionMetrics.map { $0.totalDistance / 1000 }.reduce(0, +) / Double(sessionMetrics.count)
    }

    var totalDistanceKm: Double {
        sessionMetrics.map { $0.totalDistance / 1000 }.reduce(0, +)
    }

    // Per-participant summary for charts
    var participantSummaries: [ParticipantSummary] {
        sessionMetrics.enumerated().map { index, m in
            let elapsed = m.endDateTime.timeIntervalSince(m.startDateTime)
            let pace = m.totalDistance > 0 ? (elapsed / 60) / (m.totalDistance / 1000) : 0
            let bestSplitPace = m.splits.map(\.paceInMinPerKm).min() ?? 0
            return ParticipantSummary(
                id: m.userId ?? "unknown_\(index)",
                displayIndex: index + 1,
                totalDistanceKm: m.totalDistance / 1000,
                avgPaceMinPerKm: pace,
                bestSplitPace: bestSplitPace,
                elapsedSeconds: elapsed,
                splits: m.splits,
                track: m.track,
                metricsCreatorType: m.metricsCreatorType,
                endedBeforeCreator: m.endedBeforeCreator
            )
        }
    }

    var selectedSession: SessionHistoryEntry? {
        sessions.first { $0.id == selectedSessionIndex }
    }

    // MARK: - Private

    private let repo: IMetricsRepository
    private let eventId: String

    // MARK: - Init

    init(eventId: String, numSessions: Int, repo: IMetricsRepository = MetricsRepository()) {
        self.eventId = eventId
        self.repo = repo
    }

    // MARK: - Load

    func load() async {
        isLoading = true
        errorMessage = nil
        do {
            async let sessions = repo.fetchSessionHistory(eventId: eventId)
            async let metrics  = repo.fetchMetrics(eventId: eventId)
            self.sessions   = try await sessions
            self.allMetrics = try await metrics
            if let first = self.sessions.first {
                selectedSessionIndex = first.id
            }
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }
}

// MARK: - ParticipantSummary

struct ParticipantSummary: Identifiable {
    let id: String
    let displayIndex: Int
    let totalDistanceKm: Double
    let avgPaceMinPerKm: Double
    let bestSplitPace: Double
    let elapsedSeconds: TimeInterval
    let splits: [Split]
    let track: [TrackPoint]
    let metricsCreatorType: MetricsCreatorType
    let endedBeforeCreator: Bool

    var formattedElapsed: String {
        let h = Int(elapsedSeconds) / 3600
        let m = (Int(elapsedSeconds) % 3600) / 60
        let s = Int(elapsedSeconds) % 60
        if h > 0 { return String(format: "%d:%02d:%02d", h, m, s) }
        return String(format: "%02d:%02d", m, s)
    }

    var color: Color {
        let colors: [Color] = [.neonCyan, .neonGreen, .neonPink,
                               Color(red: 1, green: 0.8, blue: 0),
                               Color(red: 0.75, green: 0.55, blue: 1)]
        return colors[(displayIndex - 1) % colors.count]
    }
}
