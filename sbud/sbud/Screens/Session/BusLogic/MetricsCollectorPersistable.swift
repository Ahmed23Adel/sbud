//
//  MetricsCollectorPersistable.swift
//  sbud
//
//  Created by ahmed on 17/05/2026.
//

import Foundation

protocol MetricsCollectorPersistable {
    func saveCheckpoint(eventId: String)
    func restoreCheckpoint(eventId: String) -> Bool
    func clearCheckpoint(eventId: String)
}

extension MetricsCollectorPersistable {
    func clearCheckpoint(eventId: String) {
        UserDefaults.standard.removeObject(forKey: checkpointKey(eventId: eventId))
    }

    func checkpointKey(eventId: String) -> String {
        return "checkpoint_\(String(describing: Self.self))_\(eventId)"
    }
}
