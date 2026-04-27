//
//  ChatView.swift
//  sbud
//
//  Created by Riccardo Maria Cadario on 23/02/26.
//

import SwiftUI

struct ChatView: View {
    let user: UserProfile
    let eventId: String?
    @StateObject var viewModel: ChatViewModel
    @State var messageText: String = ""
    
    init(user: UserProfile, eventId: String? = nil) {
        self.user = user
        self.eventId = eventId
        self._viewModel = StateObject(wrappedValue: ChatViewModel(user: user, eventId: eventId))
    }
    
    var body: some View {
        VStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 12) {
                    ForEach(viewModel.messages) { message in
                        MessageView(viewModel: MessageViewModel(message: message))
                    }
                }
            }.padding(.top)
            
            CustomInputView(inputText: $messageText,
                            placeholder: "Message...",
                            buttonTitle: "Send",
                            action: sendMessage)
            
        }
        .navigationTitle(user.name)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar(.hidden, for: .tabBar)
    }
    
    func sendMessage() {
        viewModel.sendMessage(messageText)
        messageText = ""
    }
}
