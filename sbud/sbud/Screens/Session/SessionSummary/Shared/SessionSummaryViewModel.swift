//
//  SessionSummaryViewModel.swift
//  sbud
//
//  Created by ahmed on 24/05/2026.
//

import Foundation
import SwiftUI

// MARK: - Shared metric insight types

struct MetricHolder {
    let name: String
    let profileImageUrl: String?
    let value: Double
    let color: Color
}

struct MetricInsights {
    let avg: Double
    let min: MetricHolder  // lower value (fastest pace, shortest distance, etc.)
    let max: MetricHolder  // higher value
}

// MARK: - Shared protocol

protocol SessionSummaryViewModel: AnyObject {
    associatedtype Metric: SessionMetricsBase

    var sessions: [SessionHistoryEntry] { get set }
    var selectedSessionIndex: Int { get set }
    var allMetrics: [Metric] { get set }
    var profiles: [String: UserProfile] { get set }
    var isLoading: Bool { get set }
    var errorMessage: String? { get set }

    var eventId: String { get }
    var metricsRepo: ActivityMetricsRepository<Metric> { get }
    var userRepo: UserRepository { get }
}

// MARK: - Default implementations

extension SessionSummaryViewModel {

    var sessionMetrics: [Metric] {
        allMetrics.filter { $0.numSession == selectedSessionIndex }
    }

    var participantCount: Int { sessionMetrics.count }

    var selectedSession: SessionHistoryEntry? {
        sessions.first { $0.id == selectedSessionIndex }
    }

    func load() async {
        isLoading = true
        errorMessage = nil
        do {
            async let s = metricsRepo.fetchSessionHistory(eventId: eventId)
            async let m = metricsRepo.fetchMetrics(eventId: eventId)
            sessions   = try await s
            allMetrics = try await m
            if let first = sessions.first { selectedSessionIndex = first.id }
            await loadProfiles()
        } catch {
            errorMessage = error.localizedDescription
        }
        isLoading = false
    }

    func loadProfiles() async {
        let ids = Set(allMetrics.compactMap(\.userId))
        await withTaskGroup(of: (String, UserProfile?).self) { group in
            for id in ids {
                group.addTask {
                    let profile = try? await self.userRepo.fetchProfile(id)
                    return (id, profile)
                }
            }
            for await (id, profile) in group {
                if let profile { profiles[id] = profile }
            }
        }
    }

    // MARK: - Duration insights (shared by all activities)

    var durationInsights: MetricInsights? {
        let valid: [(name: String, url: String?, color: Color, secs: Double)] =
            sessionMetrics.enumerated().compactMap { idx, m in
                let secs = m.endDateTime.timeIntervalSince(m.startDateTime)
                guard secs > 0 else { return nil }
                let profile = m.userId.flatMap { profiles[$0] }
                let name = profile.map {
                    "\($0.name) \($0.surName)".trimmingCharacters(in: .whitespaces)
                } ?? "P\(idx + 1)"
                let palette: [Color] = [
                    .neonCyan, .neonGreen, .neonPink,
                    Color(red: 1, green: 0.8, blue: 0),
                    Color(red: 0.75, green: 0.55, blue: 1)
                ]
                return (name, profile?.profileImageUrl, palette[idx % palette.count], secs)
            }
        guard !valid.isEmpty else { return nil }
        let avg = valid.map(\.secs).reduce(0, +) / Double(valid.count)
        let longest  = valid.max(by: { $0.secs < $1.secs })!
        let shortest = valid.min(by: { $0.secs < $1.secs })!
        return MetricInsights(
            avg: avg,
            min: .init(name: shortest.name, profileImageUrl: shortest.url, value: shortest.secs, color: shortest.color),
            max: .init(name: longest.name,  profileImageUrl: longest.url,  value: longest.secs,  color: longest.color)
        )
    }

    // MARK: - Profile name helper

    func profileName(for index: Int, userId: String?) -> String? {
        guard let uid = userId, let profile = profiles[uid] else { return nil }
        let name = "\(profile.name) \(profile.surName)".trimmingCharacters(in: .whitespaces)
        return name.isEmpty ? nil : name
    }
}
