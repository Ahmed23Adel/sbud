//
//  ViewMetricsSummaryCycling.swift
//  sbud
//
//  Created by ahmed on 16/05/2026.
//

import SwiftUI
//
//  ViewMetricsSummaryCycling.swift
//  sbud
//
//  Created by ahmed on 16/05/2026.
//

import SwiftUI
import MapKit

// MARK: - ViewMetricsSummaryCycling

struct ViewMetricsSummaryCycling: View {
    var collector: MetricsCollectorCycling

    // ── Helpers ───────────────────────────────────────────────────────────────

    private var distanceKm: String {
        String(format: "%.2f", collector.totalDistanceMeters / 1000)
    }

    private var routeCoordinates: [CLLocationCoordinate2D] {
        collector.trackedLocations.map { $0.1.coordinate }
    }

    private func formatSpeed(_ speed: Double) -> String {
        guard speed.isFinite && speed >= 0 else { return "0.0" }
        return String(format: "%.1f", speed)
    }

    private var maxSpeedSafe: Double {
        collector.maxSpeedKmH == -.infinity || !collector.maxSpeedKmH.isFinite
            ? 0 : collector.maxSpeedKmH
    }

    // ── Metrics — only real fields from MetricsCollectorCycling ──────────────

    private var metrics: [RunMetric] {
        [
            RunMetric(
                icon: "speedometer",
                label: "Current Speed",
                value: formatSpeed(collector.currentSpeedKmH),
                unit: "km/h",
                accentColor: .neonCyan
            ),
            RunMetric(
                icon: "chart.line.uptrend.xyaxis",
                label: "Avg Speed",
                value: formatSpeed(collector.averageSpeedKmH),
                unit: "km/h",
                accentColor: .neonGreen
            ),
            RunMetric(
                icon: "flag.checkered",
                label: "Max Speed",
                value: formatSpeed(maxSpeedSafe),
                unit: "km/h",
                accentColor: .neonCyan
            ),
            RunMetric(
                icon: "mountain.2.fill",
                label: "Elevation",
                value: String(format: "%.0f", collector.elevationGainMeters),
                unit: "m",
                accentColor: Color(red: 0.75, green: 0.55, blue: 1.0)
            ),
        ]
    }

    // ── Body ─────────────────────────────────────────────────────────────────
    // Same no-scroll layout as running:
    //   [Timer | Distance]
    //   [2×2 metric grid]
    //   [Map — fills remaining space]

    var body: some View {
        VStack(spacing: 0) {

            // ── Timer + distance row ──────────────────────────────────────
            HStack(alignment: .center, spacing: 0) {

                SessionTimerView(startDate: collector.startDateTime)
                    .frame(maxWidth: .infinity)

                Rectangle()
                    .fill(Color.neonCyan.opacity(0.2))
                    .frame(width: 1, height: 56)

                VStack(spacing: 2) {
                    Text("DISTANCE")
                        .font(.system(size: 9, weight: .bold, design: .monospaced))
                        .tracking(2)
                        .foregroundColor(.labelGray)

                    HStack(alignment: .lastTextBaseline, spacing: 3) {
                        Text(distanceKm)
                            .font(.system(size: 30, weight: .black, design: .monospaced))
                            .foregroundColor(.white)
                            .shadow(color: .neonGreen.opacity(0.5), radius: 6)

                        Text("KM")
                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                            .foregroundColor(.neonGreen)
                            .padding(.bottom, 2)
                    }
                }
                .frame(maxWidth: .infinity)
            }
            .padding(.vertical, 14)
            .background(Color.cardBg)
            .overlay(alignment: .bottom) { AccentDivider() }

            // ── 2×2 metric grid ───────────────────────────────────────────
            LazyVGrid(
                columns: [GridItem(.flexible(), spacing: 10), GridItem(.flexible(), spacing: 10)],
                spacing: 10
            ) {
                ForEach(Array(metrics.enumerated()), id: \.offset) { _, metric in
                    MetricCardView(metric: metric)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.surfaceBg)

            // ── Live map — fills remaining space ──────────────────────────
            ZStack(alignment: .topLeading) {
                RunRouteMapView(coordinates: routeCoordinates)

                HStack(spacing: 6) {
                    Circle()
                        .fill(Color.neonCyan)
                        .frame(width: 6, height: 6)
                        .shadow(color: .neonCyan, radius: 3)

                    Text("TRACKING")
                        .font(.system(size: 9, weight: .bold, design: .monospaced))
                        .tracking(2)
                        .foregroundColor(.neonCyan)
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 6)
                .background(.ultraThinMaterial)
                .clipShape(Capsule())
                .padding(12)
            }
        }
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        Color.surfaceBg.ignoresSafeArea()
        VStack(spacing: 0) {
            HStack {
                Image(systemName: "bicycle")
                    .foregroundColor(.neonCyan)
                Text("Morning Ride")
                    .font(.system(size: 16, weight: .black, design: .monospaced))
                    .foregroundColor(.white)
                Spacer()
                LiveBadgeView()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(Color.black)

            ViewMetricsSummaryCycling(collector: MetricsCollectorCycling(isCreator: true))
                .frame(maxHeight: .infinity)
        }
    }
    .preferredColorScheme(.dark)
}
