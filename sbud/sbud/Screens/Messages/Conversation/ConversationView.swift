//
//  ConversationView.swift
//  sbud
//
//  Created by Riccardo Maria Cadario on 23/02/26.
//

import SwiftUI

struct ConversationsView: View {
    @State var isShowingNewMessageView = false
    @State var showChat = false
    @State var user: User?
    @StateObject var viewModel = ConversationsViewModel()
    
    var body: some View {
        ScrollView {
            LazyVStack {
                ForEach(viewModel.recentMessages) { message in
                    NavigationLink {
                        if let user = message.user {
                            ChatView(user: user)
                        }
                    } label: {
                        ConversationCell(message: message)
                    }
                }
            }.padding()
        }
        .navigationTitle("Messages")
        .navigationBarTitleDisplayMode(.inline)
        .fullScreenCover(isPresented: $isShowingNewMessageView, content: {
            NewMessageView(startChat: $showChat, user: $user)
        })
        .toolbar(content: {
            Button {
                isShowingNewMessageView.toggle()
            } label: {
                Image(systemName: "square.and.pencil")
                    .imageScale(.large)
                    //.foregroundColor(Color.theme.systemBackground)
            }
            
        })
        .onAppear {
            viewModel.loadData()
        }
        .navigationDestination(isPresented: $showChat) {
            if let user = user {
                ChatView(user: user)
            }
        }
    }
}

