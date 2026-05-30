//
//  ViewStoriesHome.swift
//  sbud
//

import SwiftUI

struct ViewStoriesHome: View {
    @EnvironmentObject private var coordinator: StoriesCoordinator
    var vm: ViewModelStoriesHome

    var body: some View {
        ZStack {
            Color.darkBackground.ignoresSafeArea()
            if vm.isLoading && vm.friendsWithStories.isEmpty {
                ProgressView().tint(Color.mainColor)
            } else {
                scrollContent
            }
        }
        .navigationTitle("Stories")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .navigationBarTrailing) {
                Button {
                    coordinator.showCreateStory()
                } label: {
                    Image(systemName: "plus.circle.fill")
                        .foregroundStyle(Color.mainColor)
                        .font(.title2)
                }
            }
        }
        .task { await vm.load() }
    }

    private var scrollContent: some View {
        ScrollView {
            if vm.friendsWithStories.isEmpty {
                emptyState
                    .frame(maxWidth: .infinity)
                    .padding(.top, 120)
            } else {
                LazyVGrid(
                    columns: [GridItem(.adaptive(minimum: 80), spacing: 16)],
                    spacing: 20
                ) {
                    ForEach(vm.friendsWithStories) { friend in
                        FriendStoryAvatar(friend: friend) {
                            coordinator.goToFriendStories(userId: friend.id)
                        }
                    }
                }
                .padding()
            }
        }
        .refreshable { await vm.load() }
    }

    private var emptyState: some View {
        VStack(spacing: 12) {
            Image(systemName: "photo.stack")
                .font(.system(size: 48))
                .foregroundStyle(Color.mainColor)
            Text("No stories yet")
                .font(.headline)
                .foregroundStyle(.white)
            Text("Your friends' stories will appear here")
                .font(.subheadline)
                .foregroundStyle(.white.opacity(0.5))
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}

#Preview("With stories") {
    let vm = ViewModelStoriesHome()
    vm.friendsWithStories = [
        FriendWithStories(id: "1", name: "Ahmed Adel", profileImageUrl: nil, stories: []),
        FriendWithStories(id: "2", name: "Sara", profileImageUrl: nil, stories: []),
        FriendWithStories(id: "3", name: "Marco", profileImageUrl: nil, stories: []),
    ]
    return ViewStoriesHome(vm: vm)
        .environmentObject(StoriesCoordinator())
}

#Preview("Empty") {
    ViewStoriesHome(vm: ViewModelStoriesHome())
        .environmentObject(StoriesCoordinator())
}
