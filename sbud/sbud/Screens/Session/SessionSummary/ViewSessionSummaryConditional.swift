//
//  ViewSessionSummaryConditional.swift
//  sbud
//
//  Created by ahmed on 24/05/2026.
//

import SwiftUI

struct ViewSessionSummaryConditional: View {
    let event: EventFullDetails
    var onParticipantTapped: (String) -> Void = { _ in }

    var body: some View {
        switch event.activityType {
        case .running:
            ViewSessionSummaryRunning(event: event, onParticipantTapped: onParticipantTapped)
        case .cycling:
            ViewSessionSummaryCycling(event: event, onParticipantTapped: onParticipantTapped)
        case .hiking:
            ViewSessionSummaryHiking(event: event, onParticipantTapped: onParticipantTapped)
        case .skiing:
            ViewSessionSummarySkiing(event: event, onParticipantTapped: onParticipantTapped)
        case .gym:
            ViewSessionSummaryTimeBased<MetricsCollectedGym>(
                event: event, activityLabel: "Participants",
                activityIcon: "dumbbell.fill",
                onParticipantTapped: onParticipantTapped)
        case .swimming:
            ViewSessionSummaryTimeBased<MetricsCollectedSwimming>(
                event: event, activityLabel: "Swimmers",
                activityIcon: "figure.pool.swim",
                onParticipantTapped: onParticipantTapped)
        case .tennis:
            ViewSessionSummaryTimeBased<MetricsCollectedTennis>(
                event: event, activityLabel: "Players",
                activityIcon: "tennisball.fill",
                onParticipantTapped: onParticipantTapped)
        case .yoga:
            ViewSessionSummaryTimeBased<MetricsCollectedYoga>(
                event: event, activityLabel: "Participants",
                activityIcon: "figure.mind.and.body",
                onParticipantTapped: onParticipantTapped)
        }
    }
}
