//
//  MetricInsightsCard.swift
//  sbud
//
//  Created by ahmed on 24/05/2026.
//

import SwiftUI

struct MetricInsightsCard: View {

    enum MetricKind {
        case pace, distance, speed, elevationGain, elevationLoss
        case verticalDrop, duration

        var icon: String {
            switch self {
            case .pace:          return "bolt.fill"
            case .distance:      return "flag.checkered"
            case .speed:         return "gauge.with.needle.fill"
            case .elevationGain: return "arrow.up.right"
            case .elevationLoss: return "arrow.down.right"
            case .verticalDrop:  return "mountain.2.fill"
            case .duration:      return "clock.fill"
            }
        }

        var title: String {
            switch self {
            case .pace:          return "Pace"
            case .distance:      return "Distance"
            case .speed:         return "Speed"
            case .elevationGain: return "Elev Gain"
            case .elevationLoss: return "Elev Loss"
            case .verticalDrop:  return "Vertical"
            case .duration:      return "Duration"
            }
        }

        var unit: String {
            switch self {
            case .pace:          return "/km"
            case .distance:      return "km"
            case .speed:         return "km/h"
            case .elevationGain, .elevationLoss, .verticalDrop: return "m"
            case .duration:      return ""
            }
        }

        var minLabel: String {
            switch self {
            case .pace:                                              return "FASTEST"
            case .speed:                                             return "SLOWEST"
            case .duration:                                          return "SHORTEST"
            case .distance:                                          return "LEAST"
            case .elevationGain, .elevationLoss, .verticalDrop:     return "LEAST"
            }
        }

        var maxLabel: String {
            switch self {
            case .pace:                                              return "SLOWEST"
            case .speed:                                             return "FASTEST"
            case .duration:                                          return "LONGEST"
            case .distance:                                          return "MOST"
            case .elevationGain, .elevationLoss, .verticalDrop:     return "MOST"
            }
        }

        // Whether minHolder gets the crown (lower = better for pace)
        var crownOnMin: Bool {
            switch self {
            case .pace:     return true
            default:        return false
            }
        }
    }

    let kind: MetricKind
    let insights: MetricInsights

    var body: some View {
        VStack(spacing: 0) {
            header
            Divider().background(Color.white.opacity(0.06))
            HStack(spacing: 0) {
                metricColumn(
                    tag:    kind.minLabel,
                    value:  format(insights.min.value),
                    holder: insights.min,
                    accent: kind.crownOnMin ? .neonGreen : .neonPink,
                    crown:  kind.crownOnMin
                )
                columnDivider
                metricColumn(
                    tag:    "AVG",
                    value:  format(insights.avg),
                    holder: nil,
                    accent: .neonCyan,
                    crown:  false
                )
                columnDivider
                metricColumn(
                    tag:    kind.maxLabel,
                    value:  format(insights.max.value),
                    holder: insights.max,
                    accent: kind.crownOnMin ? .neonPink : .neonGreen,
                    crown:  !kind.crownOnMin
                )
            }
            .padding(.vertical, 12)
        }
        .background(Color.cardBg)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .strokeBorder(Color.white.opacity(0.07), lineWidth: 1)
        )
    }

    // MARK: - Header

    private var header: some View {
        HStack {
            Label(kind.title, systemImage: kind.icon)
                .font(.system(size: 10, weight: .black, design: .monospaced))
                .tracking(1.5)
                .foregroundColor(.labelGray)
            Spacer()
            if !kind.unit.isEmpty {
                Text(kind.unit)
                    .font(.system(size: 9, design: .monospaced))
                    .foregroundColor(.labelGray.opacity(0.5))
            }
        }
        .padding(.horizontal, 14)
        .padding(.top, 12)
        .padding(.bottom, 10)
    }

    // MARK: - Column

    private func metricColumn(
        tag: String,
        value: String,
        holder: MetricHolder?,
        accent: Color,
        crown: Bool
    ) -> some View {
        VStack(spacing: 6) {
            Text(tag)
                .font(.system(size: 7, weight: .black, design: .monospaced))
                .tracking(1.2)
                .foregroundColor(accent)

            Text(value)
                .font(.system(size: 16, weight: .black, design: .monospaced))
                .foregroundColor(.white)
                .minimumScaleFactor(0.65)
                .lineLimit(1)

            if let h = holder {
                VStack(spacing: 3) {
                    miniAvatar(url: h.profileImageUrl, color: h.color, crown: crown)
                    Text(h.name.split(separator: " ").first.map(String.init) ?? h.name)
                        .font(.system(size: 8, weight: .bold, design: .monospaced))
                        .foregroundColor(h.color)
                        .lineLimit(1)
                }
            } else {
                Color.clear.frame(height: 28 + 3 + 10)
            }
        }
        .frame(maxWidth: .infinity)
    }

    private var columnDivider: some View {
        Rectangle()
            .fill(Color.white.opacity(0.07))
            .frame(width: 1)
            .padding(.vertical, 6)
    }

    // MARK: - Mini avatar

    private func miniAvatar(url: String?, color: Color, crown: Bool) -> some View {
        ZStack(alignment: .topTrailing) {
            AvatarKFImage(url: url.flatMap(URL.init), size: 28) {
                fallbackCircle(color: color)
            }
            .overlay(Circle().strokeBorder(color, lineWidth: 1.5))

            if crown {
                Image(systemName: "crown.fill")
                    .font(.system(size: 8))
                    .foregroundColor(.neonCyan)
                    .offset(x: 4, y: -4)
            }
        }
    }

    private func fallbackCircle(color: Color) -> some View {
        Circle().fill(color.opacity(0.2)).frame(width: 28, height: 28)
            .overlay(Image(systemName: "person.fill").font(.system(size: 12)).foregroundColor(color))
    }

    // MARK: - Formatting

    private func format(_ value: Double) -> String {
        switch kind {
        case .pace:
            return SummaryFormatters.pace(value)
        case .distance:
            return String(format: "%.2f", value)
        case .speed:
            return String(format: "%.1f", value)
        case .elevationGain, .elevationLoss, .verticalDrop:
            return String(format: "%.0f", value)
        case .duration:
            return SummaryFormatters.durationShort(value)
        }
    }
}

// MARK: - Previews

#Preview("Pace Insights") {
    VStack(spacing: 12) {
        MetricInsightsCard(kind: .pace, insights: MetricInsights(
            avg: 5.65,
            min: MetricHolder(name: "Ahmed H", profileImageUrl: nil, value: 5.3, color: .neonCyan),
            max: MetricHolder(name: "Runner 3", profileImageUrl: nil, value: 6.3, color: .neonPink)
        ))
        MetricInsightsCard(kind: .distance, insights: MetricInsights(
            avg: 9.5,
            min: MetricHolder(name: "Runner 3", profileImageUrl: nil, value: 8.5,  color: .neonPink),
            max: MetricHolder(name: "Ahmed H",  profileImageUrl: nil, value: 10.2, color: .neonCyan)
        ))
    }
    .padding()
    .background(Color(.systemBackground))
    .preferredColorScheme(.dark)
}

#Preview("Speed Insights") {
    VStack(spacing: 12) {
        MetricInsightsCard(kind: .speed, insights: MetricInsights(
            avg: 28.15,
            min: MetricHolder(name: "Sara M",  profileImageUrl: nil, value: 26.2, color: .neonGreen),
            max: MetricHolder(name: "Ahmed H", profileImageUrl: nil, value: 30.1, color: .neonCyan)
        ))
        MetricInsightsCard(kind: .elevationGain, insights: MetricInsights(
            avg: 362,
            min: MetricHolder(name: "Sara M",  profileImageUrl: nil, value: 310, color: .neonGreen),
            max: MetricHolder(name: "Ahmed H", profileImageUrl: nil, value: 412, color: .neonCyan)
        ))
        MetricInsightsCard(kind: .verticalDrop, insights: MetricInsights(
            avg: 1_090,
            min: MetricHolder(name: "Sara M",  profileImageUrl: nil, value: 980,   color: .neonGreen),
            max: MetricHolder(name: "Ahmed H", profileImageUrl: nil, value: 1_200, color: .neonCyan)
        ))
    }
    .padding()
    .background(Color(.systemBackground))
    .preferredColorScheme(.dark)
}

#Preview("Duration Insights") {
    MetricInsightsCard(kind: .duration, insights: MetricInsights(
        avg: 3_617,
        min: MetricHolder(name: "Sara M",   profileImageUrl: nil, value: 3_200, color: .neonGreen),
        max: MetricHolder(name: "Runner 3", profileImageUrl: nil, value: 4_050, color: .neonPink)
    ))
    .padding()
    .background(Color(.systemBackground))
    .preferredColorScheme(.dark)
}
