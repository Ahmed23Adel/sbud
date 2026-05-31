//
//  StoriesRoute.swift
//  sbud
//

import Foundation

enum StoriesRoutePushed: Equatable, Hashable {
    case friendStories(userId: String)
}

enum StoriesSheetType: Identifiable, Equatable, Hashable {
    case createStory

    var id: String { "createStory" }
}

enum StoriesCreateStorySheet: Identifiable {
    case eventPicker(
        events: [ViewModelCreateStory.EventSummary],
        isLoading: Bool,
        selectedId: String?,
        onSelect: (ViewModelCreateStory.EventSummary) -> Void
    )

    var id: String { "eventPicker" }
}
