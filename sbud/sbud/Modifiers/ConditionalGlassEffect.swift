//
//  ConditionalGlassEffect.swift
//  sbud
//
//  Created by ahmed on 27/12/2025.
//

import SwiftUI

struct ConditionalGlassEffect: ViewModifier {
    func body(content: Content) -> some View{
        if #available(iOS 26.0, *) {
            content
                .glassEffect()
        } else {
            content
        }
    }
    
}

extension View {
    func conditionalGlassEffect() -> some View {
        modifier(ConditionalGlassEffect())
    }
}

