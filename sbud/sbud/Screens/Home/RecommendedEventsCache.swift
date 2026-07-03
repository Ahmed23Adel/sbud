//
//  RecommendedEventsCache.swift
//  sbud
//
//  Created by Erdal on 1.06.2026.
//

import Foundation

class RecommendedEventsCache {
    static let shared = RecommendedEventsCache()
    private let key = "cached_recommended_events"
    private let defaults = UserDefaults.standard

    func save(_ events: [RecommendedEvent]) {
        if let data = try? JSONEncoder().encode(events) {
            defaults.set(data, forKey: key)
        }
    }

    func load() -> [RecommendedEvent]? {
        guard let data = defaults.data(forKey: key),
              let events = try? JSONDecoder().decode([RecommendedEvent].self, from: data)
        else { return nil }
        return events
    }
}
