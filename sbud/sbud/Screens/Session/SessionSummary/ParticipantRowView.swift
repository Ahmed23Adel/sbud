//
//  ParticipantRowView.swift
//  sbud
//
//  Created by ahmed on 24/05/2026.
//

import SwiftUI

struct ParticipantRowView: View {
    let summary: ParticipantSummary
    let onTap: () -> Void

    private func formatPace(_ pace: Double) -> String {
        guard pace > 0 && pace.isFinite && pace < 99 else { return "--:--" }
        let total = Int(pace * 60)
        return String(format: "%d'%02d\"", total / 60, total % 60)
    }

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 14) {
                // Color indicator + index
                ZStack {
                    Circle()
                        .fill(summary.color.opacity(0.15))
                        .frame(width: 40, height: 40)
                    Text("\(summary.displayIndex)")
                        .font(.system(size: 16, weight: .black, design: .monospaced))
                        .foregroundColor(summary.color)
                }

                VStack(alignment: .leading, spacing: 3) {
                    HStack(spacing: 6) {
                        Text(summary.metricsCreatorType == .creator ? "CREATOR" : "PARTICIPANT")
                            .font(.system(size: 8, weight: .black, design: .monospaced))
                            .tracking(1.2)
                            .foregroundColor(summary.metricsCreatorType == .creator ? .neonCyan : .labelGray)

                        if summary.endedBeforeCreator {
                            Text("EARLY EXIT")
                                .font(.system(size: 8, weight: .bold, design: .monospaced))
                                .tracking(1)
                                .foregroundColor(.neonPink)
                        }
                    }

                    Text(summary.id == ProfileManager.shared.getLocalProfile()?.id ?? "" ? "YOU" : "RUNNER \(summary.displayIndex)")
                        .font(.system(size: 13, weight: .bold, design: .monospaced))
                        .foregroundColor(.white)
                }

                Spacer()

                VStack(alignment: .trailing, spacing: 3) {
                    Text(String(format: "%.2f km", summary.totalDistanceKm))
                        .font(.system(size: 14, weight: .black, design: .monospaced))
                        .foregroundColor(.white)
                    Text(formatPace(summary.avgPaceMinPerKm) + "/km")
                        .font(.system(size: 11, weight: .medium, design: .monospaced))
                        .foregroundColor(summary.color)
                }

                Image(systemName: "chevron.right")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.labelGray)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 14, style: .continuous)
                    .fill(Color.cardBg)
                    .overlay(
                        RoundedRectangle(cornerRadius: 14, style: .continuous)
                            .strokeBorder(summary.color.opacity(0.2), lineWidth: 1)
                    )
            )
        }
    }
}

//#Preview {
//    ParticipantRowView()
//}
