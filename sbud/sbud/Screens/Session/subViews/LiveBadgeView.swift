//
//  LiveBadgeView.swift
//  sbud
//
//  Created by ahmed on 17/05/2026.
//

import SwiftUI

struct LiveBadgeView: View {
    @State private var pulsing = false

    var body: some View {
        HStack(spacing: 5) {
            Circle()
                .fill(Color.neonPink)
                .frame(width: 6, height: 6)
                .shadow(color: .neonPink, radius: pulsing ? 4 : 1)
                .scaleEffect(pulsing ? 1.2 : 1.0)
                .animation(.easeInOut(duration: 0.9).repeatForever(autoreverses: true), value: pulsing)

            Text("LIVE")
                .font(.system(size: 9, weight: .black, design: .monospaced))
                .tracking(1.5)
                .foregroundColor(.neonPink)
        }
        .padding(.horizontal, 9)
        .padding(.vertical, 5)
        .background(Color.neonPink.opacity(0.1))
        .clipShape(Capsule())
        .overlay(Capsule().strokeBorder(Color.neonPink.opacity(0.35), lineWidth: 0.5))
        .onAppear { pulsing = true }
    }
}



#Preview {
    LiveBadgeView()
}
