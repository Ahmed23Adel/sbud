//
//  SessionSelectorView.swift
//  sbud
//
//  Created by ahmed on 24/05/2026.
//

import SwiftUI
import MapKit

struct SessionSelectorView: View {
    let sessions: [SessionHistoryEntry]
    @Binding var selectedIndex: Int

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(sessions) { session in
                    let isSelected = session.id == selectedIndex
                    Button {
                        withAnimation(.spring(response: 0.3)) {
                            selectedIndex = session.id
                        }
                    } label: {
                        VStack(alignment: .leading, spacing: 2) {
                            Text("SESSION \(session.id + 1)")
                                .font(.system(size: 9, weight: .black, design: .monospaced))
                                .tracking(1.5)
                                .foregroundColor(isSelected ? .black : .labelGray)

                            Text(session.startDateTime.formatted(date: .abbreviated, time: .shortened))
                                .font(.system(size: 10, weight: .medium, design: .monospaced))
                                .foregroundColor(isSelected ? .black.opacity(0.7) : .labelGray.opacity(0.7))
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .fill(isSelected ? Color.neonCyan : Color.cardBg)
                        )
                        .overlay(
                            RoundedRectangle(cornerRadius: 10, style: .continuous)
                                .strokeBorder(
                                    isSelected ? Color.clear : Color.neonCyan.opacity(0.2),
                                    lineWidth: 1
                                )
                        )
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
        }
        .background(Color.surfaceBg)
    }
}
