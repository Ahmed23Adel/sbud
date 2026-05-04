//
//  ConversationCell.swift
//  sbud
//
//  Created by Riccardo Maria Cadario on 04/05/26.
//


import SwiftUI
import Kingfisher

struct ConversationCell: View {
    let message: Message
    let user: UserProfile
    
    var body: some View {
        VStack(spacing: 0) {
            HStack(spacing: 12) {
                
                if let imageUrl = user.profileImageUrl, !imageUrl.isEmpty, let url = URL(string: imageUrl) {
                    KFImage(url)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 52, height: 52)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.mainColor, lineWidth: 1.5))
                } else {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .frame(width: 52, height: 52)
                        .foregroundColor(Color.backgroundColor)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    
                    Text("\(user.name) \(user.surName)")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                    
                    //last messages
                    Text(message.text)
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                        .lineLimit(2)
                        .multilineTextAlignment(.leading)
                }
                
                Spacer()
                
                
                Image(systemName: "chevron.right")
                    .foregroundColor(Color.mainColor)
                    .font(.system(size: 14, weight: .bold))
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 12)
            
            
            Divider()
                .background(Color.backgroundColor)
                .padding(.leading, 80)
        }
        .background(Color.darkBackground)
    }
}
