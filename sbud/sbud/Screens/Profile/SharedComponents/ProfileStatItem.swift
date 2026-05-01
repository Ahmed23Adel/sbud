//
//  ProfileStatItem.swift
//  sbud
//
//  Created by ahmed on 01/05/2026.
//

import SwiftUI

struct ProfileStatItem: View {
    let value: String
    let label: String
 
    var body: some View {
        VStack(spacing: 5) {
            Text(value)
                .font(.system(size: 18, weight: .bold, design: .monospaced))
                .foregroundColor(.white)
            Text(label)
                .font(.system(size: 8, weight: .bold, design: .monospaced))
                .foregroundColor(.gray)
                .kerning(1)
        }
        .frame(maxWidth: .infinity)
    }
}
//
//#Preview {
//    ProfileStatItem()
//}
