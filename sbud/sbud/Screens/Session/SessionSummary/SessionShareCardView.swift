//
//  SessionShareCardView.swift
//  sbud
//
//  Created by ahmed on 24/05/2026.
//

import SwiftUI

// MARK: - Share card (rendered to image via ImageRenderer)

struct SessionShareCardView: View {
    let eventTitle: String
    let session: SessionHistoryEntry
    let summaries: [ParticipantSummary]
    let paceInsights: MetricInsights?
    let distanceInsights: MetricInsights?

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header
            Divider().background(Color.white.opacity(0.1))
            participantRows
            Divider().background(Color.white.opacity(0.1))
            insightsGrid
            brandingFooter
        }
        .background(Color(red: 0.06, green: 0.07, blue: 0.09))
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .frame(width: 340)
    }

    // MARK: - Header

    private var header: some View {
        HStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(Color.neonCyan.opacity(0.15))
                    .frame(width: 40, height: 40)
                Image(systemName: "figure.run")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.neonCyan)
            }
            VStack(alignment: .leading, spacing: 2) {
                Text(eventTitle.uppercased())
                    .font(.system(size: 11, weight: .black, design: .monospaced))
                    .tracking(1.5)
                    .foregroundColor(.white)
                    .lineLimit(1)
                Text(session.startDateTime.formatted(date: .abbreviated, time: .shortened))
                    .font(.system(size: 9, design: .monospaced))
                    .foregroundColor(.labelGray)
            }
            Spacer()
            VStack(alignment: .trailing, spacing: 2) {
                Text(formatDuration(session.duration))
                    .font(.system(size: 13, weight: .black, design: .monospaced))
                    .foregroundColor(.neonCyan)
                Text("\(summaries.count) PARTICIPANTS")
                    .font(.system(size: 8, design: .monospaced))
                    .tracking(1)
                    .foregroundColor(.labelGray)
            }
        }
        .padding(16)
    }

    // MARK: - Participant rows

    private var participantRows: some View {
        VStack(spacing: 0) {
            ForEach(summaries) { s in
                HStack(spacing: 10) {
                    // Color dot
                    Circle().fill(s.color).frame(width: 6, height: 6)

                    Text(s.displayName)
                        .font(.system(size: 10, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                        .lineLimit(1)
                        .frame(maxWidth: .infinity, alignment: .leading)

                    if s.avgSpeedKmH > 0 {
                        Text(String(format: "%.1f km/h", s.avgSpeedKmH))
                            .font(.system(size: 10, weight: .black, design: .monospaced))
                            .foregroundColor(s.color)
                    } else if s.totalDistanceKm > 0 {
                        Text(String(format: "%.2f km", s.totalDistanceKm))
                            .font(.system(size: 10, weight: .black, design: .monospaced))
                            .foregroundColor(s.color)
                    }

                    if s.avgPaceMinPerKm > 0 {
                        Text(formatPace(s.avgPaceMinPerKm) + "/km")
                            .font(.system(size: 9, design: .monospaced))
                            .foregroundColor(.labelGray)
                            .frame(width: 64, alignment: .trailing)
                    } else {
                        Text(s.formattedElapsed)
                            .font(.system(size: 9, design: .monospaced))
                            .foregroundColor(.labelGray)
                            .frame(width: 64, alignment: .trailing)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 7)

                if s.id != summaries.last?.id {
                    Rectangle()
                        .fill(Color.white.opacity(0.04))
                        .frame(height: 1)
                        .padding(.horizontal, 16)
                }
            }
        }
    }

    // MARK: - Insights grid

    private var insightsGrid: some View {
        HStack(spacing: 0) {
            if let p = paceInsights {
                insightBlock(
                    icon: "bolt.fill",
                    title: "PACE",
                    fastest: "\(p.min.name.split(separator:" ").first ?? "")\n\(formatPace(p.min.value))",
                    avg: "AVG \(formatPace(p.avg))",
                    slowest: "\(p.max.name.split(separator:" ").first ?? "")\n\(formatPace(p.max.value))",
                    fastColor: p.min.color,
                    slowColor: p.max.color
                )
            }

            if paceInsights != nil && distanceInsights != nil {
                Rectangle()
                    .fill(Color.white.opacity(0.07))
                    .frame(width: 1)
                    .padding(.vertical, 10)
            }

            if let d = distanceInsights {
                insightBlock(
                    icon: "flag.checkered",
                    title: "DISTANCE",
                    fastest: "\(d.max.name.split(separator:" ").first ?? "")\n\(String(format: "%.2f km", d.max.value))",
                    avg: "AVG \(String(format: "%.2f km", d.avg))",
                    slowest: "\(d.min.name.split(separator:" ").first ?? "")\n\(String(format: "%.2f km", d.min.value))",
                    fastColor: d.max.color,
                    slowColor: d.min.color
                )
            }
        }
        .padding(.vertical, 12)
    }

    private func insightBlock(
        icon: String,
        title: String,
        fastest: String,
        avg: String,
        slowest: String,
        fastColor: Color,
        slowColor: Color
    ) -> some View {
        VStack(spacing: 6) {
            HStack(spacing: 4) {
                Image(systemName: icon)
                    .font(.system(size: 8, weight: .bold))
                    .foregroundColor(.labelGray)
                Text(title)
                    .font(.system(size: 8, weight: .black, design: .monospaced))
                    .tracking(1.5)
                    .foregroundColor(.labelGray)
            }

            HStack(spacing: 0) {
                insightPill(text: fastest, label: "BEST", color: fastColor, hasCrown: true)
                insightPill(text: avg, label: "AVG", color: .neonCyan, hasCrown: false)
                insightPill(text: slowest, label: "LAST", color: slowColor, hasCrown: false)
            }
        }
        .frame(maxWidth: .infinity)
        .padding(.horizontal, 8)
    }

    private func insightPill(text: String, label: String, color: Color, hasCrown: Bool) -> some View {
        VStack(spacing: 2) {
            Text(label)
                .font(.system(size: 6, weight: .black, design: .monospaced))
                .tracking(1)
                .foregroundColor(color.opacity(0.8))
            Text(text)
                .font(.system(size: 8, weight: .bold, design: .monospaced))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .lineLimit(2)
            if hasCrown {
                Image(systemName: "crown.fill")
                    .font(.system(size: 6))
                    .foregroundColor(.neonCyan)
            }
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Branding footer

    private var brandingFooter: some View {
        HStack {
            Text("sbud")
                .font(.system(size: 9, weight: .black, design: .monospaced))
                .tracking(3)
                .foregroundColor(.neonCyan.opacity(0.6))
            Spacer()
            Text("run together")
                .font(.system(size: 8, design: .monospaced))
                .foregroundColor(.labelGray.opacity(0.4))
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
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
        if h > 0 { return String(format: "%dh %02dm", h, m) }
        return String(format: "%02dm %02ds", m, s)
    }
}

// MARK: - Previews

#if DEBUG
#Preview("Share Card — Running") {
    ScrollView {
        SessionShareCardView(
            eventTitle: "Saturday Morning Run",
            session: PreviewData.session,
            summaries: PreviewData.paceParticipants,
            paceInsights: PreviewData.paceInsights(),
            distanceInsights: PreviewData.distanceInsights()
        )
        .padding()
    }
    .background(Color(.systemBackground))
    .preferredColorScheme(.dark)
}

#Preview("Share Card — Cycling") {
    ScrollView {
        SessionShareCardView(
            eventTitle: "Sunday Bike Ride",
            session: PreviewData.session,
            summaries: PreviewData.speedParticipants,
            paceInsights: nil,
            distanceInsights: nil
        )
        .padding()
    }
    .background(Color(.systemBackground))
    .preferredColorScheme(.dark)
}

#Preview("Share Card — Gym (Time Only)") {
    ScrollView {
        SessionShareCardView(
            eventTitle: "Saturday Gym Session",
            session: PreviewData.session,
            summaries: PreviewData.timeParticipants,
            paceInsights: nil,
            distanceInsights: nil
        )
        .padding()
    }
    .background(Color(.systemBackground))
    .preferredColorScheme(.dark)
}
#endif
