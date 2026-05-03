//
//  ProfilePageIndicator.swift
//  sbud
//
//  Created by ahmed on 01/05/2026.
//

import SwiftUI


struct ProfilePageIndicator: View {
    let currentPage: Int
    let pageCount: Int
 
    var body: some View {
        HStack(spacing: 8) {
            ForEach(0..<pageCount, id: \.self) { index in
                Circle()
                    .fill(currentPage == index ? Color("palelime") : Color.gray.opacity(0.5))
                    .frame(width: 6, height: 6)
            }
        }
    }
}
//
//#Preview {
//    ProfilePageIndicator()
//}
