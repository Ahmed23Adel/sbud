//
//  ViewSessionSummaryTimeBased.swift
//  sbud
//
//  Created by ahmed on 24/05/2026.
//

import SwiftUI

/// Shared summary view for time-only activities: Gym, Swimming, Tennis, Yoga.
struct ViewSessionSummaryTimeBased<M: SessionMetricsBase>: View {
    let event: EventFullDetails
    var activityLabel: String
    var activityIcon: String
    var onParticipantTapped: (String) -> Void = { _ in }

    @State private var vm: ViewModelSessionSummaryTimeBased<M>
    @State private var isRendering = false

    init(event: EventFullDetails,
         activityLabel: String,
         activityIcon: String,
         onParticipantTapped: @escaping (String) -> Void = { _ in }) {
        self.event = event
        self.activityLabel = activityLabel
        self.activityIcon = activityIcon
        self.onParticipantTapped = onParticipantTapped
        _vm = State(initialValue: ViewModelSessionSummaryTimeBased<M>(
            eventId: event.id, numSessions: event.numSessions
        ))
    }

    #if DEBUG
    init(event: EventFullDetails,
         activityLabel: String,
         activityIcon: String,
         previewVM: ViewModelSessionSummaryTimeBased<M>,
         onParticipantTapped: @escaping (String) -> Void = { _ in }) {
        self.event = event
        self.activityLabel = activityLabel
        self.activityIcon = activityIcon
        self.onParticipantTapped = onParticipantTapped
        _vm = State(initialValue: previewVM)
    }
    #endif

    var body: some View {
        ZStack {
            Color.surfaceBg.ignoresSafeArea()
            if vm.isLoading { loadingView }
            else if let error = vm.errorMessage { errorView(error) }
            else if vm.sessions.isEmpty { emptyView }
            else { mainContent }
        }
        .navigationTitle(event.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if !vm.sessionMetrics.isEmpty {
                ToolbarItem(placement: .navigationBarTrailing) { shareButton }
            }
        }
        .task { await vm.load() }
    }

    private var mainContent: some View {
        VStack(spacing: 0) {
            SessionSelectorView(sessions: vm.sessions, selectedIndex: $vm.selectedSessionIndex)
            AccentDivider()
            ScrollView {
                LazyVStack(spacing: 16) {
                    if vm.sessionMetrics.isEmpty { noDataForSession }
                    else {
                        sessionDateHeader
                        durationStatsSection
                        participantsSection
                        durationComparisonSection
                    }
                }
                .padding(.horizontal, 16).padding(.vertical, 16)
            }
        }
    }

    // MARK: - Share button

    private var shareButton: some View {
        Button { renderAndShare() } label: {
            Group {
                if isRendering { ProgressView().scaleEffect(0.7).tint(.neonCyan) }
                else { Image(systemName: "square.and.arrow.up").font(.system(size: 14, weight: .bold)) }
            }
            .foregroundColor(.neonCyan)
        }
        .disabled(isRendering)
    }

    @MainActor
    private func renderAndShare() {
        guard let session = vm.selectedSession else { return }
        isRendering = true
        let card = SessionShareCardView(eventTitle: event.title, session: session,
            summaries: vm.participantSummaries, paceInsights: nil, distanceInsights: nil)
        let renderer = ImageRenderer(content: card)
        renderer.scale = 3.0
        defer { isRendering = false }
        guard let uiImage = renderer.uiImage else { return }
        let av = UIActivityViewController(activityItems: [uiImage], applicationActivities: nil)
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let root = scene.windows.first?.rootViewController {
            var presented = root
            while let p = presented.presentedViewController { presented = p }
            presented.present(av, animated: true)
        }
    }

    // MARK: - Session header

    private var sessionDateHeader: some View {
        Group {
            if let session = vm.selectedSession {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(session.startDateTime.formatted(date: .complete, time: .omitted))
                            .font(.system(size: 10, weight: .bold, design: .monospaced)).foregroundColor(.labelGray)
                        Text(SummaryFormatters.duration(session.duration))
                            .font(.system(size: 18, weight: .black, design: .monospaced)).foregroundColor(.white)
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("\(vm.participantCount)")
                            .font(.system(size: 26, weight: .black, design: .monospaced)).foregroundColor(.neonCyan)
                            .shadow(color: .neonCyan.opacity(0.5), radius: 6)
                        Text(activityLabel.uppercased())
                            .font(.system(size: 8, weight: .bold, design: .monospaced)).tracking(1.5).foregroundColor(.labelGray)
                    }
                }
                .padding(14)
                .background(Color.cardBg)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .overlay(RoundedRectangle(cornerRadius: 12, style: .continuous)
                    .strokeBorder(Color.neonCyan.opacity(0.15), lineWidth: 1))
            }
        }
    }

    // MARK: - Duration stats

    private var durationStatsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionHeaderView(title: "Session Stats", icon: activityIcon)
            if let d = vm.durationInsights { MetricInsightsCard(kind: .duration, insights: d) }
        }
    }

    // MARK: - Participants

    private var participantsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionHeaderView(title: "Participants", icon: "person.2.fill")
            ForEach(vm.participantSummaries) { summary in
                ParticipantRowView(summary: summary) { onParticipantTapped(summary.id) }
            }
        }
    }

    // MARK: - Duration comparison

    private var durationComparisonSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionHeaderView(title: "Duration Comparison", icon: "clock.fill", accentColor: .neonPink)
            ParticipantComparisonBarView(
                title: "Session Duration", unit: "",
                entries: vm.participantSummaries.map { s in
                    .init(label: shortName(s), value: s.elapsedSeconds,
                          displayText: SummaryFormatters.durationShort(s.elapsedSeconds), color: s.color)
                }, lowerIsBetter: false)
        }
    }

    // MARK: - Loading / error / empty

    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView().tint(.neonCyan)
            Text("LOADING SESSION DATA").font(.system(size: 10, weight: .bold, design: .monospaced)).tracking(2).foregroundColor(.labelGray)
        }
    }

    private func errorView(_ message: String) -> some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill").font(.system(size: 32)).foregroundColor(.neonPink)
            Text(message).font(.system(size: 12, design: .monospaced)).foregroundColor(.labelGray).multilineTextAlignment(.center)
        }.padding(40)
    }

    private var emptyView: some View {
        VStack(spacing: 12) {
            Image(systemName: activityIcon).font(.system(size: 48)).foregroundColor(.labelGray)
            Text("NO SESSIONS YET").font(.system(size: 12, weight: .bold, design: .monospaced)).tracking(2).foregroundColor(.labelGray)
        }
    }

    private var noDataForSession: some View {
        VStack(spacing: 12) {
            Image(systemName: "tray").font(.system(size: 32)).foregroundColor(.labelGray)
            Text("NO DATA FOR THIS SESSION").font(.system(size: 11, weight: .bold, design: .monospaced)).tracking(1.5).foregroundColor(.labelGray)
        }.frame(maxWidth: .infinity).padding(40)
    }

    private func shortName(_ s: ParticipantSummary) -> String {
        if let name = s.userName, !name.isEmpty {
            return name.split(separator: " ").first.map(String.init) ?? "P\(s.displayIndex)"
        }
        let myId = ProfileManager.shared.getLocalProfile()?.id ?? ""
        return s.id == myId ? "You" : "P\(s.displayIndex)"
    }
}

// MARK: - Previews

#if DEBUG
private func makeTimeVM<M: SessionMetricsBase>(sessions: [SessionHistoryEntry]) -> ViewModelSessionSummaryTimeBased<M> {
    let vm = ViewModelSessionSummaryTimeBased<M>(eventId: "preview", numSessions: 1)
    vm.sessions = sessions
    vm.selectedSessionIndex = 0
    vm.isLoading = false
    vm.profiles = [
        "preview-user1": PreviewData.profile(id: "preview-user1", first: "Ahmed", last: "H."),
        "preview-user2": PreviewData.profile(id: "preview-user2", first: "Sara",  last: "M."),
        "preview-user3": PreviewData.profile(id: "preview-user3", first: "Luca",  last: "R."),
    ]
    return vm
}

#Preview("Gym — With Data") {
    let vm = makeTimeVM<MetricsCollectedGym>(sessions: [PreviewData.session])
    vm.allMetrics = [
        MetricsCollectedGym(userId: "preview-user1",
            startDateTime: PreviewData.session.startDateTime,
            endDateTime: PreviewData.session.endDateTime,
            metricsCreatorType: .creator, numSession: 0),
        MetricsCollectedGym(userId: "preview-user2",
            startDateTime: PreviewData.session.startDateTime,
            endDateTime: PreviewData.session.endDateTime.addingTimeInterval(-400),
            metricsCreatorType: .normalParticipant, numSession: 0),
        MetricsCollectedGym(userId: "preview-user3",
            startDateTime: PreviewData.session.startDateTime,
            endDateTime: PreviewData.session.endDateTime.addingTimeInterval(650),
            metricsCreatorType: .normalParticipant, numSession: 0),
    ]
    return NavigationStack {
        ViewSessionSummaryTimeBased<MetricsCollectedGym>(
            event: PreviewData.event(activity: .gym, title: "Saturday Gym Session"),
            activityLabel: "Participants",
            activityIcon: "dumbbell.fill",
            previewVM: vm
        )
    }
    .preferredColorScheme(.dark)
}

#Preview("Tennis — With Data") {
    let vm = makeTimeVM<MetricsCollectedTennis>(sessions: [PreviewData.session])
    vm.allMetrics = [
        MetricsCollectedTennis(userId: "preview-user1",
            startDateTime: PreviewData.session.startDateTime,
            endDateTime: PreviewData.session.endDateTime,
            metricsCreatorType: .creator, numSession: 0),
        MetricsCollectedTennis(userId: "preview-user2",
            startDateTime: PreviewData.session.startDateTime,
            endDateTime: PreviewData.session.endDateTime.addingTimeInterval(-300),
            metricsCreatorType: .normalParticipant, numSession: 0),
    ]
    return NavigationStack {
        ViewSessionSummaryTimeBased<MetricsCollectedTennis>(
            event: PreviewData.event(activity: .tennis, title: "Sunday Tennis"),
            activityLabel: "Players",
            activityIcon: "tennisball.fill",
            previewVM: vm
        )
    }
    .preferredColorScheme(.dark)
}

#Preview("Yoga — Empty") {
    let vm = ViewModelSessionSummaryTimeBased<MetricsCollectedYoga>(eventId: "preview", numSessions: 0)
    vm.sessions = []
    vm.isLoading = false
    return NavigationStack {
        ViewSessionSummaryTimeBased<MetricsCollectedYoga>(
            event: PreviewData.event(activity: .yoga, title: "Morning Yoga"),
            activityLabel: "Participants",
            activityIcon: "figure.mind.and.body",
            previewVM: vm
        )
    }
    .preferredColorScheme(.dark)
}
#endif
