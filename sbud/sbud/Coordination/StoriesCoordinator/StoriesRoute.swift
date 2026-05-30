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
