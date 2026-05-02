//
//  SectionHeader.swift
//  sbud
//
//  Created by ahmed on 02/05/2026.
//

import SwiftUI

struct SectionHeader: View {
    let title: String
    let accent: Color

    var body: some View {
        HStack(spacing: 8) {
            Rectangle()
                .fill(accent)
                .frame(width: 3, height: 14)
                .cornerRadius(2)
            Text(title)
                .font(.system(size: 11, weight: .black, design: .monospaced))
                .foregroundColor(accent.opacity(0.8))
                .tracking(2)
        }
        .padding(.top, 4)
    }
}

//
//#Preview {
//    SectionHeader()
//}
