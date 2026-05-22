//
//  HourlyCard.swift
//  sbud
//
//  Created by ahmed on 22/05/2026.
//

import SwiftUI

struct HourlyCard: View {
    let slice: HourlySlice
    let hourFmt: DateFormatter

    var body: some View {
        VStack(spacing: 6) {
            Text(hourFmt.string(from: slice.time))
                .font(.caption2)
                .foregroundColor(.gray)

            Image(systemName: wmoSFSymbol(slice.code))
                .font(.title2)
                .foregroundColor(wmoColor(slice.code))

            Text(String(format: "%.0f°", slice.temp))
                .font(.subheadline.bold())
                .foregroundColor(.white)

            // Rain probability
            HStack(spacing: 2) {
                Image(systemName: "drop.fill")
                    .font(.system(size: 8))
                    .foregroundColor(.blue)
                Text("\(slice.precipProb)%")
                    .font(.caption2)
                    .foregroundColor(.blue)
            }

            // Wind
            HStack(spacing: 2) {
                Image(systemName: "wind")
                    .font(.system(size: 8))
                    .foregroundColor(.gray)
                Text(String(format: "%.0f", slice.wind))
                    .font(.caption2)
                    .foregroundColor(.gray)
            }
        }
        .padding(10)
        .background(.white.opacity(0.07))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}
