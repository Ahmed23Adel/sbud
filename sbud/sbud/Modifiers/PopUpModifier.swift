//
//  PopUpModifier.swift
//  sbud
//
//  Created by ahmed on 10/12/2025.
//
// PopUpModifier.swift
import SwiftUI

struct PopUpModifier: ViewModifier {
    let delay: Double
    @State private var isVisible = false

    func body(content: Content) -> some View {
        content
            .scaleEffect(isVisible ? 1.0 : 0.0)
            .opacity(isVisible ? 1.0 : 0.0)
            .onAppear {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.6).delay(delay)) {
                    isVisible = true
                }
            }
    }
}

// Extension to make it easy to use
extension View {
    func popUp(delay: Double = 0.0) -> some View {
        modifier(PopUpModifier(delay: delay))
    }
}
