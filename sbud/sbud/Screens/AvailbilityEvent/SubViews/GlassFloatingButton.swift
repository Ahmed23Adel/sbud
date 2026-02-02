//
//  GlassFloatingButton.swift
//  sbud
//
//  Created by ahmed on 27/12/2025.
//

import SwiftUI

struct GlassFloatingButton: View {
    let systemName: String
    let action: () -> Void
    var body: some View {
        Button(action: action) {
            Image(systemName: systemName)
                .font(.title2)
                .fontWeight(.semibold)
                .foregroundStyle(.primary)
                .frame(width: 56, height: 56)
                .background(.ultraThinMaterial)
                .clipShape(Circle())
                .overlay(
                    Circle()
                        .stroke(.white.opacity(0.2), lineWidth: 0.5)
                )
                .shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: 5)
                .conditionalGlassEffect()
                .popUp()
        }

    }
}
//
// #Preview {
//    GlassFloatingButton()
// }
