//
//  ChatView.swift
//  sbud
//
//  Created by Riccardo Maria Cadario on 04/05/26.
//


//
//  ChatView.swift
//  sbud
//
//  Created by Riccardo Maria Cadario on 23/02/26.
//

import SwiftUI

struct ChatView: View {
    let user: UserProfile
    let eventId: String
    let eventTitle: String
    @StateObject var viewModel: ChatViewModel
    @State var messageText: String = ""
    
    init(user: UserProfile, eventId: String, eventTitle: String) {
        self.user = user
        self.eventId = eventId
        self.eventTitle = eventTitle
        self._viewModel = StateObject(wrappedValue: ChatViewModel(user: user, eventId: eventId))
    }
    
    var body: some View {
        ZStack {
            Color.darkBackground.ignoresSafeArea()
            
            VStack {
                
                ScrollViewReader { proxy in
                    ScrollView {
                        VStack(alignment: .leading, spacing: 12) {
                            ForEach(viewModel.messages) { message in
                                MessageView(viewModel: MessageViewModel(message: message), user: user)
                                    .id(message.id)
                            }
                        }
                        .padding(.top)
                    }
                    
                    .onChange(of: viewModel.messages.count) { _ in
                        if let lastMessageId = viewModel.messages.last?.id {
                            withAnimation {
                                proxy.scrollTo(lastMessageId, anchor: .bottom)
                            }
                        }
                    }
                   
                    .onReceive(viewModel.$messages) { messages in
                        if let lastMessageId = messages.last?.id {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                                proxy.scrollTo(lastMessageId, anchor: .bottom)
                            }
                        }
                    }
                }
                
                CustomInputView(inputText: $messageText,
                                placeholder: "Message...",
                                buttonTitle: "Send",
                                action: sendMessage)
                .background(Color.darkBackground)
            }
        }
        .navigationTitle("\(user.name) • \(eventTitle)")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar)
        .toolbarBackground(Color.darkBackground, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .onAppear {
            viewModel.markMessagesAsRead() 
        }
    }
    
    func sendMessage() {
        
        guard !messageText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        viewModel.sendMessage(messageText)
        messageText = ""
    }
}
