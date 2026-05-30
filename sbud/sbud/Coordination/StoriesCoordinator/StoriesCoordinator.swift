//
//  StoriesCoordinator.swift
//  sbud
//

import Foundation
import Combine

@MainActor
final class StoriesCoordinator: ObservableObject {

    @Published var navigationPath: [StoriesRoutePushed] = []
    @Published var activeSheet: StoriesSheetType?

    func goToFriendStories(userId: String) {
        navigationPath.append(.friendStories(userId: userId))
    }

    func showCreateStory() {
        activeSheet = .createStory
    }

    func dismissSheet() {
        activeSheet = nil
    }
}
