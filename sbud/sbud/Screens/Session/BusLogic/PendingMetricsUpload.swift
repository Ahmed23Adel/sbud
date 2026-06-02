//
//  PendingMetricsUpload.swift
//  sbud
//
//  Created by ahmed on 31/05/2026.
//

import Foundation
import SwiftData

// MARK: - Creator event update

/// The fields needed to update the Event document when the creator's
/// deferred upload is eventually retried.
/// Stored as JSON inside `PendingMetricsUpload.creatorEventUpdateData`.
struct CreatorEventUpdate: Codable {
    let finalStartDateTime: Date
    let finalEndDateTime: Date
    let numSession: Int
}

// MARK: - Pending upload model

/// A locally persisted record of a metrics upload that could not be completed
/// at session end (no network, or — for participants — creator hasn't ended yet).
///
/// One model covers all activity types — `activityType` tells the retry service
/// which concrete snapshot type to decode from `snapshotData`.
/// Adding a new sport never requires a schema change here.
@Model
final class PendingMetricsUpload {

    var id: UUID
    var eventId: String
    var userId: String
    var numSession: Int
    var activityType: ActivityType
    var isCreator: Bool
    /// When the entry was created — used to enforce the 24-hour fallback timeout
    /// for participant entries waiting on the creator.
    var enqueuedAt: Date
    /// JSON-encoded sport-specific snapshot (e.g. `RunSessionSnapshot`).
    var snapshotData: Data
    /// Non-nil only for creator entries — JSON-encoded `CreatorEventUpdate`.
    /// Contains the fields needed to update the Event document on retry.
    var creatorEventUpdateData: Data?

    init(
        eventId: String,
        userId: String,
        numSession: Int,
        activityType: ActivityType,
        isCreator: Bool,
        snapshotData: Data,
        creatorEventUpdateData: Data? = nil
    ) {
        self.id = UUID()
        self.eventId = eventId
        self.userId = userId
        self.numSession = numSession
        self.activityType = activityType
        self.isCreator = isCreator
        self.enqueuedAt = Date()
        self.snapshotData = snapshotData
        self.creatorEventUpdateData = creatorEventUpdateData
    }
}
