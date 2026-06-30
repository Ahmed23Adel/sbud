//
//  AthleteFeedbackSection.swift
//  sbud
//
//  Created by Riccardo Maria Cadario on 27/05/2026.
//
import SwiftUI

struct AthleteFeedbackSection: View {
    let isOwnProfile: Bool
    let topFeedbacks: [(tag: String, count: Int)]

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            Text("ATHLETE FEEDBACK")
                .font(.system(size: 18, weight: .black))
                .foregroundColor(.white)
            
            if topFeedbacks.isEmpty {
                Text("No feedback received yet.")
                    .font(.system(size: 12, design: .monospaced))
                    .foregroundColor(.gray)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding(.vertical, 10)
            } else {
                FlowLayout(spacing: 12) {
                    ForEach(topFeedbacks, id: \.tag) { item in
                        // Assegna un colore coerente basato sul nome dell'aggettivo
                        let chipColor = colorForAdjective(item.tag)
                        
                        HStack(spacing: 6) {
                            Text("#\(item.tag)")
                                .font(.system(size: 13, weight: .heavy, design: .rounded))
                            Text("x\(item.count)")
                                .font(.system(size: 12, weight: .bold, design: .monospaced))
                                .opacity(0.8)
                        }
                        .foregroundColor(.white.opacity(0.9))
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(chipColor)
                        .clipShape(Capsule())
                        .overlay(
                            Capsule().stroke(Color.white.opacity(0.1), lineWidth: 1)
                        )
                    }
                }
            }
        }
        .padding(20)
        .background(Color(white: 0.07))
        .cornerRadius(8)
        .padding(.horizontal, 16)
    }
    
    // Funzione di supporto per dare colori fighi e sportivi ai tag nel profilo
    private func colorForAdjective(_ tag: String) -> Color {
        let palette: [Color] = [
            Color(red: 0.13, green: 0.20, blue: 0.30), // Blu scuro
            Color(red: 0.23, green: 0.05, blue: 0.45), // Viola
            Color(red: 0.05, green: 0.35, blue: 0.25), // Verde smeraldo
            Color(red: 0.35, green: 0.10, blue: 0.05), // Rosso scuro
            Color(red: 0.05, green: 0.20, blue: 0.50)  // Cobalto
        ]
        let index = abs(tag.hashValue) % palette.count
        return palette[index]
    }
}
