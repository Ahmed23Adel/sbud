//
//  TextModifierSignUp.swift
//  sbud
//
//  Created by Riccardo Maria Cadario on 14/12/25.
//

import SwiftUI

struct TextModifierSignUp: ViewModifier {
    func body(content: Content) -> some View {
        content
            .font(.subheadline)
            .padding()
            .background(Color(.systemGray5))
            .cornerRadius(11)
            .padding(.horizontal, 20)
    }
}
