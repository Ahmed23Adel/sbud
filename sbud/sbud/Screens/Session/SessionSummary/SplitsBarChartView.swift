//
//  SplitsBarChartView.swift
//  sbud
//
//  Created by ahmed on 24/05/2026.
//

import SwiftUI
import Charts

struct SplitsBarChartView: View {
    struct Bar: Identifiable {
        let id = UUID()
        let label: String
        let value: Double
        let displayText: String
        let color: Color
    }

    let bars: [Bar]
    let unit: String
    let title: String
    var isSpeed: Bool = false

    private var maxValue: Double { (bars.map(\.value).max() ?? 1) * 1.18 }
    private var minValue: Double { max(0, (bars.map(\.value).min() ?? 0) * 0.82) }

    private var avgValue: Double {
        guard !bars.isEmpty else { return 0 }
        return bars.map(\.value).reduce(0, +) / Double(bars.count)
    }

    private var accentColor: Color { bars.first?.color ?? .neonCyan }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(title.uppercased())
                    .font(.system(size: 9, weight: .black, design: .monospaced))
                    .tracking(2)
                    .foregroundColor(.labelGray)
                Spacer()
                if avgValue > 0 {
                    HStack(spacing: 3) {
                        Circle()
                            .fill(accentColor.opacity(0.5))
                            .frame(width: 5, height: 5)
                        Text("AVG \(formatAxisValue(avgValue))")
                            .font(.system(size: 8, weight: .bold, design: .monospaced))
                            .foregroundColor(accentColor.opacity(0.8))
                    }
                }
            }

            Chart {
                ForEach(bars) { bar in
                    BarMark(
                        x: .value("Split", bar.label),
                        y: .value("Pace", bar.value),
                        width: .ratio(0.55)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [bar.color, bar.color.opacity(0.35)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .cornerRadius(4)
                    .annotation(position: .top, alignment: .center, spacing: 2) {
                        Text(bar.displayText)
                            .font(.system(size: 7, weight: .bold, design: .monospaced))
                            .foregroundColor(bar.color)
                    }
                }

                if avgValue > 0 {
                    RuleMark(y: .value("Avg", avgValue))
                        .lineStyle(StrokeStyle(lineWidth: 1, dash: [4, 3]))
                        .foregroundStyle(accentColor.opacity(0.5))
                }
            }
            .chartYScale(domain: minValue...maxValue)
            .chartYAxis {
                AxisMarks(values: .automatic(desiredCount: 3)) { value in
                    AxisGridLine().foregroundStyle(Color.white.opacity(0.05))
                    AxisValueLabel {
                        if let v = value.as(Double.self) {
                            Text(formatAxisValue(v))
                                .font(.system(size: 7, design: .monospaced))
                                .foregroundColor(.labelGray)
                        }
                    }
                }
            }
            .chartXAxis {
                AxisMarks { value in
                    AxisValueLabel {
                        if let label = value.as(String.self) {
                            Text(label)
                                .font(.system(size: 7, weight: .medium, design: .monospaced))
                                .foregroundColor(.labelGray)
                        }
                    }
                }
            }
            .frame(height: 120)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(Color.cardBg)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }

    private func formatAxisValue(_ v: Double) -> String {
        if isSpeed {
            guard v > 0 && v.isFinite else { return "--" }
            return String(format: "%.1f", v)
        } else {
            guard v > 0 && v.isFinite && v < 99 else { return "--:--" }
            let total = Int(v * 60)
            return String(format: "%d'%02d\"", total / 60, total % 60)
        }
    }
}

// MARK: - Previews

#Preview("Splits — Pace (Running)") {
    SplitsBarChartView(
        bars: [
            .init(label: "KM1", value: 5.1, displayText: "5'06\"", color: .neonCyan),
            .init(label: "KM2", value: 5.4, displayText: "5'24\"", color: .neonCyan),
            .init(label: "KM3", value: 4.9, displayText: "4'54\"", color: .neonCyan),
            .init(label: "KM4", value: 5.3, displayText: "5'18\"", color: .neonCyan),
            .init(label: "KM5", value: 5.0, displayText: "5'00\"", color: .neonCyan),
        ],
        unit: "/km",
        title: "Split Pace — Ahmed H",
        isSpeed: false
    )
    .padding()
    .background(Color(.systemBackground))
    .preferredColorScheme(.dark)
}

#Preview("Splits — Speed (Cycling)") {
    SplitsBarChartView(
        bars: [
            .init(label: "KM1", value: 28.5, displayText: "28.5", color: .neonGreen),
            .init(label: "KM2", value: 32.1, displayText: "32.1", color: .neonGreen),
            .init(label: "KM3", value: 30.8, displayText: "30.8", color: .neonGreen),
            .init(label: "KM4", value: 34.2, displayText: "34.2", color: .neonGreen),
        ],
        unit: "km/h",
        title: "Split Speed — Ahmed H",
        isSpeed: true
    )
    .padding()
    .background(Color(.systemBackground))
    .preferredColorScheme(.dark)
}
