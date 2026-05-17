//
//  ViewMetricsSummaryRun.swift
//  sbud
//
//  Created by ahmed on 16/05/2026.

import SwiftUI
import MapKit

// MARK: - ViewMetricsSummaryRun

struct ViewMetricsSummaryRun: View {
    var collector: MetricsCollectorRun

    // ── Helpers ───────────────────────────────────────────────────────────────

    private var distanceKm: String {
        String(format: "%.2f", collector.totalDistanceMeters / 1000)
    }

    private var routeCoordinates: [CLLocationCoordinate2D] {
        collector.trackedLocations.map { $0.1.coordinate }
    }

    private func formatPace(_ pace: Double) -> String {
        guard pace > 0 && pace.isFinite && pace < 99 else { return "--:--" }
        let total = Int(pace * 60)
        return String(format: "%02d:%02d", total / 60, total % 60)
    }

    // ── Metrics — only real fields from MetricsCollectorRun ──────────────────

    private var metrics: [RunMetric] {
        [
            RunMetric(
                icon: "bolt.fill",
                label: "Current Pace",
                value: formatPace(collector.currentPaceMinPerKm),
                unit: "/km",
                accentColor: .neonCyan
            ),
            RunMetric(
                icon: "chart.line.uptrend.xyaxis",
                label: "Avg Pace",
                value: formatPace(collector.averagePaceMinPerKm),
                unit: "/km",
                accentColor: .neonGreen
            ),
        ]
    }

    // ── Body ─────────────────────────────────────────────────────────────────
    // Layout goal: timer + distance + 2 metric cards all visible without scrolling.
    // Map fills the remaining space below.

    var body: some View {
        VStack(spacing: 0) {

            // ── Timer + distance row ──────────────────────────────────────
            HStack(alignment: .center, spacing: 0) {

                // Timer (left)
                SessionTimerView(startDate: collector.startDateTime)
                    .frame(maxWidth: .infinity)

                // Divider
                Rectangle()
                    .fill(Color.neonCyan.opacity(0.2))
                    .frame(width: 1, height: 56)

                // Total distance (right)
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

            // ── Metric cards ──────────────────────────────────────────────
            HStack(spacing: 10) {
                ForEach(Array(metrics.enumerated()), id: \.offset) { _, metric in
                    MetricCardView(metric: metric)
                }
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(Color.surfaceBg)

            // ── Live map — fills all remaining space ──────────────────────
            ZStack(alignment: .topLeading) {
                RunRouteMapView(coordinates: routeCoordinates)

                // "LIVE TRACKING" overlay label
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

// MARK: - RunRouteMapView
// • Starts centred on user location
// • Draws neon cyan polyline over the tracked route
// • Auto-fits to route bounding rect as it grows

struct RunRouteMapView: UIViewRepresentable {
    var coordinates: [CLLocationCoordinate2D]

    func makeUIView(context: Context) -> MKMapView {
        let map = MKMapView()
        map.mapType = .mutedStandard
        map.overrideUserInterfaceStyle = .dark
        map.pointOfInterestFilter = .excludingAll
        map.showsUserLocation = true
        // Start tracking user heading so map centres on them
        map.userTrackingMode = .follow
        map.isUserInteractionEnabled = true   // allow pinch/pan during session
        map.delegate = context.coordinator
        return map
    }

    func updateUIView(_ mapView: MKMapView, context: Context) {
        // Redraw route
        mapView.removeOverlays(mapView.overlays)

        guard coordinates.count > 1 else { return }

        let polyline = MKPolyline(coordinates: coordinates, count: coordinates.count)
        mapView.addOverlay(polyline, level: .aboveRoads)

        // Only auto-fit when the user hasn't panned away; keep it snug
        let padding = UIEdgeInsets(top: 60, left: 40, bottom: 60, right: 40)
        mapView.setVisibleMapRect(
            polyline.boundingMapRect,
            edgePadding: padding,
            animated: true
        )
    }

    func makeCoordinator() -> Coordinator { Coordinator() }

    // MARK: Coordinator

    final class Coordinator: NSObject, MKMapViewDelegate {
        func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
            guard let polyline = overlay as? MKPolyline else {
                return MKOverlayRenderer(overlay: overlay)
            }
            let r = MKPolylineRenderer(polyline: polyline)
            // Neon cyan route line
            r.strokeColor = UIColor(red: 0, green: 0.95, blue: 1, alpha: 0.95)
            r.lineWidth = 4
            r.lineCap = .round
            r.lineJoin = .round
            return r
        }

        // Render start/finish annotations if needed in future
        func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
            guard !(annotation is MKUserLocation) else { return nil }
            return nil
        }
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        Color.surfaceBg.ignoresSafeArea()
        VStack(spacing: 0) {
            // Fake header for preview context
            HStack {
                Text("Morning Run")
                    .font(.system(size: 16, weight: .black, design: .monospaced))
                    .foregroundColor(.white)
                Spacer()
                LiveBadgeView()
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(Color.black)

            ViewMetricsSummaryRun(collector: MetricsCollectorRun(isCreator: true))
                .frame(maxHeight: .infinity)
        }
    }
    .preferredColorScheme(.dark)
}
