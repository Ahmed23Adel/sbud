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
            
            // 1. La ScrollView ORA avvolge tutto, in modo da poter sempre tirare giù
            ScrollView {
                if viewModel.recentMessages.isEmpty {
                    // STATO VUOTO
                    VStack(spacing: 16) {
                        Image(systemName: "tray")
                            .font(.system(size: 48))
                            .foregroundColor(.gray)
                        Text("No messages for this event yet.")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.gray)
                    }
                    // 2. Fondamentale: diamo un'altezza minima per permettere il drag
                    .frame(maxWidth: .infinity, minHeight: UIScreen.main.bounds.height * 0.6)
                    
                } else {
                    // STATO PIENO
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
            // 3. Il refreshable ora è applicato SEMPRE, indipendentemente dai messaggi
            .refreshable {
                await viewModel.loadData()
            }
        }
        .navigationTitle("Chats: \(eventTitle)")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color.darkBackground, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .task {
            // task assicura che il ViewModel carichi i dati appena apri la pagina
            await viewModel.loadData()
        }
    }
}
