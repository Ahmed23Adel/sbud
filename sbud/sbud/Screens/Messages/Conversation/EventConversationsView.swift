//
//  EventConversationsView.swift
//  sbud
//
//  Created by Riccardo Maria Cadario on 04/05/26.
//


import SwiftUI

struct EventConversationsView: View {
    let eventId: String
    let eventTitle: String
    @StateObject var viewModel: EventConversationsViewModel
    
    init(eventId: String, eventTitle: String) {
        self.eventId = eventId
        self.eventTitle = eventTitle
        _viewModel = StateObject(wrappedValue: EventConversationsViewModel(eventId: eventId))
    }
    
    var body: some View {
        ZStack {
            Color.darkBackground.ignoresSafeArea()
            
            
            ScrollView {
                if viewModel.recentMessages.isEmpty {
                    // EMPTY STAT
                    VStack(spacing: 16) {
                        Image(systemName: "tray")
                            .font(.system(size: 48))
                            .foregroundColor(.gray)
                        Text("No messages for this event yet.")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.gray)
                    }
                    
                    .frame(maxWidth: .infinity, minHeight: UIScreen.main.bounds.height * 0.6)
                    
                } else {
                    
                    LazyVStack(spacing: 0) {
                        ForEach(viewModel.recentMessages) { message in
                            if let user = message.user {
                                NavigationLink(destination: ChatView(user: user, eventId: eventId, eventTitle: eventTitle)) {
                                    ConversationCell(message: message, user: user)
                                }
                            }
                        }
                    }
                    .padding(.top)
                }
            }
            
            .refreshable {
                viewModel.loadData()
            }
        }
        .navigationTitle("Chats: \(eventTitle)")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.darkBackground, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .onAppear {
            viewModel.loadData()
        }
    }
}
