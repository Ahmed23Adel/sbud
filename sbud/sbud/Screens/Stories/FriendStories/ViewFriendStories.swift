//
//  ViewFriendStories.swift
//  sbud
//

import SwiftUI

struct ViewFriendStories: View {
    @State private var vm: ViewModelFriendStories
    @Environment(\.dismiss) private var dismiss

    var onStoriesChanged: (([Story]) -> Void)?

    init(stories: [Story], onStoriesChanged: (([Story]) -> Void)? = nil) {
        _vm = State(initialValue: ViewModelFriendStories(stories: stories, onStoriesChanged: onStoriesChanged))
    }

    var body: some View {
        ZStack {
            Color.black.ignoresSafeArea()
            if vm.stories.isEmpty {
                noStoriesView
            } else {
                storyContent
            }
        }
        .navigationBarBackButtonHidden()
        .ignoresSafeArea()
    }

    @ViewBuilder
    private var storyContent: some View {
        if let story = vm.currentStory, let image = vm.currentImage {
            StoryImagePage(
                imageUrl: image.url,
                authorName: story.authorName,
                authorImageUrl: story.authorProfileImageUrl,
                currentIndex: vm.currentImageIndex,
                totalImages: story.images.count
            )
            .contentShape(Rectangle())
            .gesture(tapGesture)
            .overlay(alignment: .topLeading) { dismissButton }
            .overlay(alignment: .bottom) {
                bottomControls(story: story)
            }
        }
    }

    private func bottomControls(story: Story) -> some View {
        VStack(alignment: .center, spacing: 10) {
            if let caption = story.text, !caption.isEmpty {
                captionView(caption)
            }
            StoryReactionBar(myReaction: story.myReaction) { emoji in
                Task { await vm.react(emoji: emoji) }
            }
            .frame(maxWidth: .infinity, alignment: .center)
        }
        .padding(.bottom, 80)
    }

    private func captionView(_ text: String) -> some View {
        Text(text)
            .font(.subheadline)
            .foregroundStyle(.white)
            .multilineTextAlignment(.leading)
            .padding(12)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(.ultraThinMaterial)
    }

    private var tapGesture: some Gesture {
        DragGesture(minimumDistance: 0).onEnded { value in
            let screenWidth = UIScreen.main.bounds.width
            if value.location.x > screenWidth / 2 {
                if vm.isAtEnd {
                    Task { await vm.advanceMarkingViewed() }
                    dismiss()
                } else {
                    Task { await vm.advanceMarkingViewed() }
                }
            } else {
                vm.goBackImage()
            }
        }
    }

    private var dismissButton: some View {
        Button { dismiss() } label: {
            Image(systemName: "xmark")
                .font(.title2.bold())
                .foregroundStyle(.white)
                .padding(16)
                .padding(.top, 44)
        }
    }

    private var noStoriesView: some View {
        VStack(spacing: 12) {
            Image(systemName: "photo.slash")
                .font(.system(size: 48))
                .foregroundStyle(.white.opacity(0.5))
            Text("No stories available")
                .foregroundStyle(.white)
        }
        .overlay(alignment: .topLeading) { dismissButton }
    }
}

#Preview {
    let mockStory = Story(
        id: "story-1", userId: "user-1",
        authorName: "Ahmed Adel", authorProfileImageUrl: nil,
        eventId: "event-1", eventName: "Morning Run", eventImage: nil,
        activityType: "Running",
        images: [StoryImage(index: 0, url: "https://picsum.photos/400/700"),
                 StoryImage(index: 1, url: "https://picsum.photos/400/800")],
        text: "Great morning run with the crew! 🏃‍♂️",
        reactions: [:], createdAt: Date(), expiresAt: nil, myReaction: nil
    )
    ViewFriendStories(stories: [mockStory])
}
