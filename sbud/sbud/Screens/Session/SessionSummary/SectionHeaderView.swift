//
//  SectionHeaderView.swift
//  sbud
//
//  Created by ahmed on 24/05/2026.
//

import SwiftUI


struct SectionHeaderView: View {
    let title: String
    let icon: String
    var accentColor: Color = .neonCyan

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(accentColor)

            Text(title.uppercased())
                .font(.system(size: 11, weight: .black, design: .monospaced))
                .tracking(2)
                .foregroundColor(.white)

            Rectangle()
                .fill(accentColor.opacity(0.3))
                .frame(height: 1)
        }
    }
}

