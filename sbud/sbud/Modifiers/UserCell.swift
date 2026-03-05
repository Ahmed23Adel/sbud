//
//  UserCell.swift
//  sbud
//
//  Created by Riccardo Maria Cadario on 03/03/26.
//

import SwiftUI
import Kingfisher

struct UserCell: View {
    let user: User
    
    var body: some View {
        HStack(spacing: 12) {
            if let imageUrl = user.profileImageUrl, !imageUrl.isEmpty, let url = URL(string: imageUrl) {
                KFImage(url)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 48, height: 48)
                    .clipShape(Circle())
            } else {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .frame(width: 48, height: 48)
                    .foregroundColor(Color(.systemGray4))
            }
            
            VStack(alignment: .leading) {
                Text(user.username)
                    .font(.system(size: 14, weight: .semibold))
                
                if let fullname = user.fullname {
                    Text(fullname)
                        .font(.system(size: 14))
                }
            }
            
            Spacer()
        }
    }
}

