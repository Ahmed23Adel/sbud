//
//  Components.swift
//  sbud
//
//  Created by Erdal on 24.03.2026.
//

import SwiftUI

@ViewBuilder
func customTextField(title: String, placeholder: String, text: Binding<String>) -> some View {
    VStack(alignment: .leading, spacing: 8) {
        Text(title)
            .font(.system(size: 12, weight: .bold)).foregroundColor(Color.gray).kerning(1.2)
            
        
        TextField("", text: text, prompt:
            Text(placeholder)
                .foregroundColor(Color.white.opacity(0.2))
                .font(.system(size: 24, weight: .bold))
        )
        .padding()
        .frame(height: 60)
        .background(Color.white.opacity(0.08))
        .foregroundColor(.white)
        .cornerRadius(4)
    }
}
