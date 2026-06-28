//
//  ViewModelFriendStories.swift
//  sbud
//

import Foundation
import FirebaseAuth
import Combine

@MainActor
@Observable
final class ViewModelFriendStories {
    var stories: [Story]
    var currentStoryIndex = 0
    var currentImageIndex = 0

    /// Called whenever stories change so the home grid can stay in sync.
    var onStoriesChanged: (([Story]) -> Void)?

    private let storiesRepo = StoriesRepository()

    init(stories: [Story], onStoriesChanged: (([Story]) -> Void)? = nil) {
        self.stories = stories
        self.onStoriesChanged = onStoriesChanged
    }

    let currentUserId: String = Auth.auth().currentUser?.uid ?? ""

    var currentStory: Story? {
        guard currentStoryIndex < stories.count else { return nil }
        return stories[currentStoryIndex]
    }

    var currentImage: StoryImage? {
        guard let story = currentStory,
              currentImageIndex < story.images.count else { return nil }
        return story.images[currentImageIndex]
    }

    var isAtEnd: Bool {
        stories.isEmpty || (currentStoryIndex == stories.count - 1
            && currentImageIndex >= (stories[currentStoryIndex].images.count - 1))
    }

    // MARK: - Advance (marks viewed + removes the image locally)

    func advanceMarkingViewed() async {
        guard let story = currentStory, let image = currentImage else { return }

        // Fire-and-forget server call
        Task { try? await storiesRepo.markImageViewed(storyId: story.id, imageIndex: image.index) }

        // Remove viewed image from local state
        stories[currentStoryIndex].images.remove(at: currentImageIndex)

        if stories[currentStoryIndex].images.isEmpty {
            stories.remove(at: currentStoryIndex)
            // currentStoryIndex now points to the next story (array shifted); clamp if needed
            if currentStoryIndex >= stories.count {
                currentStoryIndex = max(0, stories.count - 1)
            }
            currentImageIndex = 0
        } else if currentImageIndex >= stories[currentStoryIndex].images.count {
            // Was the last image in this story — move to next story
            currentStoryIndex = min(currentStoryIndex + 1, stories.count - 1)
            currentImageIndex = 0
        }
        // else: currentImageIndex now points to the next image naturally

        onStoriesChanged?(stories)
    }

    func goBackImage() {
        if currentImageIndex > 0 {
            currentImageIndex -= 1
        } else if currentStoryIndex > 0 {
            currentStoryIndex -= 1
            currentImageIndex = max(0, stories[currentStoryIndex].images.count - 1)
        }
    }

    // MARK: - Delete (own stories only)

    /// Deletes the currently viewed image. Removes story entirely if it was the last image.
    func deleteCurrentImage(onLastImageDeleted: () -> Void) async {
        guard let story = currentStory, let image = currentImage else { return }
        do {
            if story.images.count == 1 {
                try await storiesRepo.deleteStory(story.id)
                stories.remove(at: currentStoryIndex)
                if currentStoryIndex >= stories.count {
                    currentStoryIndex = max(0, stories.count - 1)
                }
                currentImageIndex = 0
                onStoriesChanged?(stories)
                if stories.isEmpty { onLastImageDeleted() }
            } else {
                try await storiesRepo.deleteStoryImage(storyId: story.id, imageIndex: image.index)
                stories[currentStoryIndex].images.remove(at: currentImageIndex)
                if currentImageIndex >= stories[currentStoryIndex].images.count {
                    currentImageIndex = max(0, stories[currentStoryIndex].images.count - 1)
                }
                onStoriesChanged?(stories)
            }
        } catch {
            PopUpGenerator.shared.show(msg: error.localizedDescription, type: .error)
        }
    }

    /// Deletes the entire current story.
    func deleteCurrentStory(onDeleted: () -> Void) async {
        guard let story = currentStory else { return }
        do {
            try await storiesRepo.deleteStory(story.id)
            stories.remove(at: currentStoryIndex)
            if currentStoryIndex >= stories.count {
                currentStoryIndex = max(0, stories.count - 1)
            }
            currentImageIndex = 0
            onStoriesChanged?(stories)
            if stories.isEmpty { onDeleted() }
        } catch {
            PopUpGenerator.shared.show(msg: error.localizedDescription, type: .error)
        }
    }

    func react(emoji: String?) async {
        guard let story = currentStory else { return }
        do {
            let updatedReactions = try await storiesRepo.react(storyId: story.id, emoji: emoji)
            let uid = Auth.auth().currentUser?.uid ?? ""
            stories[currentStoryIndex].myReaction = updatedReactions[uid]
        } catch {
            PopUpGenerator.shared.show(msg: error.localizedDescription, type: .error)
        }
    }
}
