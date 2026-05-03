//
//  ProfileInfoRow.swift
//  sbud
//
//  Created by ahmed on 01/05/2026.
//

import SwiftUI


struct ProfileInfoRow: View {
    let icon: String
    let label: String
    let value: String
 
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            Image(systemName: icon)
                .font(.system(size: 18))
                .foregroundColor(Color("turquoise"))
                .frame(width: 28, height: 28)
                .offset(y: 2)
 
            VStack(alignment: .leading, spacing: 2) {
                Text(label)
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.gray)
                Text(value.uppercased())
                    .font(.system(size: 14, weight: .bold, design: .monospaced))
                    .foregroundColor(.white)
            }
        }
    }
}
//
//#Preview {
//    ProfileInfoRow()
//}
