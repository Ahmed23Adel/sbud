//
//  ViewEventSummary.swift
//  sbud
//
//  Created by ahmed on 16/05/2026.
//
//
//  ViewEventSummary.swift
//  sbud
//
//  Created by ahmed on 16/05/2026.
//

import SwiftUI

/// Compact event identity row: activity icon + event title + live badge.
/// Designed to sit in a fixed header — no scrolling needed.
struct ViewEventSummary: View {
    let event: EventFullDetails

    var body: some View {
        HStack(spacing: 12) {

            // Activity icon pill
            ZStack {
                RoundedRectangle(cornerRadius: 10, style: .continuous)
                    .fill(Color.neonCyan.opacity(0.12))
                    .overlay(
                        RoundedRectangle(cornerRadius: 10, style: .continuous)
                            .strokeBorder(Color.neonCyan.opacity(0.3), lineWidth: 1)
                    )
                    .frame(width: 38, height: 38)

                Image(systemName: event.activityType.icon)
                    .font(.system(size: 16, weight: .bold))
                    .foregroundColor(.neonCyan)
            }

            // Event title
            VStack(alignment: .leading, spacing: 2) {
                Text(event.title)
                    .font(.system(size: 16, weight: .black, design: .monospaced))
                    .foregroundColor(.white)
                    .lineLimit(1)

                Text(event.activityType.rawValue.uppercased())
                    .font(.system(size: 9, weight: .bold, design: .monospaced))
                    .tracking(1.5)
                    .foregroundColor(.labelGray)
            }

            Spacer()

            LiveBadgeView()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(Color.black)
        .overlay(alignment: .bottom) {
            Rectangle()
                .fill(
                    LinearGradient(
                        colors: [.neonCyan.opacity(0.5), .neonGreen.opacity(0.25), .clear],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(height: 1)
        }
    }
}
