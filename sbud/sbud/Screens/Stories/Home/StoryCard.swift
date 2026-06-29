//
//  StoryCard.swift
//  sbud
//

import SwiftUI
import Kingfisher

struct StoryCard: View {
    let card: MyStoryImageCard

    @State private var captionVisible = false

    var body: some View {
        ZStack(alignment: .bottom) {
            KFImage(URL(string: card.imageUrl))
                .resizable()
                .scaledToFill()
                .frame(width: 260, height: 300)
                .clipped()

            // Gradient scrim so text is always readable
            LinearGradient(
                colors: [.clear, .black.opacity(0.65)],
                startPoint: .center,
                endPoint: .bottom
            )

            // Floating reaction emojis
            if !card.reactions.isEmpty {
                FloatingReactions(emojis: Array(Set(card.reactions.values)).prefix(5).map { $0 })
            }

            // Animated caption
            if let caption = card.caption {
                Text(caption)
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(.white)
                    .lineLimit(2)
                    .padding(.horizontal, 12)
                    .padding(.bottom, 14)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .offset(y: captionVisible ? 0 : 20)
                    .opacity(captionVisible ? 1 : 0)
                    .animation(.spring(response: 0.5, dampingFraction: 0.7).delay(0.15), value: captionVisible)
            }
        }
        .frame(width: 260, height: 300)
        .clipShape(RoundedRectangle(cornerRadius: 20, style: .continuous))
        .shadow(color: .black.opacity(0.4), radius: 12, x: 0, y: 6)
        .onAppear { captionVisible = true }
        .onDisappear { captionVisible = false }
    }
}

// MARK: - Floating reaction emojis

private struct FloatingReactions: View {
    let emojis: [String]

    var body: some View {
        ZStack {
            ForEach(Array(emojis.enumerated()), id: \.offset) { index, emoji in
                FloatingEmoji(emoji: emoji, index: index, total: emojis.count)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
        .padding(.trailing, 12)
        .padding(.bottom, 40)
    }
}

private struct FloatingEmoji: View {
    let emoji: String
    let index: Int
    let total: Int

    @State private var offsetY: CGFloat = 0
    @State private var opacity: Double = 0

    // Stagger each emoji so they don't all move in sync
    private var delay: Double { Double(index) * 0.4 }
    private var horizontalShift: CGFloat { CGFloat((index % 3) - 1) * 14 }

    var body: some View {
        Text(emoji)
            .font(.system(size: 20))
            .shadow(color: .black.opacity(0.3), radius: 2)
            .offset(x: horizontalShift, y: offsetY)
            .opacity(opacity)
            .onAppear {
                withAnimation(
                    .easeInOut(duration: 2.2)
                    .repeatForever(autoreverses: false)
                    .delay(delay)
                ) {
                    offsetY = -80
                    opacity = 0
                }
                // Fade in quickly on first frame
                withAnimation(.easeIn(duration: 0.3).delay(delay)) {
                    opacity = 1
                }
            }
    }
}

#Preview("With caption and reactions") {
    ZStack {
        Color.darkBackground.ignoresSafeArea()
        StoryCard(card: MyStoryImageCard(
            imageUrl: "",
            reactions: ["u1": "👏", "u2": "🔥", "u3": "❤️"],
            caption: "Great morning run with the crew!"
        ))
    }
}

#Preview("No overlay") {
    ZStack {
        Color.darkBackground.ignoresSafeArea()
        StoryCard(card: MyStoryImageCard(
            imageUrl: "",
            reactions: [:],
            caption: nil
        ))
    }
}
