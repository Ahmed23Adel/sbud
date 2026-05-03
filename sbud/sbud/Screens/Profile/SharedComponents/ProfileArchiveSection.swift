//
//  ProfileArchiveSection.swift
//  sbud
//
//  Created by ahmed on 01/05/2026.
//

import SwiftUI


struct ProfileArchiveSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            HStack {
                Text("ARCHIVE HISTORY")
                    .font(.system(size: 15, weight: .black))
                    .foregroundColor(.white)
                Spacer()
                Text("VIEW ALL")
                    .font(.system(size: 10, weight: .bold, design: .monospaced))
                    .foregroundColor(Color("turquoise"))
            }
 
            Text("No activity history yet.")
                .font(.system(size: 12, design: .monospaced))
                .foregroundColor(.gray)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 30)
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
//    ProfileArchiveSection()
//}
