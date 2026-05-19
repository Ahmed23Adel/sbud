//
//  ViewMetricsSummaryHiking.swift
//  sbud
//
//  Created by ahmed on 17/05/2026.
//

import SwiftUI
import MapKit

// MARK: - ViewMetricsSummaryHiking

struct ViewMetricsSummaryHiking: View {
    var collector: MetricsCollectorHiking

    // ── Helpers ───────────────────────────────────────────────────────────────

    private var distanceKm: String {
        String(format: "%.2f", collector.totalDistanceMeters / 1000)
    }

    private var routeCoordinates: [CLLocationCoordinate2D] {
        collector.trackedLocations.map { $0.1.coordinate }
    }

    private var maxAltitudeSafe: Double {
        collector.maxAltitudeMeters == -.infinity || !collector.maxAltitudeMeters.isFinite
            ? 0 : collector.maxAltitudeMeters
    }

    // ── Metrics — all real fields from MetricsCollectorHiking ────────────────
    // 6 metrics → 2 rows of 3, stays readable without scrolling

    private var metrics: [RunMetric] {
        [
            RunMetric(
                icon: "speedometer",
                label: "Speed",
                value: String(format: "%.1f", collector.currentSpeedKmH),
                unit: "km/h",
                accentColor: .neonCyan
            ),
            RunMetric(
                icon: "chart.line.uptrend.xyaxis",
                label: "Avg Speed",
                value: String(format: "%.1f", collector.averageSpeedKmH),
                unit: "km/h",
                accentColor: .neonGreen
            ),
            RunMetric(
                icon: "arrow.up.circle.fill",
                label: "Elev. Gain",
                value: String(format: "%.0f", collector.elevationGainMeters),
                unit: "m",
                accentColor: Color(red: 0.75, green: 0.55, blue: 1.0)
            ),
            RunMetric(
                icon: "arrow.down.circle.fill",
                label: "Elev. Loss",
                value: String(format: "%.0f", collector.elevationLossMeters),
                unit: "m",
                accentColor: .neonPink
            ),
            RunMetric(
                icon: "mountain.2.fill",
                label: "Max Alt.",
                value: String(format: "%.0f", maxAltitudeSafe),
                unit: "m",
                accentColor: Color(red: 0.75, green: 0.55, blue: 1.0)
            ),
            RunMetric(
                icon: "location.fill",
                label: "Altitude",
                value: String(format: "%.0f", collector.currentAltitudeMeters),
                unit: "m",
                accentColor: .neonCyan
            ),
        ]
    }

    // ── Body ─────────────────────────────────────────────────────────────────

    var body: some View {
        VStack(spacing: 0) {

            // ── Timer + distance row ──────────────────────────────────────
            HStack(alignment: .center, spacing: 0) {
                SessionTimerView(collector: collector)
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

            // ── 3×2 metric grid (6 metrics) ───────────────────────────────
            LazyVGrid(
                columns: Array(repeating: GridItem(.flexible(), spacing: 8), count: 3),
                spacing: 8
            ) {
                ForEach(Array(metrics.enumerated()), id: \.offset) { _, metric in
                    MetricCardView(metric: metric)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.surfaceBg)

            // ── Live map ──────────────────────────────────────────────────
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
                Image(systemName: "figure.hiking")
                    .foregroundColor(.neonCyan)
                Text("Summit Trail")
                    .font(.system(size: 16, weight: .black, design: .monospaced))
                    .foregroundColor(.white)
                Spacer()
                LiveBadgeView()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(Color.black)

            ViewMetricsSummaryHiking(collector: MetricsCollectorHiking(isCreator: true))
                .frame(maxHeight: .infinity)
        }
    }
    .preferredColorScheme(.dark)
}
