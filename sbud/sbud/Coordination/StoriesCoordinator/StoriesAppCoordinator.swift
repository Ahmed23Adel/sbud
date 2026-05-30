//
//  StoriesAppCoordinator.swift
//  sbud
//

import SwiftUI

// MARK: - Tab Root

struct StoriesTabRoot: View {
    @StateObject private var coordinator = StoriesCoordinator()
    @State private var homeVM = ViewModelStoriesHome()

    var body: some View {
        NavigationStack(path: $coordinator.navigationPath) {
            ViewStoriesHome(vm: homeVM)
                .navigationDestination(for: StoriesRoutePushed.self) { route in
                    StoriesDestinationView(route: route, homeVM: homeVM)
                }
        }
        .environmentObject(coordinator)
        .sheet(item: $coordinator.activeSheet) { sheet in
            switch sheet {
            case .createStory:
                ViewCreateStory(onDidPost: {
                    coordinator.dismissSheet()
                    Task { await homeVM.load() }
                })
            }
        }
    }
}

// MARK: - Destination View

private struct StoriesDestinationView: View {
    let route: StoriesRoutePushed
    let homeVM: ViewModelStoriesHome

    var body: some View {
        switch route {
        case .friendStories(let userId):
            let stories = homeVM.friendsWithStories.first(where: { $0.id == userId })?.stories ?? []
            ViewFriendStories(stories: stories) { remaining in
                homeVM.updateStories(for: userId, remaining: remaining)
            }
        }
    }
}
