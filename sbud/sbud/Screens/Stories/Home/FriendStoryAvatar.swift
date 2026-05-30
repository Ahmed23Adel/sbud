//
//  FriendStoryAvatar.swift
//  sbud
//

import SwiftUI
import Kingfisher

struct FriendStoryAvatar: View {
    let friend: FriendWithStories
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            VStack(spacing: 6) {
                avatarRing
                Text(friend.name.components(separatedBy: " ").first ?? friend.name)
                    .font(.caption2)
                    .foregroundStyle(.white)
                    .lineLimit(1)
            }
        }
        .buttonStyle(.plain)
    }

    private var avatarRing: some View {
        ZStack {
            Circle()
                .stroke(
                    LinearGradient(
                        colors: [Color.mainColor, Color.blueColor],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    lineWidth: 2.5
                )
                .frame(width: 68, height: 68)
            avatarImage
                .frame(width: 60, height: 60)
                .clipShape(Circle())
        }
    }

    @ViewBuilder
    private var avatarImage: some View {
        if let urlString = friend.profileImageUrl, let url = URL(string: urlString) {
            KFImage(url)
                .resizable()
                .scaledToFill()
        } else {
            Circle()
                .fill(Color.blueColor.opacity(0.3))
                .overlay {
                    Image(systemName: "person.fill")
                        .foregroundStyle(Color.blueColor)
                }
        }
    }
}

#Preview {
    ZStack {
        Color.darkBackground.ignoresSafeArea()
        HStack(spacing: 16) {
            FriendStoryAvatar(
                friend: FriendWithStories(id: "1", name: "Ahmed Adel", profileImageUrl: nil, stories: []),
                onTap: {}
            )
            FriendStoryAvatar(
                friend: FriendWithStories(id: "2", name: "Sara", profileImageUrl: nil, stories: []),
                onTap: {}
            )
        }
    }
}
