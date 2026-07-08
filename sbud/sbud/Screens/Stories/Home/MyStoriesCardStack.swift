//
//  MyStoriesCardStack.swift
//  sbud
//

import SwiftUI

struct MyStoriesCardStack: View {
    @State private var cards: [MyStoryImageCard]
    @State private var dragOffset: CGSize = .zero
    @State private var isDragging = false
    var onViewAll: (() -> Void)?

    // Pre-computed random rotations so they don't shift on re-render
    private let rotations: [Double]

    init(cards: [MyStoryImageCard], onViewAll: (() -> Void)? = nil) {
        _cards = State(initialValue: cards)
        rotations = cards.indices.map { _ in Double.random(in: -12...12) }
        self.onViewAll = onViewAll
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Your stories")
                    .font(.subheadline)
                    .fontWeight(.semibold)
                    .foregroundStyle(.white.opacity(0.7))
                Spacer()
                if onViewAll != nil {
                    Button("View all") { onViewAll?() }
                        .font(.subheadline)
                        .foregroundStyle(Color.mainColor)
                }
            }
            .padding(.horizontal)

            ZStack {
                ForEach(Array(cards.enumerated()), id: \.element.id) { index, card in
                    cardView(card: card, index: index)
                }
            }
            .frame(height: 320)
            .padding(.horizontal, 24)
        }
    }

    @ViewBuilder
    private func cardView(card: MyStoryImageCard, index: Int) -> some View {
        let isTop = index == cards.count - 1
        let rotation = rotations[min(index, rotations.count - 1)]
        let depth = CGFloat(cards.count - 1 - index)
        let stackOffsetX = depth * 4
        let stackOffsetY = depth * -6
        let offsetX = isTop ? dragOffset.width + stackOffsetX : stackOffsetX
        let offsetY = isTop ? dragOffset.height + stackOffsetY : stackOffsetY
        let deg = isTop ? rotation + dragRotation : rotation
        let scale = isTop ? 1.0 : 1.0 - depth * 0.025

        StoryCard(card: card)
            .rotationEffect(.degrees(deg))
            .offset(x: offsetX, y: offsetY)
            .scaleEffect(scale)
            .zIndex(Double(index))
            .gesture(isTop ? dragGesture : nil)
            .animation(.spring(response: 0.35, dampingFraction: 0.75), value: dragOffset)
    }

    private var dragRotation: Double {
        Double(dragOffset.width) / 20.0
    }

    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                dragOffset = value.translation
                isDragging = true
            }
            .onEnded { value in
                let threshold: CGFloat = 100
                if abs(value.translation.width) > threshold || abs(value.translation.height) > threshold {
                    flyOut(toward: value.translation)
                } else {
                    withAnimation(.spring()) { dragOffset = .zero }
                    isDragging = false
                }
            }
    }

    private func flyOut(toward translation: CGSize) {
        let direction = CGSize(
            width: translation.width * 4,
            height: translation.height * 4
        )
        withAnimation(.easeOut(duration: 0.3)) {
            dragOffset = direction
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            if !cards.isEmpty { cards.removeLast() }
            dragOffset = .zero
            isDragging = false
        }
    }
}

#Preview {
    ZStack {
        Color.darkBackground.ignoresSafeArea()
        MyStoriesCardStack(cards: [
            MyStoryImageCard(imageUrl: "", reactions: ["u1": "👏", "u2": "🔥"], caption: "Great morning run!"),
            MyStoryImageCard(imageUrl: "", reactions: ["u1": "❤️"], caption: "Summit achieved"),
            MyStoryImageCard(imageUrl: "", reactions: [:], caption: nil),
        ])
    }
}
