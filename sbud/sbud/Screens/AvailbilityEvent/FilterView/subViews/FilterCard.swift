//
//  FilterCard.swift
//  sbud
//
//  Created by ahmed on 04/05/2026.
//

import SwiftUI


struct FilterCard<Content: View>: View {
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            content
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 20)
        .background(Color.backgroundColor.opacity(0.55))
        .cornerRadius(28)
        .overlay(
            RoundedRectangle(cornerRadius: 28)
                .stroke(Color.white.opacity(0.15), lineWidth: 1)
        )
        .popUp()
    }
}
//
//#Preview {
//    FilterCard()
//}
