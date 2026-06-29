//
//  PreviewData.swift
//  sbud
//
//  Created by ahmed on 24/05/2026.
//

#if DEBUG
import SwiftUI

// MARK: - Mock participants

enum PreviewData {

    // MARK: Pace activities (running / hiking)

    static let paceSplits1: [DisplaySplit] = [
        DisplaySplit(number: 1, chartValue: 5.1, displayText: "5'06\"", isSpeed: false),
        DisplaySplit(number: 2, chartValue: 5.4, displayText: "5'24\"", isSpeed: false),
        DisplaySplit(number: 3, chartValue: 4.9, displayText: "4'54\"", isSpeed: false),
        DisplaySplit(number: 4, chartValue: 5.3, displayText: "5'18\"", isSpeed: false),
    ]

    static let paceSplits2: [DisplaySplit] = [
        DisplaySplit(number: 1, chartValue: 5.7, displayText: "5'42\"", isSpeed: false),
        DisplaySplit(number: 2, chartValue: 6.1, displayText: "6'06\"", isSpeed: false),
        DisplaySplit(number: 3, chartValue: 5.9, displayText: "5'54\"", isSpeed: false),
        DisplaySplit(number: 4, chartValue: 5.6, displayText: "5'36\"", isSpeed: false),
    ]

    static let paceParticipants: [ParticipantSummary] = [
        ParticipantSummary(
            id: "preview-user1", displayIndex: 1,
            elapsedSeconds: 3_245, metricsCreatorType: .creator, endedBeforeCreator: false,
            userName: "Ahmed H", profileImageUrl: nil,
            totalDistanceKm: 10.2, avgPaceMinPerKm: 5.3, bestSplitPace: 4.9,
            elevationGainM: 95, elevationLossM: 88, maxAltitudeM: 340,
            splits: paceSplits1
        ),
        ParticipantSummary(
            id: "preview-user2", displayIndex: 2,
            elapsedSeconds: 3_512, metricsCreatorType: .normalParticipant, endedBeforeCreator: false,
            userName: "Sara M", profileImageUrl: nil,
            totalDistanceKm: 9.8, avgPaceMinPerKm: 5.9, bestSplitPace: 5.6,
            elevationGainM: 82, elevationLossM: 75, maxAltitudeM: 310,
            splits: paceSplits2
        ),
        ParticipantSummary(
            id: "preview-user3", displayIndex: 3,
            elapsedSeconds: 3_721, metricsCreatorType: .normalParticipant, endedBeforeCreator: true,
            userName: nil, profileImageUrl: nil,
            totalDistanceKm: 8.5, avgPaceMinPerKm: 6.3, bestSplitPace: 6.0,
            splits: []
        ),
    ]

    // MARK: Speed activities (cycling / skiing)

    static let speedSplits1: [DisplaySplit] = [
        DisplaySplit(number: 1, chartValue: 28.5, displayText: "28.5", isSpeed: true),
        DisplaySplit(number: 2, chartValue: 32.1, displayText: "32.1", isSpeed: true),
        DisplaySplit(number: 3, chartValue: 30.8, displayText: "30.8", isSpeed: true),
        DisplaySplit(number: 4, chartValue: 34.2, displayText: "34.2", isSpeed: true),
    ]

    static let speedSplits2: [DisplaySplit] = [
        DisplaySplit(number: 1, chartValue: 25.3, displayText: "25.3", isSpeed: true),
        DisplaySplit(number: 2, chartValue: 27.1, displayText: "27.1", isSpeed: true),
        DisplaySplit(number: 3, chartValue: 26.4, displayText: "26.4", isSpeed: true),
        DisplaySplit(number: 4, chartValue: 28.0, displayText: "28.0", isSpeed: true),
    ]

    static let speedParticipants: [ParticipantSummary] = [
        ParticipantSummary(
            id: "preview-user1", displayIndex: 1,
            elapsedSeconds: 5_400, metricsCreatorType: .creator, endedBeforeCreator: false,
            userName: "Ahmed H", profileImageUrl: nil,
            totalDistanceKm: 32.5, avgSpeedKmH: 30.1, bestSplitSpeedKmH: 34.2,
            elevationGainM: 412, verticalDropM: 900, numberOfRuns: 5,
            splits: speedSplits1
        ),
        ParticipantSummary(
            id: "preview-user2", displayIndex: 2,
            elapsedSeconds: 5_900, metricsCreatorType: .normalParticipant, endedBeforeCreator: false,
            userName: "Sara M", profileImageUrl: nil,
            totalDistanceKm: 28.3, avgSpeedKmH: 26.2, bestSplitSpeedKmH: 28.0,
            elevationGainM: 310, verticalDropM: 750, numberOfRuns: 4,
            splits: speedSplits2
        ),
    ]

    // MARK: Time-based activities (gym / tennis / swimming / yoga)

    static let timeParticipants: [ParticipantSummary] = [
        ParticipantSummary(
            id: "preview-user1", displayIndex: 1,
            elapsedSeconds: 3_600, metricsCreatorType: .creator, endedBeforeCreator: false,
            userName: "Ahmed H", profileImageUrl: nil
        ),
        ParticipantSummary(
            id: "preview-user2", displayIndex: 2,
            elapsedSeconds: 3_200, metricsCreatorType: .normalParticipant, endedBeforeCreator: false,
            userName: "Sara M", profileImageUrl: nil
        ),
        ParticipantSummary(
            id: "preview-user3", displayIndex: 3,
            elapsedSeconds: 4_050, metricsCreatorType: .normalParticipant, endedBeforeCreator: false,
            userName: nil, profileImageUrl: nil
        ),
    ]

    // MARK: MetricInsights helpers

    static func paceInsights(participants: [ParticipantSummary] = paceParticipants) -> MetricInsights {
        MetricInsights(
            avg: 5.83,
            min: MetricHolder(name: "Ahmed H", profileImageUrl: nil, value: 5.3, color: .neonCyan),
            max: MetricHolder(name: "Sara M",  profileImageUrl: nil, value: 6.3, color: .neonGreen)
        )
    }

    static func speedInsights(participants: [ParticipantSummary] = speedParticipants) -> MetricInsights {
        MetricInsights(
            avg: 28.15,
            min: MetricHolder(name: "Sara M",  profileImageUrl: nil, value: 26.2, color: .neonGreen),
            max: MetricHolder(name: "Ahmed H", profileImageUrl: nil, value: 30.1, color: .neonCyan)
        )
    }

    static func distanceInsights() -> MetricInsights {
        MetricInsights(
            avg: 10.0,
            min: MetricHolder(name: "Sara M",  profileImageUrl: nil, value: 9.8, color: .neonGreen),
            max: MetricHolder(name: "Ahmed H", profileImageUrl: nil, value: 10.2, color: .neonCyan)
        )
    }

    static func elevationInsights() -> MetricInsights {
        MetricInsights(
            avg: 362.0,
            min: MetricHolder(name: "Sara M",  profileImageUrl: nil, value: 310, color: .neonGreen),
            max: MetricHolder(name: "Ahmed H", profileImageUrl: nil, value: 412, color: .neonCyan)
        )
    }

    static func durationInsights() -> MetricInsights {
        MetricInsights(
            avg: 3_617,
            min: MetricHolder(name: "Sara M",  profileImageUrl: nil, value: 3_200, color: .neonGreen),
            max: MetricHolder(name: "Runner 3", profileImageUrl: nil, value: 4_050, color: .neonPink)
        )
    }

    // MARK: Mock session

    static let session = SessionHistoryEntry(
        id: 0,
        startDateTime: Calendar.current.date(byAdding: .hour, value: -2, to: Date())!,
        endDateTime: Date()
    )

    // MARK: Mock events

    static func event(activity: ActivityType, title: String) -> EventFullDetails {
        let details = ExtraArgsHolder()
        details.selectedActivity = activity
        return EventFullDetails(
            id: "preview-\(activity.rawValue.lowercased())",
            title: title,
            creator: .sample,
            activityDetails: details,
            isDateConfirmed: true,
            isLocationConfirmed: true,
            isPublic: true,
            joinCondition: .autoJoin,
            createdAt: Date(),
            dateLocations: [.sample],
            numSessions: 2
        )
    }

    // MARK: Mock UserProfile helpers

    static func profile(id: String, first: String, last: String) -> UserProfile {
        var p = UserProfile(id: id)
        p.name = first
        p.surName = last
        return p
    }
}
#endif
