//
//  ProfileMyEventsButton.swift
//  sbud
//
//  Created by ahmed on 01/05/2026.
//

import SwiftUI

struct ProfileMyEventsButton: View {
    let userId: String
    let title: String
    let onViewAll: () -> Void
    

    var body: some View {
        HStack {
            Text("MY EVENTS")
                .font(.system(size: 15, weight: .black))
                .foregroundColor(.white)
                .kerning(1.5)
            Spacer()
            Button(action: onViewAll) {
                Text("VIEW ALL")
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundColor(Color("turquoise"))
            }
        }
        .padding(20)
        .background(Color(white: 0.07))
        .clipShape(Rectangle())
        .padding(.horizontal, 16)
        .cornerRadius(4)
    }
}
//
//#Preview {
//    ProfileMyEventsButton()
//}
