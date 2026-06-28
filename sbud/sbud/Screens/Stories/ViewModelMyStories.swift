//
//  ViewModelMyStories.swift
//  sbud
//

import Foundation

@MainActor
@Observable
final class ViewModelMyStories {
    var stories: [Story] = []
    var isLoading = false
    var isLoadingMore = false
    var hasMore = true

    private let requester = MyStoriesRequester()
    private let pageSize = 20

    func load() async {
        guard !isLoading else { return }
        isLoading = true
        defer { isLoading = false }
        do {
            let response = try await requester.fetchMyStories(limit: pageSize, offset: 0)
            stories = response.stories
            hasMore = response.hasMore
        } catch {
            print("ViewModelMyStories.load error: \(error)")
            PopUpGenerator.shared.show(msg: error.localizedDescription, type: .error)
        }
    }

    func loadMore() async {
        guard hasMore, !isLoadingMore, !isLoading else { return }
        isLoadingMore = true
        defer { isLoadingMore = false }
        do {
            let response = try await requester.fetchMyStories(limit: pageSize, offset: stories.count)
            stories.append(contentsOf: response.stories)
            hasMore = response.hasMore
        } catch {
            print("ViewModelMyStories.loadMore error: \(error)")
            PopUpGenerator.shared.show(msg: error.localizedDescription, type: .error)
        }
    }

    func deleteImage(storyId: String, imageIndex: Int) async {
        guard let storyIdx = stories.firstIndex(where: { $0.id == storyId }) else { return }
        let story = stories[storyIdx]
        do {
            if story.images.count == 1 {
                try await requester.deleteStory(storyId: storyId)
                stories.remove(at: storyIdx)
            } else {
                try await requester.deleteStoryImage(storyId: storyId, imageIndex: imageIndex)
                stories[storyIdx].images.removeAll { $0.index == imageIndex }
            }
        } catch {
            print("ViewModelMyStories.deleteImage error: \(error)")
            PopUpGenerator.shared.show(msg: error.localizedDescription, type: .error)
        }
    }

    func deleteStory(storyId: String) async {
        guard let storyIdx = stories.firstIndex(where: { $0.id == storyId }) else { return }
        do {
            try await requester.deleteStory(storyId: storyId)
            stories.remove(at: storyIdx)
        } catch {
            print("ViewModelMyStories.deleteStory error: \(error)")
            PopUpGenerator.shared.show(msg: error.localizedDescription, type: .error)
        }
    }
}
