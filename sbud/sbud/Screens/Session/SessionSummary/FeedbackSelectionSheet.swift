//
//  FeedbackSelectionSheet.swift
//  sbud
//
//  Created by Riccardo Maria Cadario on 29/06/2026.
//


import SwiftUI

struct FeedbackSelectionSheet: View {
    let currentVote: String?
    let onSelect: (String) -> Void
    
    @Environment(\.dismiss) private var dismiss
    
    
    let availableAdjectives = [
        "BEAST", "FAST", "MOTIVATOR", "LEADER", "FRIENDLY",
        "UNSTOPPABLE", "CONSISTENT", "HELPFUL", "DETERMINED",
        "ENERGIZER", "FOCUSED", "RESILIENT", "MACHINE", "SUPPORTIVE", "TALKATIVE"
    ]
    
    var body: some View {
        NavigationStack {
            List {
                ForEach(availableAdjectives, id: \.self) { adjective in
                    Button {
                        let generator = UIImpactFeedbackGenerator(style: .medium)
                        generator.impactOccurred()
                        
                        onSelect(adjective)
                        dismiss() // Chiude la tendina
                    } label: {
                        HStack {
                            Text(adjective)
                                .font(.system(size: 16, weight: .bold, design: .monospaced))
                                .foregroundColor(currentVote == adjective ? .neonCyan : .primary)
                            
                            Spacer()
                            
                            
                            if currentVote == adjective {
                                Image(systemName: "checkmark")
                                    .foregroundColor(.neonCyan)
                                    .fontWeight(.bold)
                            }
                        }
                    }
                    .listRowBackground(Color.cardBg)
                }
            }
            .navigationTitle("Rate Teammate")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(.gray)
                }
            }
        }
        .presentationDetents([.medium, .large]) 
    }
}
