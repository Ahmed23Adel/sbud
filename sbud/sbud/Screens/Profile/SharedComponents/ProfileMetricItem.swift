//
//  ProfileMetricItem.swift
//  sbud
//
//  Created by ahmed on 01/05/2026.
//

import SwiftUI

struct ProfileMetricItem: View {
    let label: String
    let value: String
    let color: Color
    var unit: String? = nil   // optional unit shown smaller + dimmer

    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(label)
                .font(.system(size: 9, weight: .bold, design: .monospaced))
                .foregroundColor(.gray)
                .kerning(1)

            if let unit {
                HStack(alignment: .lastTextBaseline, spacing: 4) {
                    Text(value)
                        .font(.system(size: 36, weight: .black, design: .monospaced))
                        .foregroundColor(color)
                    Text(unit)
                        .font(.system(size: 16, weight: .semibold, design: .monospaced))
                        .foregroundColor(color.opacity(0.45))
                }
            } else {
                Text(value)
                    .font(.system(size: 36, weight: .black, design: .monospaced))
                    .foregroundColor(color)
            }
        }
    }
}
