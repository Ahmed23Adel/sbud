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
    // Provided only when there's no system back button (e.g. the post-session
    // route swap in MainAppCoordinator, which isn't inside a NavigationStack push).
    var onBack: (() -> Void)? = nil

    var body: some View {
        Group {
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
        .toolbar {
            if let onBack {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: onBack) {
                        Image(systemName: "chevron.left")
                            .fontWeight(.semibold)
                            .foregroundStyle(Color.neonCyan)
                    }
                }
            }
        }
        .task {
            try? await UserStatsRequester().recalculate()
        }
    }
}
