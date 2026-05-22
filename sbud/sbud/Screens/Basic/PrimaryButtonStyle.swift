//
//  PrimaryButtonStyle.swift
//  sbud
//
//  Created by ahmed on 15/05/2026.
//

import SwiftUI

struct PrimaryButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 17, weight: .heavy))
            .foregroundColor(.black)
            .frame(maxWidth: .infinity)
            .frame(height: 68)
            .background(Color.mainColor)
            .clipShape(Capsule())
            .padding()
            .opacity(configuration.isPressed ? 0.8 : 1.0)
    }
}
