//
//  MessageView.swift
//  sbud
//
//  Created by Riccardo Maria Cadario on 04/05/26.
//


//
//  MessageView.swift
//  sbud
//
//  Created by Riccardo Maria Cadario on 23/02/26.
//

import SwiftUI
import Foundation
import Kingfisher
import Firebase

struct MessageView: View {
    let viewModel: MessageViewModel
    @State private var isOfferAccepted = false
    @State private var isAcceptingOffer = false
    var user: UserProfile?
    
    var body: some View {
        HStack {
            if viewModel.isFromCurrentUser {
                Spacer()
                
                    Text(viewModel.message.text)
                        .font(.system(size: 15))
                        .padding(10)
                        .background(Color.mainColor)
                        .clipShape(ChatBubble(isFromCurrentUser: true))
                        .foregroundColor(.black)
                        .padding(.leading, 100)
                        .padding(.trailing)
                
            } else {
                HStack(alignment: .bottom) {
                    if let imageUrl = user?.profileImageUrl, !imageUrl.isEmpty, let url = URL(string: imageUrl) {
                        KFImage(url)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 36, height: 36)
                            .clipShape(Circle())
                    } else {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .frame(width: 36, height: 36)
                            .foregroundColor(Color(.systemGray4))
                    }
                    
                        Text(viewModel.message.text)
                            .font(.system(size: 15))
                            .padding(10)
                            .background(Color.backgroundColor)
                            .clipShape(ChatBubble(isFromCurrentUser: false))
                            .foregroundColor(.white)
                }
                .padding(.trailing, 100)
                .padding(.leading)
                
                Spacer()
            }
            
        }
    }
}