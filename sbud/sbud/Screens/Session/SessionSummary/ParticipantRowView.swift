//
//  ParticipantRowView.swift
//  sbud
//
//  Created by ahmed on 24/05/2026.
//

import SwiftUI
import FirebaseAuth

struct ParticipantRowView: View {
    let summary: ParticipantSummary
    let onTap: () -> Void
    
    var onVote: ((String) -> Void)? = nil
    
    @State private var showFeedbackSheet = false

    private func formatPace(_ pace: Double) -> String {
        guard pace > 0 && pace.isFinite && pace < 99 else { return "--:--" }
        let total = Int(pace * 60)
        return String(format: "%d'%02d\"", total / 60, total % 60)
    }

    var body: some View {
        VStack(spacing: 0) {
            Button(action: onTap) {
                HStack(spacing: 14) {
                    avatar

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

                        Text(summary.displayName)
                            .font(.system(size: 13, weight: .bold, design: .monospaced))
                            .foregroundColor(.white)
                            .lineLimit(1)
                    }

                    Spacer()

                    VStack(alignment: .trailing, spacing: 3) {
                        if summary.avgSpeedKmH > 0 {
                            Text(String(format: "%.1f km/h", summary.avgSpeedKmH))
                                .font(.system(size: 14, weight: .black, design: .monospaced))
                                .foregroundColor(.white)
                            if summary.totalDistanceKm > 0 {
                                Text(String(format: "%.2f km", summary.totalDistanceKm))
                                    .font(.system(size: 11, weight: .medium, design: .monospaced))
                                    .foregroundColor(summary.color)
                            }
                        } else if summary.avgPaceMinPerKm > 0 {
                            Text(String(format: "%.2f km", summary.totalDistanceKm))
                                .font(.system(size: 14, weight: .black, design: .monospaced))
                                .foregroundColor(.white)
                            Text(formatPace(summary.avgPaceMinPerKm) + "/km")
                                .font(.system(size: 11, weight: .medium, design: .monospaced))
                                .foregroundColor(summary.color)
                        } else {
                            Text(summary.formattedElapsed)
                                .font(.system(size: 14, weight: .black, design: .monospaced))
                                .foregroundColor(.white)
                            Text("DURATION")
                                .font(.system(size: 8, weight: .bold, design: .monospaced))
                                .tracking(1)
                                .foregroundColor(.labelGray)
                        }
                    }

                    Image(systemName: "chevron.right")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.labelGray)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 12)
            }
            .buttonStyle(.plain) // Fondamentale per separare il tap della riga da quello dei feedback
            
            if let onVote = onVote, summary.id != Auth.auth().currentUser?.uid {
                Divider()
                    .background(Color.white.opacity(0.1))
                    .padding(.horizontal, 16)
                
                // Ricaviamo il mio ID per vedere se ho già votato
                let myUserId = Auth.auth().currentUser?.uid ?? ""
                let myPreviousVote = summary.receivedFeedbacks?[myUserId]
                
                Button {
                    showFeedbackSheet = true
                } label: {
                    HStack {
                        Image(systemName: myPreviousVote != nil ? "star.fill" : "star")
                        Text(myPreviousVote != nil ? "YOU RATED: \(myPreviousVote!)" : "RATE TEAMMATE")
                    }
                    .font(.system(size: 12, weight: .black, design: .monospaced))
                    .foregroundColor(myPreviousVote != nil ? .neonCyan : .gray)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                }
                .buttonStyle(.plain)
            }
        }
        .background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(Color.cardBg)
                // ... overlay bordo ...
        )
        // ATTACCHIAMO LO SHEET ALLA VISTA
        .sheet(isPresented: $showFeedbackSheet) {
            let myUserId = Auth.auth().currentUser?.uid ?? ""
            let myPreviousVote = summary.receivedFeedbacks?[myUserId]
            
            // Scompattiamo onVote in una costante locale chiamata closure
            if let closure = onVote {
                FeedbackSelectionSheet(currentVote: myPreviousVote) { selectedAdjective in
                    closure(selectedAdjective)
                }
            }
        }
    }

    // MARK: - Avatar

    @ViewBuilder
    private var avatar: some View {
        ZStack {
            Circle()
                .fill(summary.color.opacity(0.15))
                .frame(width: 44, height: 44)

            AvatarKFImage(url: summary.profileImageUrl.flatMap(URL.init), size: 44) {
                fallbackAvatar
            }

            // Rank badge
            Circle()
                .fill(summary.color)
                .frame(width: 16, height: 16)
                .overlay(
                    Text("\(summary.displayIndex)")
                        .font(.system(size: 9, weight: .black, design: .monospaced))
                        .foregroundColor(.black)
                )
                .offset(x: 14, y: 14)
        }
        .frame(width: 44, height: 44)
    }

    private var fallbackAvatar: some View {
        let initials: String = {
            if let name = summary.userName, !name.isEmpty {
                let parts = name.split(separator: " ")
                let first = parts.first.map { String($0.prefix(1)) } ?? ""
                let last  = parts.dropFirst().first.map { String($0.prefix(1)) } ?? ""
                return (first + last).uppercased()
            }
            return "\(summary.displayIndex)"
        }()
        return Text(initials)
            .font(.system(size: initials.count == 1 ? 16 : 13, weight: .black, design: .monospaced))
            .foregroundColor(summary.color)
    }
}

// MARK: - Previews
// (Le preview sotto rimangono identiche e ora funzioneranno perché onVote è opzionale di default)

#Preview("Row — Pace activity (Running)") {
    VStack(spacing: 8) {
        ParticipantRowView(
            summary: ParticipantSummary(
                id: "u1", displayIndex: 1, elapsedSeconds: 3_245,
                metricsCreatorType: .creator, endedBeforeCreator: false,
                userName: "Ahmed Hussein", profileImageUrl: nil,
                totalDistanceKm: 10.2, avgPaceMinPerKm: 5.3, bestSplitPace: 4.9
            ), onTap: {}
        )
        ParticipantRowView(
            summary: ParticipantSummary(
                id: "u2", displayIndex: 2, elapsedSeconds: 3_512,
                metricsCreatorType: .normalParticipant, endedBeforeCreator: true,
                userName: "Sara M", profileImageUrl: nil,
                totalDistanceKm: 9.8, avgPaceMinPerKm: 5.9, bestSplitPace: 5.6
            ), onTap: {}
        )
        ParticipantRowView(
            summary: ParticipantSummary(
                id: "u3", displayIndex: 3, elapsedSeconds: 2_800,
                metricsCreatorType: .normalParticipant, endedBeforeCreator: false,
                userName: nil, profileImageUrl: nil,
                totalDistanceKm: 8.1, avgPaceMinPerKm: 5.8, bestSplitPace: 5.5
            ), onTap: {}
        )
    }
    .padding()
    .background(Color(.systemBackground))
    .preferredColorScheme(.dark)
}

#Preview("Row — Speed activity (Cycling)") {
    VStack(spacing: 8) {
        ParticipantRowView(
            summary: ParticipantSummary(
                id: "u1", displayIndex: 1, elapsedSeconds: 5_400,
                metricsCreatorType: .creator, endedBeforeCreator: false,
                userName: "Ahmed H", profileImageUrl: nil,
                totalDistanceKm: 32.5, avgSpeedKmH: 30.1, bestSplitSpeedKmH: 34.2
            ), onTap: {}
        )
        ParticipantRowView(
            summary: ParticipantSummary(
                id: "u2", displayIndex: 2, elapsedSeconds: 5_900,
                metricsCreatorType: .normalParticipant, endedBeforeCreator: false,
                userName: "Sara M", profileImageUrl: nil,
                totalDistanceKm: 28.3, avgSpeedKmH: 26.2, bestSplitSpeedKmH: 28.0
            ), onTap: {}
        )
    }
    .padding()
    .background(Color(.systemBackground))
    .preferredColorScheme(.dark)
}

#Preview("Row — Time-only activity (Gym)") {
    VStack(spacing: 8) {
        ParticipantRowView(
            summary: ParticipantSummary(
                id: "u1", displayIndex: 1, elapsedSeconds: 3_600,
                metricsCreatorType: .creator, endedBeforeCreator: false,
                userName: "Ahmed H", profileImageUrl: nil
            ), onTap: {}
        )
        ParticipantRowView(
            summary: ParticipantSummary(
                id: "u2", displayIndex: 2, elapsedSeconds: 2_850,
                metricsCreatorType: .normalParticipant, endedBeforeCreator: false,
                userName: nil, profileImageUrl: nil
            ), onTap: {}
        )
    }
    .padding()
    .background(Color(.systemBackground))
    .preferredColorScheme(.dark)
}
