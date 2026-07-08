//
//  ParticipantSummary.swift
//  sbud
//
//  Created by ahmed on 24/05/2026.
//

import SwiftUI

/// Single struct used by every activity's session summary.
/// GPS-only fields default to 0 / empty for time-based activities.
struct ParticipantSummary: Identifiable {

    // MARK: - Common (all activities)
    let id: String
    let displayIndex: Int
    let elapsedSeconds: TimeInterval
    let metricsCreatorType: MetricsCreatorType
    let endedBeforeCreator: Bool
    let userName: String?
    let profileImageUrl: String?
    
    var receivedFeedbacks: [String: String]?

    // MARK: - GPS activities (0 / [] for time-based)
    let totalDistanceKm: Double
    let track: [TrackPoint]

    // MARK: - Pace activities (running, hiking)
    let avgPaceMinPerKm: Double
    let bestSplitPace: Double

    // MARK: - Speed activities (cycling, skiing)
    let avgSpeedKmH: Double
    let bestSplitSpeedKmH: Double

    // MARK: - Elevation (cycling, hiking, skiing)
    let elevationGainM: Double
    let elevationLossM: Double   // hiking only
    let maxAltitudeM: Double     // hiking only

    // MARK: - Skiing specific
    let verticalDropM: Double
    let numberOfRuns: Int

    // MARK: - Splits (converted to unified DisplaySplit by each VM)
    let splits: [DisplaySplit]

    // MARK: - Derived

    var displayName: String {
        if let name = userName, !name.isEmpty { return name }
        let myId = ProfileManager.shared.getLocalProfile()?.id ?? ""
        return id == myId ? "You" : "Runner \(displayIndex)"
    }

    var formattedElapsed: String {
        let h = Int(elapsedSeconds) / 3600
        let m = (Int(elapsedSeconds) % 3600) / 60
        let s = Int(elapsedSeconds) % 60
        if h > 0 { return String(format: "%d:%02d:%02d", h, m, s) }
        return String(format: "%02d:%02d", m, s)
    }

    var color: Color {
        let palette: [Color] = [
            .neonCyan, .neonGreen, .neonPink,
            Color(red: 1, green: 0.8, blue: 0),
            Color(red: 0.75, green: 0.55, blue: 1)
        ]
        return palette[(displayIndex - 1) % palette.count]
    }

    // MARK: - Init with defaults for optional fields

    init(
        id: String,
        displayIndex: Int,
        elapsedSeconds: TimeInterval,
        metricsCreatorType: MetricsCreatorType,
        endedBeforeCreator: Bool,
        userName: String?,
        profileImageUrl: String?,
        receivedFeedbacks: [String: String]? = nil,
        totalDistanceKm: Double = 0,
        track: [TrackPoint] = [],
        avgPaceMinPerKm: Double = 0,
        bestSplitPace: Double = 0,
        avgSpeedKmH: Double = 0,
        bestSplitSpeedKmH: Double = 0,
        elevationGainM: Double = 0,
        elevationLossM: Double = 0,
        maxAltitudeM: Double = 0,
        verticalDropM: Double = 0,
        numberOfRuns: Int = 0,
        splits: [DisplaySplit] = []
    ) {
        self.id = id
        self.displayIndex = displayIndex
        self.elapsedSeconds = elapsedSeconds
        self.metricsCreatorType = metricsCreatorType
        self.endedBeforeCreator = endedBeforeCreator
        self.userName = userName
        self.profileImageUrl = profileImageUrl
        self.receivedFeedbacks = receivedFeedbacks
        self.totalDistanceKm = totalDistanceKm
        self.track = track
        self.avgPaceMinPerKm = avgPaceMinPerKm
        self.bestSplitPace = bestSplitPace
        self.avgSpeedKmH = avgSpeedKmH
        self.bestSplitSpeedKmH = bestSplitSpeedKmH
        self.elevationGainM = elevationGainM
        self.elevationLossM = elevationLossM
        self.maxAltitudeM = maxAltitudeM
        self.verticalDropM = verticalDropM
        self.numberOfRuns = numberOfRuns
        self.splits = splits
    }
}
