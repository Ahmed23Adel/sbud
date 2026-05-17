//
//  MetricsCollectorUtils.swift
//  sbud
//
//  Created by ahmed on 17/05/2026.
//

import Foundation
import FirebaseFirestore
import CoreLocation

class MetricsCollectorUtils{
    
    static func isCreatorEndedSession(eventId: String, eventRef: DocumentReference) async throws -> (Bool, Timestamp?){
        // 1. Read the event doc to check if creator has ended
        let snapshot = try await eventRef.getDocument()
        guard let data = snapshot.data() else {
            throw MetricsError.eventNotFound
        }

        let creatorEndedSession = data["finalEndDateTime"] != nil
        return (creatorEndedSession, data["finalEndDateTime"] as? Timestamp)
    }
    
    static func trimMetricsForRun(finalEndDateTime: Date,
                                  trackedLocations: [(Date, CLLocation)],
                                  splits: [Split]) -> ([(Date, CLLocation)], [Split], Double)
    {

        let trimmedTrack = trackedLocations.filter { $0.0 <= finalEndDateTime }
        let trimmedSplits = splits.filter { $0.dateTimeCreated <= finalEndDateTime }

        // Recalculate total distance from trimmed track
        let trimmedDistance = computeDistance(from: trimmedTrack.map { $0.1 })
        
        return (trimmedTrack, trimmedSplits, trimmedDistance)
    }
    
    static func computeDistance(from locations: [CLLocation]) -> Double {
        guard locations.count > 1 else { return 0 }
        var total = 0.0
        for i in 1..<locations.count {
            total += locations[i].distance(from: locations[i - 1])
        }
        return total
    }
}



extension Collection where Element == (Date, CLLocation) {
    /// Converts the array of location tuples directly into TrackPoint models
    func toTrackPoints() -> [TrackPoint] {
        return self.map { tuple in
            TrackPoint(
                timestamp: tuple.0,
                latitude: tuple.1.coordinate.latitude,
                longitude: tuple.1.coordinate.longitude
            )
        }
    }
}
