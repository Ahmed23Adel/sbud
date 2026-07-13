//
//  EventConversationsView.swift
//  sbud
//
//  Created by Riccardo Maria Cadario on 04/05/26.
//


import SwiftUI
import Kingfisher

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
                if viewModel.messageableParticipants.isEmpty && viewModel.recentMessages.isEmpty {
                    emptyState
                } else {
                    VStack(spacing: 0) {
                        if !viewModel.messageableParticipants.isEmpty {
                            participantsStrip
                        }
                        if !viewModel.recentMessages.isEmpty {
                            conversationsList
                        }
                    }
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

    // MARK: - Subviews

    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "tray")
                .font(.system(size: 48))
                .foregroundColor(.gray)
            Text("No participants to message yet.")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, minHeight: UIScreen.main.bounds.height * 0.6)
    }

    /// Tappable avatars of every confirmed participant (except the creator).
    private var participantsStrip: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Message a participant")
                .font(.system(size: 13, weight: .semibold))
                .foregroundColor(.gray)
                .padding(.horizontal, 16)
                .padding(.top, 16)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(alignment: .top, spacing: 16) {
                    ForEach(viewModel.messageableParticipants) { participant in
                        NavigationLink(destination: ChatView(user: participant, eventId: eventId, eventTitle: eventTitle)) {
                            participantAvatar(participant)
                        }
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
            }

            Divider()
                .background(Color.backgroundColor)
        }
    }

    private func participantAvatar(_ user: UserProfile) -> some View {
        VStack(spacing: 6) {
            ZStack(alignment: .bottomTrailing) {
                if let imageUrl = user.profileImageUrl, !imageUrl.isEmpty, let url = URL(string: imageUrl) {
                    KFImage(url)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 56, height: 56)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.mainColor, lineWidth: 1.5))
                } else {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .frame(width: 56, height: 56)
                        .foregroundColor(Color.backgroundColor)
                }

                Image(systemName: "plus.circle.fill")
                    .font(.system(size: 18))
                    .foregroundColor(Color.mainColor)
                    .background(Circle().fill(Color.darkBackground))
            }

            Text(user.name)
                .font(.caption)
                .foregroundColor(.white)
                .lineLimit(1)
                .frame(width: 64)
        }
    }

    private var conversationsList: some View {
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
