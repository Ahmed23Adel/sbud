//
//  SessionHistoryEntry.swift
//  sbud
//
//  Created by ahmed on 24/05/2026.
//

import Foundation

struct SessionHistoryEntry: Identifiable {
    let id: Int  // session index (numSession)
    let startDateTime: Date
    let endDateTime: Date

    var duration: TimeInterval { endDateTime.timeIntervalSince(startDateTime) }
}
