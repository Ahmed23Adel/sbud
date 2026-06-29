//
//  StoryReactionBar.swift
//  sbud
//

import SwiftUI

struct StoryReactionBar: View {
    let myReaction: String?
    let onReact: (String?) -> Void

    private let emojis = ["🔥", "💪", "❤️", "👏", "😍"]

    var body: some View {
        HStack(spacing: 16) {
            ForEach(emojis, id: \.self) { emoji in
                Button {
                    onReact(myReaction == emoji ? nil : emoji)
                } label: {
                    Text(emoji)
                        .font(.system(size: 28))
                        .scaleEffect(myReaction == emoji ? 1.25 : 1.0)
                        .animation(.spring(response: 0.3), value: myReaction)
                        .padding(6)
                        .background(
                            Circle()
                                .fill(myReaction == emoji
                                      ? Color.mainColor.opacity(0.25)
                                      : Color.white.opacity(0.1))
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.vertical, 24)
        .padding(.horizontal, 20)
        .fixedSize()
    }
}

#Preview("No reaction") {
    ZStack {
        Color.black.ignoresSafeArea()
        StoryReactionBar(myReaction: nil) { _ in }
    }
}

#Preview("With reaction") {
    ZStack {
        Color.black.ignoresSafeArea()
        StoryReactionBar(myReaction: "🔥") { _ in }
    }
}
