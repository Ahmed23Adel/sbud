//
//  ViewSessionSummaryConditional.swift
//  sbud
//
//  Created by ahmed on 24/05/2026.
//

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

    @EnvironmentObject private var mainCoordinator: MainCoordinator

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
        .task {
            try? await UserStatsRequester().recalculate()
        }

        .safeAreaInset(edge: .top, spacing: 0) {
            closeBar
        }
    }

    private var closeBar: some View {
        HStack {
            Spacer()
            Button {
                mainCoordinator.goToHome()
            } label: {
                Image(systemName: "xmark")
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(.white)
                    .frame(width: 32, height: 32)
                    .background(Color.white.opacity(0.15))
                    .clipShape(Circle())
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color.surfaceBg)
    }
}
