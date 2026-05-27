//
//  AthleteFeedbackSection.swift
//  sbud
//
//  Created by Riccardo Maria Cadario on 27/05/2026.
//
import SwiftUI

// Configurazione base dei tag disponibili nell'app
struct FeedbackConfig: Identifiable {
    var id: String { name }
    let name: String
    let color: Color
}

let allFeedbackOptions: [FeedbackConfig] = [
    FeedbackConfig(name: "FRIENDLY", color: Color(red: 0.13, green: 0.20, blue: 0.30)),
    FeedbackConfig(name: "TALKATIVE", color: Color(red: 0.23, green: 0.05, blue: 0.45)),
    FeedbackConfig(name: "EXTROVERT", color: Color(red: 0.05, green: 0.35, blue: 0.25)),
    FeedbackConfig(name: "SHY", color: Color(red: 0.35, green: 0.10, blue: 0.05)),
    FeedbackConfig(name: "TEAM_PLAYER", color: Color(red: 0.05, green: 0.20, blue: 0.50))
]

struct AthleteFeedbackSection: View {
    let isOwnProfile: Bool
    let currentUserId: String
    let feedbackVoters: [String: [String]]
    let onVote: (String) -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("ATHLETE FEEDBACK")
                .font(.system(size: 18, weight: .black))
                .foregroundColor(.white)
            
            FlowLayout(spacing: 12) {
                ForEach(allFeedbackOptions) { option in
                    // Ora leggiamo l'array
                    let votersForTag = feedbackVoters[option.name] ?? []
                    let currentCount = votersForTag.count
                    let hasVoted = votersForTag.contains(currentUserId)
                    
                    Button {
                        guard !isOwnProfile, !hasVoted else { return }
                        
                        let generator = UIImpactFeedbackGenerator(style: .medium)
                        generator.impactOccurred()
                        onVote(option.name)
                        
                    } label: {
                        Text("#\(option.name)" + (currentCount > 0 ? "x\(currentCount)" : ""))
                            .font(.system(size: 13, weight: .heavy, design: .rounded))
                            // Se hai già votato, il tag diventa leggermente più scuro/disattivato
                            .foregroundColor(.white.opacity(isOwnProfile || hasVoted ? 0.6 : 0.9))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 10)
                            .background(option.color)
                            .clipShape(Capsule())
                            .overlay(
                                Capsule().stroke(
                                    hasVoted ? Color("turquoise") : Color.white.opacity(0.1),
                                    lineWidth: hasVoted ? 2 : 1
                                )
                            )
                    }
                    .buttonStyle(.plain)
                    .disabled(isOwnProfile || hasVoted)
                }
            }
        }
        .padding(20)
        .background(Color(white: 0.07))
        .cornerRadius(8)
        .padding(.horizontal, 16)
    }
}
