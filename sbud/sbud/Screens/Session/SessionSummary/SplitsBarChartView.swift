//
//  SplitsBarChartView.swift
//  sbud
//
//  Created by ahmed on 24/05/2026.
//

import SwiftUI


struct SplitsBarChartView: View {
    struct Bar: Identifiable {
        let id = UUID()
        let label: String       // "KM 1"
        let value: Double       // raw value (pace or speed)
        let displayText: String // formatted
        let color: Color
    }

    let bars: [Bar]
    let unit: String
    let title: String

    private var maxValue: Double { bars.map(\.value).max() ?? 1 }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title.uppercased())
                .font(.system(size: 10, weight: .black, design: .monospaced))
                .tracking(2)
                .foregroundColor(.labelGray)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .bottom, spacing: 8) {
                    ForEach(bars) { bar in
                        VStack(spacing: 4) {
                            Text(bar.displayText)
                                .font(.system(size: 8, weight: .bold, design: .monospaced))
                                .foregroundColor(bar.color)

                            RoundedRectangle(cornerRadius: 4, style: .continuous)
                                .fill(
                                    LinearGradient(
                                        colors: [bar.color, bar.color.opacity(0.3)],
                                        startPoint: .top,
                                        endPoint: .bottom
                                    )
                                )
                                .frame(width: 28, height: max(8, 100 * (bar.value / maxValue)))

                            Text(bar.label)
                                .font(.system(size: 8, weight: .medium, design: .monospaced))
                                .foregroundColor(.labelGray)
                        }
                    }
                }
                .padding(.horizontal, 4)
                .padding(.bottom, 4)
            }
        }
        .padding(16)
        .background(Color.cardBg)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
    }
}

