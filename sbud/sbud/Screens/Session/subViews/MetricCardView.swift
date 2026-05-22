//
//  MetricCardView.swift
//  sbud
//
//  Created by ahmed on 17/05/2026.
//
//
//  DesignSystem.swift
//  sbud
//
//  Shared design tokens, reusable metric card, and UI primitives
//  used across ALL activity session views (run, cycle, swim, etc.)
//

import SwiftUI

// MARK: - Color tokens

extension Color {
    static let neonCyan   = Color(red: 0.0,  green: 0.95, blue: 1.0)
    static let neonGreen  = Color(red: 0.6,  green: 1.0,  blue: 0.3)
    static let neonPink   = Color(red: 1.0,  green: 0.2,  blue: 0.5)
    static let cardBg     = Color(red: 0.08, green: 0.09, blue: 0.12)
    static let surfaceBg  = Color(red: 0.05, green: 0.06, blue: 0.08)
    static let labelGray  = Color(white: 0.45)
}

// MARK: - RunMetric model

/// Generic metric descriptor — use for any activity type
struct RunMetric {
    let icon: String        // SF Symbol name
    let label: String
    let value: String
    let unit: String
    var accentColor: Color = .neonCyan
}

// MARK: - MetricCardView
// Reusable across Run, Cycle, Swim, or any future activity.

struct MetricCardView: View {
    let metric: RunMetric

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color.cardBg)
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .strokeBorder(
                            LinearGradient(
                                colors: [metric.accentColor.opacity(0.45), .clear],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
                .shadow(color: metric.accentColor.opacity(0.14), radius: 10, x: 0, y: 4)

            GridPatternView()
                .clipShape(RoundedRectangle(cornerRadius: 16, style: .continuous))
                .opacity(0.35)

            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 5) {
                    Image(systemName: metric.icon)
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(metric.accentColor)

                    Text(metric.label.uppercased())
                        .font(.system(size: 9, weight: .bold, design: .monospaced))
                        .tracking(1.2)
                        .foregroundColor(.labelGray)

                    Spacer()
                }

                HStack(alignment: .lastTextBaseline, spacing: 3) {
                    Text(metric.value)
                        .font(.system(size: 30, weight: .black, design: .monospaced))
                        .foregroundColor(.white)
                        .shadow(color: metric.accentColor.opacity(0.55), radius: 6)

                    Text(metric.unit.uppercased())
                        .font(.system(size: 10, weight: .semibold, design: .monospaced))
                        .foregroundColor(metric.accentColor)
                        .padding(.bottom, 2)
                }
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 12)
        }
    }
}

#Preview{
    MetricCardView(metric: RunMetric(
        icon: "speedometer",
        label: "Speed",
        value: String(format: "%.1f", 18.5),
        unit: "km/h",
        accentColor: .neonCyan
        
    ))
}
