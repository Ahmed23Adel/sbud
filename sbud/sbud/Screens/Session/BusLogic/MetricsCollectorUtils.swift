//
//  MetricsCollectorUtils.swift
//  sbud
//
//  Created by ahmed on 17/05/2026.
//

import Foundation
import FirebaseFirestore
import CoreLocation
//
//  MetricsCollectorUtils.swift
//  sbud
//

import Foundation
import CoreLocation
import FirebaseFirestore

enum MetricsCollectorUtils {

    // MARK: - Location validation

    static func isValidLocation(_ location: CLLocation, lastLocation: CLLocation?) -> Bool {
        guard location.horizontalAccuracy >= 0,
              location.horizontalAccuracy < 20,
              location.speed >= 0
        else { return false }

        if let last = lastLocation {
            let timeDelta = location.timestamp.timeIntervalSince(last.timestamp)
            guard timeDelta >= 1 else { return false }
        }

        return true
    }

    // MARK: - Distance

    static func computeDistance(from locations: [CLLocation]) -> Double {
        guard locations.count > 1 else { return 0 }
        var total = 0.0
        for i in 1..<locations.count {
            total += locations[i].distance(from: locations[i - 1])
        }
        return total
    }

    // MARK: - Elevation

    static func computeElevationGain(from locations: [CLLocation]) -> Double {
        guard locations.count > 1 else { return 0 }
        var gain = 0.0
        for i in 1..<locations.count {
            let delta = locations[i].altitude - locations[i - 1].altitude
            if delta > 0 { gain += delta }
        }
        return gain
    }

    // MARK: - Track trimming

    static func trimTrack(
        _ track: [(Date, CLLocation)],
        to cutoff: Date
    ) -> [(Date, CLLocation)] {
        track.filter { $0.0 <= cutoff }
    }

    // MARK: - Elapsed time from trimmed track

    static func trimmedElapsed(
        from track: [(Date, CLLocation)],
        fallback: Double
    ) -> Double {
        guard let first = track.first?.0,
              let last = track.last?.0
        else { return fallback }
        return last.timeIntervalSince(first)
    }

    // MARK: - Firestore: read finalEndDateTime

    /// Returns the creator's finalEndDateTime if they have ended, nil otherwise.
    static func readFinalEndDateTime(eventId: String) async throws -> Date? {
        let db = Firestore.firestore()
        let snapshot = try await db.collection("Events").document(eventId).getDocument()
        guard let data = snapshot.data() else { throw MetricsError.eventNotFound }
        guard let timestamp = data["finalEndDateTime"] as? Timestamp else { return nil }
        return timestamp.dateValue()
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

enum MetricsError: Error {
    case eventNotFound
}
