//
//  ProfileMetricItem.swift
//  sbud
//
//  Created by ahmed on 01/05/2026.
//

import SwiftUI


struct ProfileMetricItem: View {
    let label: String
    let value: String
    let color: Color
 
    var body: some View {
        VStack(alignment: .leading, spacing: 5) {
            Text(label)
                .font(.system(size: 9, weight: .bold, design: .monospaced))
                .foregroundColor(.gray)
                .kerning(1)
            Text(value)
                .font(.system(size: 36, weight: .black, design: .monospaced))
                .foregroundColor(color)
        }
    }
}
//
//#Preview {
//    ProfileMetricItem()
//}
