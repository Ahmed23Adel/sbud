//
//  ParticipantComparisonBarView.swift
//  sbud
//
//  Created by ahmed on 24/05/2026.
//

import SwiftUI


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
    let lowerIsBetter: Bool  // true for pace, false for distance/speed

    private var best: Double? {
        lowerIsBetter ? entries.map(\.value).filter { $0 > 0 }.min()
                      : entries.map(\.value).max()
    }
    private var maxValue: Double { entries.map(\.value).max() ?? 1 }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title.uppercased())
                .font(.system(size: 10, weight: .black, design: .monospaced))
                .tracking(2)
                .foregroundColor(.labelGray)

            VStack(spacing: 10) {
                ForEach(entries) { entry in
                    let isBest = best.map { abs($0 - entry.value) < 0.0001 } ?? false
                    HStack(spacing: 10) {
                        Text(entry.label)
                            .font(.system(size: 10, weight: .bold, design: .monospaced))
                            .foregroundColor(entry.color)
                            .frame(width: 40, alignment: .leading)

                        GeometryReader { geo in
                            ZStack(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 4)
                                    .fill(Color.white.opacity(0.05))

                                RoundedRectangle(cornerRadius: 4)
                                    .fill(
                                        LinearGradient(
                                            colors: [entry.color, entry.color.opacity(0.4)],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .frame(width: geo.size.width * (maxValue > 0 ? entry.value / maxValue : 0))
                            }
                        }
                        .frame(height: 12)

                        HStack(spacing: 4) {
                            Text(entry.displayText)
                                .font(.system(size: 10, weight: .black, design: .monospaced))
                                .foregroundColor(.white)
                            if isBest {
                                Image(systemName: "crown.fill")
                                    .font(.system(size: 8))
                                    .foregroundColor(.neonCyan)
                            }
                        }
                        .frame(width: 64, alignment: .trailing)
                    }
                }
            }
        }
        .padding(16)
        .background(Color.cardBg)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}
