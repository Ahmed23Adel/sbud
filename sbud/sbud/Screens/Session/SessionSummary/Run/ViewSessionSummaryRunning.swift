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
    var onParticipantTapped: (String) -> Void = { _ in }  // wire via coordinator

    @State private var vm: ViewModelSessionSummaryRunning

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
        .task { await vm.load() }
    }

    // MARK: - Main content

    private var mainContent: some View {
        VStack(spacing: 0) {
            // Session selector
            SessionSelectorView(sessions: vm.sessions, selectedIndex: $vm.selectedSessionIndex)

            AccentDivider()

            ScrollView {
                LazyVStack(spacing: 20) {
                    if vm.sessionMetrics.isEmpty {
                        noDataForSession
                    } else {
                        sessionDateHeader
                        overallStatsSection
                        participantsSection
                        paceComparisonSection
                        distanceComparisonSection
                        splitsSection
                        routeMapSection
                    }
                }
                .padding(.horizontal, 20)
                .padding(.vertical, 20)
            }
        }
    }

    // MARK: - Session date header

    private var sessionDateHeader: some View {
        Group {
            if let session = vm.selectedSession {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text(session.startDateTime.formatted(date: .complete, time: .omitted))
                            .font(.system(size: 11, weight: .bold, design: .monospaced))
                            .foregroundColor(.labelGray)
                        Text(formatDuration(session.duration))
                            .font(.system(size: 18, weight: .black, design: .monospaced))
                            .foregroundColor(.white)
                    }
                    Spacer()
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("\(vm.participantCount)")
                            .font(.system(size: 28, weight: .black, design: .monospaced))
                            .foregroundColor(.neonCyan)
                            .shadow(color: .neonCyan.opacity(0.5), radius: 6)
                        Text("RUNNERS")
                            .font(.system(size: 9, weight: .bold, design: .monospaced))
                            .tracking(1.5)
                            .foregroundColor(.labelGray)
                    }
                }
                .padding(16)
                .background(Color.cardBg)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .strokeBorder(Color.neonCyan.opacity(0.15), lineWidth: 1)
                )
            }
        }
    }

    // MARK: - Overall stats

    private var overallStatsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeaderView(title: "Session Stats", icon: "chart.bar.fill")

            SummaryStatBanner(stats: [
                .init(
                    label: "AVG PACE",
                    value: formatPace(vm.avgPaceMinPerKm),
                    unit: "/km",
                    color: .neonCyan
                ),
                .init(
                    label: "BEST PACE",
                    value: formatPace(vm.minPaceMinPerKm),
                    unit: "/km",
                    color: .neonGreen
                ),
                .init(
                    label: "AVG DIST",
                    value: String(format: "%.2f", vm.avgDistanceKm),
                    unit: "km",
                    color: .neonPink
                )
            ])
        }
    }

    // MARK: - Participants

    private var participantsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeaderView(title: "Participants", icon: "person.2.fill")

            ForEach(vm.participantSummaries) { summary in
                ParticipantRowView(summary: summary) {
                    onParticipantTapped(summary.id)
                }
            }
        }
    }

    // MARK: - Pace comparison

    private var paceComparisonSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeaderView(title: "Pace Comparison", icon: "bolt.fill", accentColor: .neonGreen)

            ParticipantComparisonBarView(
                title: "Average Pace",
                unit: "/km",
                entries: vm.participantSummaries.map { s in
                    .init(
                        label: "R\(s.displayIndex)",
                        value: s.avgPaceMinPerKm,
                        displayText: formatPace(s.avgPaceMinPerKm),
                        color: s.color
                    )
                },
                lowerIsBetter: true
            )

            ParticipantComparisonBarView(
                title: "Best Split Pace",
                unit: "/km",
                entries: vm.participantSummaries.map { s in
                    .init(
                        label: "R\(s.displayIndex)",
                        value: s.bestSplitPace,
                        displayText: formatPace(s.bestSplitPace),
                        color: s.color
                    )
                },
                lowerIsBetter: true
            )
        }
    }

    // MARK: - Distance comparison

    private var distanceComparisonSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeaderView(title: "Distance", icon: "flag.checkered", accentColor: .neonPink)

            ParticipantComparisonBarView(
                title: "Total Distance",
                unit: "km",
                entries: vm.participantSummaries.map { s in
                    .init(
                        label: "R\(s.displayIndex)",
                        value: s.totalDistanceKm,
                        displayText: String(format: "%.2f", s.totalDistanceKm),
                        color: s.color
                    )
                },
                lowerIsBetter: false
            )
        }
    }

    // MARK: - Splits section

    @State private var selectedParticipantForSplits: Int = 0

    private var splitsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeaderView(title: "Splits", icon: "stopwatch.fill", accentColor: .neonGreen)

            // Participant picker for splits
            if vm.participantSummaries.count > 1 {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(Array(vm.participantSummaries.enumerated()), id: \.offset) { index, s in
                            let isSelected = selectedParticipantForSplits == index
                            Button {
                                withAnimation(.spring(response: 0.3)) {
                                    selectedParticipantForSplits = index
                                }
                            } label: {
                                Text("RUNNER \(s.displayIndex)")
                                    .font(.system(size: 9, weight: .black, design: .monospaced))
                                    .tracking(1.2)
                                    .foregroundColor(isSelected ? .black : s.color)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 6)
                                    .background(
                                        RoundedRectangle(cornerRadius: 8)
                                            .fill(isSelected ? s.color : s.color.opacity(0.1))
                                    )
                            }
                        }
                    }
                }
            }

            // Splits chart for selected participant
            if selectedParticipantForSplits < vm.participantSummaries.count {
                let summary = vm.participantSummaries[selectedParticipantForSplits]
                if summary.splits.isEmpty {
                    Text("No splits recorded")
                        .font(.system(size: 12, design: .monospaced))
                        .foregroundColor(.labelGray)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.cardBg)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                } else {
                    SplitsBarChartView(
                        bars: summary.splits.map { split in
                            .init(
                                label: "KM\(split.number)",
                                value: split.paceInMinPerKm,
                                displayText: split.formatted,
                                color: summary.color
                            )
                        },
                        unit: "/km",
                        title: "Split Pace — Runner \(summary.displayIndex)"
                    )
                }
            }
        }
    }

    // MARK: - Route map section

    @State private var selectedRouteIndex: Int? = nil  // nil = all routes

    private var routeMapSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeaderView(title: "Routes", icon: "map.fill", accentColor: .neonCyan)

            // Route picker
            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    // "All" button
                    Button {
                        withAnimation { selectedRouteIndex = nil }
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
                            withAnimation { selectedRouteIndex = isSelected ? nil : index }
                        } label: {
                            Text("R\(s.displayIndex)")
                                .font(.system(size: 9, weight: .black, design: .monospaced))
                                .tracking(1.2)
                                .foregroundColor(isSelected ? .black : s.color)
                                .padding(.horizontal, 10)
                                .padding(.vertical, 6)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(isSelected ? s.color : s.color.opacity(0.1))
                                )
                        }
                    }
                }
            }

            // Map
            let tracks = vm.participantSummaries.map { s in (
                color: UIColor(s.color),
                coordinates: s.track.map {
                    CLLocationCoordinate2D(latitude: $0.latitude, longitude: $0.longitude)
                }
            )}

            MultiRouteMapView(tracks: tracks, selectedTrackIndex: selectedRouteIndex)
                .frame(height: 280)
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .overlay(
                    RoundedRectangle(cornerRadius: 14, style: .continuous)
                        .strokeBorder(Color.neonCyan.opacity(0.2), lineWidth: 1)
                )
        }
    }

    // MARK: - Loading / error / empty

    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .tint(.neonCyan)
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
