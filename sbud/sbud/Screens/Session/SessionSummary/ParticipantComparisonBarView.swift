//
//  ParticipantComparisonBarView.swift
//  sbud
//
//  Created by ahmed on 24/05/2026.
//

import SwiftUI
import Charts

struct ParticipantComparisonBarView: View {
    struct Entry: Identifiable {
        let id = UUID()
        let label: String
        let value: Double
        let displayText: String
        let color: Color
    }

    let title: String
    let unit: String
    let entries: [Entry]
    let lowerIsBetter: Bool

    private var best: Double? {
        lowerIsBetter ? entries.map(\.value).filter { $0 > 0 }.min()
                      : entries.map(\.value).max()
    }
    private var maxValue: Double { entries.map(\.value).max() ?? 1 }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title.uppercased())
                .font(.system(size: 9, weight: .black, design: .monospaced))
                .tracking(2)
                .foregroundColor(.labelGray)

            Chart {
                ForEach(entries) { entry in
                    BarMark(
                        x: .value("Value", entry.value),
                        y: .value("Runner", entry.label),
                        height: .fixed(14)
                    )
                    .foregroundStyle(
                        LinearGradient(
                            colors: [entry.color, entry.color.opacity(0.4)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(4)
                    .annotation(position: .trailing, alignment: .leading, spacing: 4) {
                        let isBest = best.map { abs($0 - entry.value) < 0.0001 } ?? false
                        HStack(spacing: 3) {
                            Text(entry.displayText)
                                .font(.system(size: 9, weight: .black, design: .monospaced))
                                .foregroundColor(.white)
                            if isBest {
                                Image(systemName: "crown.fill")
                                    .font(.system(size: 7))
                                    .foregroundColor(.neonCyan)
                            }
                        }
                    }
                }
            }
            .chartXAxis(.hidden)
            .chartYAxis {
                AxisMarks { value in
                    AxisValueLabel {
                        if let label = value.as(String.self) {
                            Text(label)
                                .font(.system(size: 9, weight: .bold, design: .monospaced))
                                .foregroundColor(
                                    entries.first(where: { $0.label == label })?.color ?? .labelGray
                                )
                        }
                    }
                }
            }
            .chartXScale(domain: 0...(maxValue * 1.4))
            .frame(height: CGFloat(entries.count) * 26 + 8)
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 12)
        .background(Color.cardBg)
        .clipShape(RoundedRectangle(cornerRadius: 12, style: .continuous))
    }
}

// MARK: - Previews

#Preview("Comparison — Pace (lower is better)") {
    VStack(spacing: 16) {
        ParticipantComparisonBarView(
            title: "Average Pace",
            unit: "/km",
            entries: [
                .init(label: "Ahmed", value: 5.3, displayText: "5'18\"/km", color: .neonCyan),
                .init(label: "Sara",  value: 5.9, displayText: "5'54\"/km", color: .neonGreen),
                .init(label: "P3",    value: 6.3, displayText: "6'18\"/km", color: .neonPink),
            ],
            lowerIsBetter: true
        )
        ParticipantComparisonBarView(
            title: "Best Split Pace",
            unit: "/km",
            entries: [
                .init(label: "Ahmed", value: 4.9, displayText: "4'54\"/km", color: .neonCyan),
                .init(label: "Sara",  value: 5.6, displayText: "5'36\"/km", color: .neonGreen),
                .init(label: "P3",    value: 6.0, displayText: "6'00\"/km", color: .neonPink),
            ],
            lowerIsBetter: true
        )
    }
    .padding()
    .background(Color(.systemBackground))
    .preferredColorScheme(.dark)
}

#Preview("Comparison — Speed (higher is better)") {
    VStack(spacing: 16) {
        ParticipantComparisonBarView(
            title: "Average Speed",
            unit: "km/h",
            entries: [
                .init(label: "Ahmed", value: 30.1, displayText: "30.1 km/h", color: .neonCyan),
                .init(label: "Sara",  value: 26.2, displayText: "26.2 km/h", color: .neonGreen),
            ],
            lowerIsBetter: false
        )
        ParticipantComparisonBarView(
            title: "Best Split Speed",
            unit: "km/h",
            entries: [
                .init(label: "Ahmed", value: 34.2, displayText: "34.2 km/h", color: .neonCyan),
                .init(label: "Sara",  value: 28.0, displayText: "28.0 km/h", color: .neonGreen),
            ],
            lowerIsBetter: false
        )
    }
    .padding()
    .background(Color(.systemBackground))
    .preferredColorScheme(.dark)
}

#Preview("Comparison — Duration") {
    VStack(spacing: 16) {
        ParticipantComparisonBarView(
            title: "Session Duration",
            unit: "",
            entries: [
                .init(label: "Ahmed", value: 3_600, displayText: "1h 00m", color: .neonCyan),
                .init(label: "Sara",  value: 3_200, displayText: "53m 20s", color: .neonGreen),
                .init(label: "P3",    value: 4_050, displayText: "1h 07m", color: .neonPink),
            ],
            lowerIsBetter: false
        )
        ParticipantComparisonBarView(
            title: "Distance Covered",
            unit: "km",
            entries: [
                .init(label: "Ahmed", value: 10.2, displayText: "10.20 km", color: .neonCyan),
                .init(label: "Sara",  value: 9.8,  displayText: "9.80 km",  color: .neonGreen),
                .init(label: "P3",    value: 8.5,  displayText: "8.50 km",  color: .neonPink),
            ],
            lowerIsBetter: false
        )
    }
    .padding()
    .background(Color(.systemBackground))
    .preferredColorScheme(.dark)
}
