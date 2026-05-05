//
//  ProfileAvatarView.swift
//  sbud
//
//  Created by ahmed on 01/05/2026.
//

import SwiftUI
import Kingfisher

struct ProfileAvatarView: View {
    let imageUrl: String?
 
    var body: some View {
        ZStack {
            Circle()
                .stroke(Color("turquoise").opacity(0.5), lineWidth: 2)
                .frame(width: 120, height: 120)
                .shadow(color: Color("turquoise").opacity(0.3), radius: 10)
 
            Group {
                if let urlStr = imageUrl, let url = URL(string: urlStr) {
                    KFImage(url)
                        .resizable()
                        .scaledToFill()
                } else {
                    Image(systemName: "person.fill")
                        .resizable()
                        .scaledToFit()
                        .padding(30)
                        .foregroundColor(.gray)
                }
            }
            .frame(width: 110, height: 110)
            .clipShape(Circle())
        }
        .padding(.bottom, 10)
    }
}
//
//#Preview {
//    ProfileAvatarView()
//}
