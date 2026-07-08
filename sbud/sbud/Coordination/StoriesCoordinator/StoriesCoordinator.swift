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
    @Published var createStorySheet: StoriesCreateStorySheet?

    func goToFriendStories(userId: String) {
        navigationPath.append(.friendStories(userId: userId))
    }

    func goToMyStories() {
        navigationPath.append(.myStories)
    }

    func goToManageMyStories() {
        navigationPath.append(.manageMyStories)
    }

    func showCreateStory() {
        activeSheet = .createStory
    }

    func dismissSheet() {
        activeSheet = nil
    }

    func showEventPicker(
        events: [ViewModelCreateStory.EventSummary],
        isLoading: Bool,
        selectedId: String?,
        onSelect: @escaping (ViewModelCreateStory.EventSummary) -> Void
    ) {
        createStorySheet = .eventPicker(events: events, isLoading: isLoading, selectedId: selectedId, onSelect: onSelect)
    }

    func dismissCreateStorySheet() {
        createStorySheet = nil
    }
}
