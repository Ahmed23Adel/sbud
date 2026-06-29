//
//  PaceTrendChartView.swift
//  sbud
//
//  Created by ahmed on 24/05/2026.
//

import SwiftUI
import Charts

struct PaceTrendChartView: View {

    struct DataPoint: Identifiable {
        let id = UUID()
        let participantName: String
        let splitNumber: Int
        let value: Double
        let color: Color
    }

    let summaries: [ParticipantSummary]
    let shortName: (ParticipantSummary) -> String
    var isSpeed: Bool = false
    var title: String = "Pace Trend"

    private var dataPoints: [DataPoint] {
        summaries.flatMap { s in
            s.splits.map { split in
                DataPoint(participantName: shortName(s), splitNumber: split.number,
                          value: split.chartValue, color: s.color)
            }
        }
    }
    // Calculates Y axis range with 12% padding above and below the real min/max, so lines don't touch the edges. max(0, ...) prevents negative Y axis.
    private var yMin: Double {
        max(0, (dataPoints.map(\.value).min() ?? 0) * 0.88)
    }
    private var yMax: Double {
        (dataPoints.map(\.value).max() ?? 10) * 1.12
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            SectionHeaderView(title: title, icon: "chart.line.uptrend.xyaxis", accentColor: .neonCyan)

            Chart {
                ForEach(summaries) { s in
                    let name = shortName(s)
                    ForEach(s.splits) { split in
                        LineMark(
                            x: .value("Split", split.number),
                            y: .value(isSpeed ? "Speed" : "Pace", split.chartValue),
                            series: .value("Participant", name)// // groups into separate lines
                        )
                        .foregroundStyle(s.color)
                        .lineStyle(StrokeStyle(lineWidth: 2))
                        .interpolationMethod(.catmullRom) // .catmullRom is a smoothing algorithm — makes the line curve naturally between points instead of sharp angles.


                        PointMark(
                            x: .value("Split", split.number),
                            y: .value(isSpeed ? "Speed" : "Pace", split.chartValue)
                        )
                        .foregroundStyle(s.color)
                        .symbolSize(30)
                    }
                }
            }
            .chartYScale(domain: yMin...yMax)
            .chartYAxis {
                //  asks for ~4 tick marks (Charts may adjust). For each tick you get:
                AxisMarks(values: .automatic(desiredCount: 4)) { value in
                    AxisGridLine()
                        .foregroundStyle(Color.white.opacity(0.06))
                    AxisValueLabel {
                        if let v = value.as(Double.self) {
                            Text(formatAxisValue(v))
                                .font(.system(size: 8, design: .monospaced))
                                .foregroundColor(.labelGray)
                        }
                    }
                }
            }
            .chartXAxis {
                AxisMarks(values: .automatic) { value in
                    AxisGridLine()
                        .foregroundStyle(Color.white.opacity(0.04))
                    AxisValueLabel {
                        if let km = value.as(Int.self) {
                            Text("KM\(km)")
                                .font(.system(size: 8, weight: .medium, design: .monospaced))
                                .foregroundColor(.labelGray)
                        }
                    }
                }
            }
            // A fully custom legend — you build it yourself with SwiftUI views inside the closure. The default legend would just show colored lines, this gives you colored circles + names.
            .chartLegend(position: .bottom, alignment: .leading, spacing: 8) {
                HStack(spacing: 12) {
                    ForEach(summaries) { s in
                        HStack(spacing: 4) {
                            Circle()
                                .fill(s.color)
                                .frame(width: 7, height: 7)
                            Text(shortName(s))
                                .font(.system(size: 8, weight: .bold, design: .monospaced))
                                .foregroundColor(.labelGray)
                        }
                    }
                }
            }
            .frame(height: 140)
        }
        .padding(16)
        .background(Color.cardBg)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .strokeBorder(Color.neonCyan.opacity(0.1), lineWidth: 1)
        )
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

#Preview("Pace Trend — Multi-runner") {
    let splits1: [DisplaySplit] = [
        DisplaySplit(number: 1, chartValue: 5.1, displayText: "5'06\"", isSpeed: false),
        DisplaySplit(number: 2, chartValue: 5.4, displayText: "5'24\"", isSpeed: false),
        DisplaySplit(number: 3, chartValue: 4.9, displayText: "4'54\"", isSpeed: false),
        DisplaySplit(number: 4, chartValue: 5.2, displayText: "5'12\"", isSpeed: false),
    ]
    let splits2: [DisplaySplit] = [
        DisplaySplit(number: 1, chartValue: 5.7, displayText: "5'42\"", isSpeed: false),
        DisplaySplit(number: 2, chartValue: 6.1, displayText: "6'06\"", isSpeed: false),
        DisplaySplit(number: 3, chartValue: 5.9, displayText: "5'54\"", isSpeed: false),
        DisplaySplit(number: 4, chartValue: 5.6, displayText: "5'36\"", isSpeed: false),
    ]
    let summaries: [ParticipantSummary] = [
        ParticipantSummary(id: "1", displayIndex: 1, elapsedSeconds: 3_245,
            metricsCreatorType: .creator, endedBeforeCreator: false,
            userName: "Ahmed H", profileImageUrl: nil,
            totalDistanceKm: 10.2, avgPaceMinPerKm: 5.2, bestSplitPace: 4.9,
            splits: splits1),
        ParticipantSummary(id: "2", displayIndex: 2, elapsedSeconds: 3_512,
            metricsCreatorType: .normalParticipant, endedBeforeCreator: false,
            userName: "Sara M", profileImageUrl: nil,
            totalDistanceKm: 9.8, avgPaceMinPerKm: 5.8, bestSplitPace: 5.6,
            splits: splits2),
    ]
    return PaceTrendChartView(summaries: summaries, shortName: { $0.userName.map { String($0.split(separator:" ").first ?? "") } ?? "P\($0.displayIndex)" })
        .padding()
        .background(Color(.systemBackground))
        .preferredColorScheme(.dark)
}
//
//#Preview("Speed Trend — Cycling") {
//    let splits1: [DisplaySplit] = [
//        DisplaySplit(number: 1, chartValue: 28.5, displayText: "28.5", isSpeed: true),
//        DisplaySplit(number: 2, chartValue: 32.1, displayText: "32.1", isSpeed: true),
//        DisplaySplit(number: 3, chartValue: 30.8, displayText: "30.8", isSpeed: true),
//        DisplaySplit(number: 4, chartValue: 34.2, displayText: "34.2", isSpeed: true),
//    ]
//    let summaries: [ParticipantSummary] = [
//        ParticipantSummary(id: "1", displayIndex: 1, elapsedSeconds: 5_400,
//            metricsCreatorType: .creator, endedBeforeCreator: false,
//            userName: "Ahmed H", profileImageUrl: nil,
//            totalDistanceKm: 32.5, avgSpeedKmH: 30.1, bestSplitSpeedKmH: 34.2,
//            splits: splits1),
//    ]
//    return PaceTrendChartView(summaries: summaries,
//        shortName: { _ in "Ahmed" },
//        isSpeed: true, title: "Speed Trend")
//        .padding()
//        .background(Color(.systemBackground))
//        .preferredColorScheme(.dark)
//}
