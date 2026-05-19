//
//  AccentDivider.swift
//  sbud
//
//  Created by ahmed on 17/05/2026.
//

import SwiftUI

struct AccentDivider: View {
    var body: some View {
        LinearGradient(
            colors: [.clear, .neonCyan.opacity(0.45), .neonGreen.opacity(0.25), .clear],
            startPoint: .leading,
            endPoint: .trailing
        )
        .frame(height: 1)
        .padding(.horizontal, 32)
    }
}

#Preview {
    AccentDivider()
}
