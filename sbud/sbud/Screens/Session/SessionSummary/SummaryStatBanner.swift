//
//  SummaryStatBanner.swift
//  sbud
//
//  Created by ahmed on 24/05/2026.
//

import SwiftUI

struct SummaryStatBanner: View {
    struct Stat {
        let label: String
        let value: String
        let unit: String
        let color: Color
    }

    let stats: [Stat]

    var body: some View {
        HStack(spacing: 0) {
            ForEach(Array(stats.enumerated()), id: \.offset) { index, stat in
                VStack(spacing: 4) {
                    Text(stat.label)
                        .font(.system(size: 9, weight: .bold, design: .monospaced))
                        .tracking(1.5)
                        .foregroundColor(.labelGray)

                    HStack(alignment: .lastTextBaseline, spacing: 2) {
                        Text(stat.value)
                            .font(.system(size: 22, weight: .black, design: .monospaced))
                            .foregroundColor(.white)
                            .shadow(color: stat.color.opacity(0.5), radius: 4)
                        Text(stat.unit)
                            .font(.system(size: 9, weight: .bold, design: .monospaced))
                            .foregroundColor(stat.color)
                    }
                }
                .frame(maxWidth: .infinity)

                if index < stats.count - 1 {
                    Rectangle()
                        .fill(Color.white.opacity(0.07))
                        .frame(width: 1, height: 40)
                }
            }
        }
        .padding(.vertical, 16)
        .padding(.horizontal, 12)
        .background(Color.cardBg)
        .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .strokeBorder(Color.neonCyan.opacity(0.1), lineWidth: 1)
        )
    }
}

//#Preview {
//    SummaryStatBanner()
//}
