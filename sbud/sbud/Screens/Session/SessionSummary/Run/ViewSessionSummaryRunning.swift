//
//  ViewSessionSummaryRunning.swift
//  sbud
//
//  Created by ahmed on 24/05/2026.
//

import SwiftUI
import MapKit

struct ViewSessionSummaryRunning: View {
    let event: EventFullDetails
    var onParticipantTapped: (String) -> Void = { _ in }

    @State private var vm: ViewModelSessionSummaryRunning
    @State private var isRendering = false

    init(event: EventFullDetails, onParticipantTapped: @escaping (String) -> Void = { _ in }) {
        self.event = event
        self.onParticipantTapped = onParticipantTapped
        _vm = State(initialValue: ViewModelSessionSummaryRunning(
            eventId: event.id,
            numSessions: event.numSessions
        ))
    }

    // MARK: - Body

    var body: some View {
        ZStack {
            Color.surfaceBg.ignoresSafeArea()

            if vm.isLoading {
                loadingView
            } else if let error = vm.errorMessage {
                errorView(error)
            } else if vm.sessions.isEmpty {
                emptyView
            } else {
                mainContent
            }
        }
        .navigationTitle(event.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if !vm.sessionMetrics.isEmpty {
                ToolbarItem(placement: .navigationBarTrailing) {
                    shareButton
                }
            }
        }
        .task { await vm.load() }
    }

    // MARK: - Main content

    private var mainContent: some View {
        VStack(spacing: 0) {
            SessionSelectorView(sessions: vm.sessions, selectedIndex: $vm.selectedSessionIndex)
            AccentDivider()

            ScrollView {
                LazyVStack(spacing: 16) {
                    if vm.sessionMetrics.isEmpty {
                        noDataForSession
                    } else {
                        sessionDateHeader
                        overallStatsSection
                        participantsSection
                        paceComparisonSection
                        distanceComparisonSection
                        paceTrendSection
                        splitsSection
                        routeMapSection
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 16)
            }
        }
    }

    // MARK: - Share button

    private var shareButton: some View {
        Button {
            renderAndShare()
        } label: {
            HStack(spacing: 4) {
                if isRendering {
                    ProgressView()
                        .scaleEffect(0.7)
                        .tint(.neonCyan)
                } else {
                    Image(systemName: "square.and.arrow.up")
                        .font(.system(size: 14, weight: .bold))
                }
            }
            .foregroundColor(.neonCyan)
        }
        .disabled(isRendering)
    }

    @MainActor
    private func renderAndShare() {
        guard let session = vm.selectedSession else { return }
        isRendering = true

        Task { @MainActor in
            defer { isRendering = false }

            // Snapshot the routes before feeding them into ImageRenderer —
            // MKMapSnapshotter is async, UIViewRepresentable can't be rendered by ImageRenderer
            let routeImage = await MapSnapshotBuilder.snapshot(summaries: vm.participantSummaries)

            let card = SessionShareCardView(
                eventTitle: event.title,
                session: session,
                summaries: vm.participantSummaries,
                routeImage: routeImage,
                paceInsights: vm.paceInsights,
                distanceInsights: vm.distanceInsights
            )

            let renderer = ImageRenderer(content: card)
            renderer.scale = 3.0

            guard let uiImage = renderer.uiImage else { return }

            let av = UIActivityViewController(
                activityItems: [uiImage],
                applicationActivities: nil
            )
            if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
               let root = scene.windows.first?.rootViewController {
                var presented = root
                while let p = presented.presentedViewController { presented = p }
                presented.present(av, animated: true)
            }
        } // end Task
    }

    // MARK: - Session date header

    private var sessionDateHeader: some View {
        Group {
            if let session = vm.selectedSession {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(session.startDateTime.formatted(date: .complete, time: .omitted))
                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                            .foregroundColor(.labelGray)
                        Text(formatDuration(session.duration))
                            .font(.system(size: 18, weight: .black, design: .monospaced))
                            .foregroundColor(.white)
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("\(vm.participantCount)")
                            .font(.system(size: 26, weight: .black, design: .monospaced))
                            .foregroundColor(.neonCyan)
                            .shadow(color: .neonCyan.opacity(0.5), radius: 6)
                        Text("RUNNERS")
                            .font(.system(size: 8, weight: .bold, design: .monospaced))
                            .tracking(1.5)
                            .foregroundColor(.labelGray)
                    }
                }
                .padding(14)
                .background(Color.cardBg)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .strokeBorder(Color.neonCyan.opacity(0.15), lineWidth: 1)
                )
            }
        }
    }

    // MARK: - Overall stats (avg + min/max insights)

    private var overallStatsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionHeaderView(title: "Session Stats", icon: "chart.bar.fill")

            SummaryStatBanner(stats: [
                .init(label: "AVG PACE",  value: formatPace(vm.avgPaceMinPerKm), unit: "/km", color: .neonCyan),
                .init(label: "BEST PACE", value: formatPace(vm.minPaceMinPerKm), unit: "/km", color: .neonGreen),
                .init(label: "AVG DIST",  value: String(format: "%.2f", vm.avgDistanceKm), unit: "km", color: .neonPink)
            ])

            if let p = vm.paceInsights {
                MetricInsightsCard(kind: .pace, insights: p)
            }

            if let d = vm.distanceInsights {
                MetricInsightsCard(kind: .distance, insights: d)
            }
        }
    }

    // MARK: - Participants

    private var participantsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionHeaderView(title: "Participants", icon: "person.2.fill")
            ForEach(vm.participantSummaries) { summary in
                ParticipantRowView(
                    summary: summary,
                    onTap: {
                        onParticipantTapped(summary.id)
                    },
                    onVote: { tag in
                        Task {
                            await vm.voteForFeedback(targetUserId: summary.id, tag: tag)
                        }
                    }
                )
            }
        }
    }

    // MARK: - Pace comparison

    private var paceComparisonSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionHeaderView(title: "Pace Comparison", icon: "bolt.fill", accentColor: .neonGreen)

            ParticipantComparisonBarView(
                title: "Average Pace",
                unit: "/km",
                entries: vm.participantSummaries.map { s in
                    .init(label: shortName(s), value: s.avgPaceMinPerKm,
                          displayText: formatPace(s.avgPaceMinPerKm), color: s.color)
                },
                lowerIsBetter: true
            )

            ParticipantComparisonBarView(
                title: "Best Split Pace",
                unit: "/km",
                entries: vm.participantSummaries.map { s in
                    .init(label: shortName(s), value: s.bestSplitPace,
                          displayText: formatPace(s.bestSplitPace), color: s.color)
                },
                lowerIsBetter: true
            )
        }
    }

    // MARK: - Distance comparison

    private var distanceComparisonSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionHeaderView(title: "Distance", icon: "flag.checkered", accentColor: .neonPink)

            ParticipantComparisonBarView(
                title: "Total Distance",
                unit: "km",
                entries: vm.participantSummaries.map { s in
                    .init(label: shortName(s), value: s.totalDistanceKm,
                          displayText: String(format: "%.2f km", s.totalDistanceKm), color: s.color)
                },
                lowerIsBetter: false
            )
        }
    }

    // MARK: - Pace trend

    private var paceTrendSection: some View {
        let summaries = vm.participantSummaries.filter { !$0.splits.isEmpty }
        guard !summaries.isEmpty else { return AnyView(EmptyView()) }
        return AnyView(PaceTrendChartView(summaries: summaries, shortName: shortName))
    }

    // MARK: - Splits section

    @State private var selectedParticipantForSplits: Int = 0

    private var splitsSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionHeaderView(title: "Splits", icon: "stopwatch.fill", accentColor: .neonGreen)

            if vm.participantSummaries.count > 1 {
                participantPicker(selected: $selectedParticipantForSplits)
            }

            if selectedParticipantForSplits < vm.participantSummaries.count {
                let summary = vm.participantSummaries[selectedParticipantForSplits]
                if summary.splits.isEmpty {
                    emptyChartPlaceholder("No splits recorded")
                } else {
                    SplitsBarChartView(
                        bars: summary.splits.map { split in
                            .init(label: "KM\(split.number)", value: split.chartValue,
                                  displayText: split.displayText, color: summary.color)
                        },
                        unit: "/km",
                        title: "Split Pace — \(summary.displayName)",
                        isSpeed: false
                    )
                }
            }
        }
    }

    // MARK: - Route map section

    @State private var selectedRouteIndex: Int? = nil

    private var routeMapSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            SectionHeaderView(title: "Routes", icon: "map.fill", accentColor: .neonCyan)

            // Picker with avatars
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .bottom, spacing: 8) {
                    // "All" chip
                    Button {
                        withAnimation(.spring(response: 0.3)) { selectedRouteIndex = nil }
                    } label: {
                        Text("ALL")
                            .font(.system(size: 9, weight: .black, design: .monospaced))
                            .tracking(1.2)
                            .foregroundColor(selectedRouteIndex == nil ? .black : .labelGray)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 6)
                            .background(
                                RoundedRectangle(cornerRadius: 8)
                                    .fill(selectedRouteIndex == nil ? Color.neonCyan : Color.cardBg)
                            )
                    }

                    ForEach(Array(vm.participantSummaries.enumerated()), id: \.offset) { index, s in
                        let isSelected = selectedRouteIndex == index
                        Button {
                            withAnimation(.spring(response: 0.3)) {
                                selectedRouteIndex = isSelected ? nil : index
                            }
                        } label: {
                            routeChip(summary: s, isSelected: isSelected)
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.vertical, 4)
            }

            // Map
            let tracks = vm.participantSummaries.map { s in (
                color: UIColor(s.color),
                coordinates: s.track.map {
                    CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude)
                }
            )}

            MultiRouteMapView(tracks: tracks, selectedTrackIndex: selectedRouteIndex)
                .frame(height: 260)
                .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 12, style: .continuous)
                        .strokeBorder(Color.neonCyan.opacity(0.2), lineWidth: 1)
                )
        }
    }

    // Route chip with avatar
    private func routeChip(summary: ParticipantSummary, isSelected: Bool) -> some View {
        Group {
            if isSelected {
                // Expanded: big avatar + name
                VStack(spacing: 5) {
                    routeAvatar(summary: summary, size: 44, ringColor: .white.opacity(0.9))
                    Text(shortName(summary))
                        .font(.system(size: 8, weight: .black, design: .monospaced))
                        .foregroundColor(.white)
                        .lineLimit(1)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .fill(summary.color)
                        .shadow(color: summary.color.opacity(0.45), radius: 6, y: 2)
                )
            } else {
                // Compact: small avatar + name inline
                HStack(spacing: 5) {
                    routeAvatar(summary: summary, size: 20, ringColor: summary.color)
                    Text(shortName(summary))
                        .font(.system(size: 9, weight: .bold, design: .monospaced))
                        .foregroundColor(summary.color)
                }
                .padding(.horizontal, 8)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: 10, style: .continuous)
                        .fill(summary.color.opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .strokeBorder(summary.color.opacity(0.25), lineWidth: 1)
                        )
                )
            }
        }
    }

    @ViewBuilder
    private func routeAvatar(summary: ParticipantSummary, size: CGFloat, ringColor: Color) -> some View {
        AvatarKFImage(url: summary.profileImageUrl.flatMap(URL.init), size: size) {
            avatarFallback(summary: summary, size: size)
        }
        .overlay(Circle().strokeBorder(ringColor, lineWidth: size > 24 ? 2 : 1.5))
    }

    private func avatarFallback(summary: ParticipantSummary, size: CGFloat) -> some View {
        Circle()
            .fill(summary.color.opacity(0.25))
            .frame(width: size, height: size)
            .overlay(
                Text(String(summary.displayName.prefix(1)).uppercased())
                    .font(.system(size: size * 0.45, weight: .black, design: .monospaced))
                    .foregroundColor(summary.color)
            )
    }

    // MARK: - Reusable sub-views

    private func participantPicker(selected: Binding<Int>) -> some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 6) {
                ForEach(Array(vm.participantSummaries.enumerated()), id: \.offset) { index, s in
                    let isSel = selected.wrappedValue == index
                    Button {
                        withAnimation(.spring(response: 0.25)) { selected.wrappedValue = index }
                    } label: {
                        Text(s.displayName.uppercased())
                            .font(.system(size: 8, weight: .black, design: .monospaced))
                            .tracking(1)
                            .foregroundColor(isSel ? .black : s.color)
                            .padding(.horizontal, 10)
                            .padding(.vertical, 5)
                            .background(
                                RoundedRectangle(cornerRadius: 7)
                                    .fill(isSel ? s.color : s.color.opacity(0.1))
                            )
                    }
                }
            }
        }
    }

    private func emptyChartPlaceholder(_ text: String) -> some View {
        Text(text)
            .font(.system(size: 11, design: .monospaced))
            .foregroundColor(.labelGray)
            .frame(maxWidth: .infinity)
            .padding(20)
            .background(Color.cardBg)
            .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Loading / error / empty

    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView().tint(.neonCyan)
            Text("LOADING SESSION DATA")
                .font(.system(size: 10, weight: .bold, design: .monospaced))
                .tracking(2)
                .foregroundColor(.labelGray)
        }
    }

    private func errorView(_ message: String) -> some View {
        VStack(spacing: 12) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 32))
                .foregroundColor(.neonPink)
            Text(message)
                .font(.system(size: 12, design: .monospaced))
                .foregroundColor(.labelGray)
                .multilineTextAlignment(.center)
        }
        .padding(40)
    }

    private var emptyView: some View {
        VStack(spacing: 12) {
            Image(systemName: "figure.run.circle")
                .font(.system(size: 48))
                .foregroundColor(.labelGray)
            Text("NO SESSIONS YET")
                .font(.system(size: 12, weight: .bold, design: .monospaced))
                .tracking(2)
                .foregroundColor(.labelGray)
        }
    }

    private var noDataForSession: some View {
        VStack(spacing: 12) {
            Image(systemName: "tray")
                .font(.system(size: 32))
                .foregroundColor(.labelGray)
            Text("NO DATA FOR THIS SESSION")
                .font(.system(size: 11, weight: .bold, design: .monospaced))
                .tracking(1.5)
                .foregroundColor(.labelGray)
        }
        .frame(maxWidth: .infinity)
        .padding(40)
    }

    // MARK: - Helpers

    private func shortName(_ s: ParticipantSummary) -> String {
        if let name = s.userName, !name.isEmpty {
            return name.split(separator: " ").first.map(String.init) ?? "R\(s.displayIndex)"
        }
        let myId = ProfileManager.shared.getLocalProfile()?.id ?? ""
        return s.id == myId ? "You" : "R\(s.displayIndex)"
    }

    // MARK: - Formatters

    private func formatPace(_ pace: Double) -> String {
        guard pace > 0 && pace.isFinite && pace < 99 else { return "--:--" }
        let total = Int(pace * 60)
        return String(format: "%d'%02d\"", total / 60, total % 60)
    }

    private func formatDuration(_ seconds: TimeInterval) -> String {
        let h = Int(seconds) / 3600
        let m = (Int(seconds) % 3600) / 60
        let s = Int(seconds) % 60
        if h > 0 { return String(format: "%dh %02dm %02ds", h, m, s) }
        return String(format: "%02dm %02ds", m, s)
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        Text("Wire ViewSessionSummaryRunning with a real EventFullDetails")
            .foregroundColor(.white)
    }
    .preferredColorScheme(.dark)
}
