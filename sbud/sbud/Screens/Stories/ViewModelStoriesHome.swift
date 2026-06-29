//
//  ViewModelStoriesHome.swift
//  sbud
//

import Foundation

@MainActor
@Observable
final class ViewModelStoriesHome {
    var friendsWithStories: [FriendWithStories] = []
    var myStories: [Story] = []
    var myStoryCards: [MyStoryImageCard] = []
    var isLoading = false
    var errorMessage: String?

    private let helper = StoriesHelperService.shared
    private let myStoriesRepo = MyStoriesRepository()

    func updateStories(for userId: String, remaining: [Story]) {
        if remaining.isEmpty {
            friendsWithStories.removeAll { $0.id == userId }
        } else if let idx = friendsWithStories.firstIndex(where: { $0.id == userId }) {
            let current = friendsWithStories[idx]
            friendsWithStories[idx] = FriendWithStories(
                id: current.id,
                name: current.name,
                profileImageUrl: current.profileImageUrl,
                stories: remaining
            )
        }
    }

    func load() async {
        isLoading = true
        defer { isLoading = false }
        async let allGroups = helper.fetchFriendsWithStoriesAndOwn()
        async let myCards = myStoriesRepo.fetchMyRandomImages()
        do {
            let (friends, own) = try await allGroups
            friendsWithStories = friends
            myStories = own
            myStoryCards = (try? await myCards) ?? []
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func updateMyStories(remaining: [Story]) {
        myStories = remaining
    }
}
