//
//  FilterSectionHeader.swift
//  sbud
//
//  Created by ahmed on 04/05/2026.
//

import SwiftUI

struct FilterSectionHeader: View {
    let title: String
    let icon: String

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 13, weight: .semibold))
                .foregroundStyle(Color.mainColor)
                .frame(width: 26, height: 26)
                .background(Color.mainColor.opacity(0.15))
                .clipShape(RoundedRectangle(cornerRadius: 8))

            Text(title)
                .font(.title)
                .foregroundStyle(.primary)
        }
    }
}
//#Preview {
//    FilterSectionHeader()
//}
