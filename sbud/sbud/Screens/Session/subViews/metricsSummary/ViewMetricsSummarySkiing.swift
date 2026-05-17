//
//  ViewMetricsSummarySkiing.swift
//  sbud
//
//  Created by ahmed on 17/05/2026.
//


import SwiftUI
import MapKit

// MARK: - ViewMetricsSummarySkiing

struct ViewMetricsSummarySkiing: View {
    var collector: MetricsCollectorSkiing

    // ── Helpers ───────────────────────────────────────────────────────────────

    private var distanceKm: String {
        String(format: "%.2f", collector.totalDistanceMeters / 1000)
    }

    private var routeCoordinates: [CLLocationCoordinate2D] {
        collector.trackedLocations.map { $0.1.coordinate }
    }

    private var maxSpeedSafe: Double {
        collector.maxSpeedKmH == -.infinity || !collector.maxSpeedKmH.isFinite
            ? 0 : collector.maxSpeedKmH
    }

    // ── Metrics — all real fields from MetricsCollectorSkiing ────────────────
    // 6 metrics → 3×2 grid, no scroll needed

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
                icon: "flag.checkered",
                label: "Max Speed",
                value: String(format: "%.1f", maxSpeedSafe),
                unit: "km/h",
                accentColor: .neonPink
            ),
            RunMetric(
                icon: "chart.line.uptrend.xyaxis",
                label: "Avg Speed",
                value: String(format: "%.1f", collector.averageSpeedKmH),
                unit: "km/h",
                accentColor: .neonGreen
            ),
            RunMetric(
                icon: "arrow.down.to.line",
                label: "Vert. Drop",
                value: String(format: "%.0f", collector.verticalDropMeters),
                unit: "m",
                accentColor: .neonCyan
            ),
            RunMetric(
                icon: "arrow.up.circle.fill",
                label: "Elev. Gain",
                value: String(format: "%.0f", collector.elevationGainMeters),
                unit: "m",
                accentColor: Color(red: 0.75, green: 0.55, blue: 1.0)
            ),
            RunMetric(
                icon: "number",
                label: "Runs",
                value: "\(collector.numberOfRuns)",
                unit: "",
                accentColor: .neonGreen
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
                Image(systemName: "figure.skiing.downhill")
                    .foregroundColor(.neonCyan)
                Text("Alpine Run")
                    .font(.system(size: 16, weight: .black, design: .monospaced))
                    .foregroundColor(.white)
                Spacer()
                LiveBadgeView()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(Color.black)

            ViewMetricsSummarySkiing(collector: MetricsCollectorSkiing(isCreator: true))
                .frame(maxHeight: .infinity)
        }
    }
    .preferredColorScheme(.dark)
}
