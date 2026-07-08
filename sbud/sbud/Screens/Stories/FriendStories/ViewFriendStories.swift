//
//  ViewFriendStories.swift
//  sbud
//

import SwiftUI

struct ViewFriendStories: View {
    @State private var vm: ViewModelFriendStories
    @State private var isExpanded = false
    @State private var showDeleteMenu = false
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
            GeometryReader { geo in
                let imageHeight = isExpanded
                    ? geo.size.height * 0.55
                    : geo.size.height

                VStack(spacing: 0) {
                    StoryImagePage(
                        imageUrl: image.url,
                        authorName: story.authorName,
                        authorImageUrl: story.authorProfileImageUrl,
                        currentIndex: vm.currentImageIndex,
                        totalImages: story.images.count
                    )
                    .frame(height: imageHeight)
                    .contentShape(RoundedRectangle(cornerRadius: UIConstants.cornerRadius))
                    .clipShape(RoundedRectangle(cornerRadius: isExpanded ? 20 : UIConstants.cornerRadius))
                    .overlay(alignment: .topTrailing) {
                        HStack(spacing: 0) {
                            if let story = vm.currentStory, story.userId == vm.currentUserId {
                                deleteMenuButton
                            }
                            dismissButton
                        }
                    }
                    .overlay(alignment: .bottom) {
                        if !isExpanded {
                            reactionBar(story: story)
                        }
                    }
                    .gesture(navigationAndSwipeGesture(story: story))
                    .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isExpanded)

                    if isExpanded {
                        expandedContent(story: story)
                    }
                }
            }
        }
    }

    private func expandedContent(story: Story) -> some View {
        ScrollView(showsIndicators: false) {
            VStack(alignment: .leading, spacing: 16) {
                if let caption = story.text, !caption.isEmpty {
                    Text(caption)
                        .font(.body)
                        .foregroundStyle(.white)
                        .multilineTextAlignment(.leading)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                }
                reactionBar(story: story)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
            }
        }
        .background(Color.black)
        .transition(.move(edge: .bottom).combined(with: .opacity))
    }

    private func reactionBar(story: Story) -> some View {
        StoryReactionBar(myReaction: story.myReaction) { emoji in
            Task { await vm.react(emoji: emoji) }
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(.bottom, isExpanded ? 0 : 80)
    }

    private func navigationAndSwipeGesture(story: Story) -> some Gesture {
        DragGesture(minimumDistance: 10)
            .onEnded { value in
                let isVertical = abs(value.translation.height) > abs(value.translation.width)

                if isVertical {
                    if value.translation.height < -40 {
                        // swipe up — only expand if caption exists
                        if let caption = story.text, !caption.isEmpty {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                isExpanded = true
                            }
                        }
                    } else if value.translation.height > 40 {
                        // swipe down — collapse
                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                            isExpanded = false
                        }
                    }
                } else {
                    // horizontal — navigate
                    let screenWidth = UIScreen.main.bounds.width
                    isExpanded = false
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
    }

    private var dismissButton: some View {
        Button {
            dismiss()
        } label: {
            Image(systemName: "xmark")
                .font(.title2.bold())
                .foregroundStyle(.white)
                .padding(16)
                .padding(.top, 64)
        }
    }

    private var deleteMenuButton: some View {
        Menu {
            Button(role: .destructive) {
                Task {
                    await vm.deleteCurrentImage { dismiss() }
                }
            } label: {
                Label("Delete this photo", systemImage: "photo.badge.minus")
            }

            Button(role: .destructive) {
                Task {
                    await vm.deleteCurrentStory { dismiss() }
                    if vm.stories.isEmpty { dismiss() }
                }
            } label: {
                Label("Delete entire story", systemImage: "trash")
            }
        } label: {
            Image(systemName: "ellipsis")
                .font(.title2.bold())
                .foregroundStyle(.white)
                .padding(16)
                .padding(.top, 64)
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
