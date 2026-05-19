//
//  CapacityBadge.swift
//  sbud
//
//  Created by ahmed on 15/05/2026.
//

import SwiftUI

struct CapacityBadge: View {
    var max: Int
    var body: some View {
        HStack(spacing: 4) {
            Image(systemName: "person.2").font(.system(size: 9))
            Text("Max \(max)").font(.system(size: 10))
        }
        .foregroundColor(.black)
        .padding(.vertical, 5).padding(.horizontal, 10)
        .background(Color.yellow.opacity(0.8))
        .clipShape(RoundedRectangle(cornerRadius: UIConstants.cornerRadius))
    }
}
//
//#Preview {
//    CapacityBadge()
//}
