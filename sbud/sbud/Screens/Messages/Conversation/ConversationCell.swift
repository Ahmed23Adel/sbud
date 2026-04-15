//
//  ConversationCell.swift
//  sbud
//
//  Created by Riccardo Maria Cadario on 23/02/26.
//

import SwiftUI
import Kingfisher

struct ConversationCell: View {
    let message: Message
    var user: User?
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack(spacing: 12) {
                if let imageUrl = user?.profileImageUrl, !imageUrl.isEmpty, let url = URL(string: imageUrl) {
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
                
                VStack(alignment: .leading, spacing: 4) {
                    if let user = message.user {
                        Text(user.email ?? user.username)
                            .font(.system(size: 14, weight: .semibold))
                    }
                    
                    Text(message.text)
                        .font(.system(size: 15))
                        .lineLimit(2)
                    
                }
                .padding(.trailing)
                
                Spacer()
            }
            
            Divider()
        }
        
    }
}
