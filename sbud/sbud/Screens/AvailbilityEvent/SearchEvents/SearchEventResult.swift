//
//  SearchEventResult.swift
//  sbud
//
//  Created by ahmed on 26/05/2026.
//

import Foundation

struct SearchEventResult: Identifiable, Sendable {
    let id: String
    let title: String
    let eventImage: String
    let creatorName: String
    let activityType: String
    let startDateTime: Date
    let endDateTime: Date
    let isDateConfirmed: Bool
    let isPublic: Bool
    let numFlattenedEvents: Int
    let eventId: String
    let creatorId: String?
}
