//
//  DestructiveButtonStyle.swift
//  sbud
//
//  Created by ahmed on 15/05/2026.
//

import SwiftUI

struct DestructiveButton: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 17, weight: .heavy))
            .foregroundColor(.white)
            .frame(maxWidth: .infinity)
            .frame(height: 68)
            .background(Color(red: 244/255, green: 55/255, blue: 73/255))
            .clipShape(Capsule())
            .padding()
            .opacity(configuration.isPressed ? 0.8 : 1.0)
    }
}
