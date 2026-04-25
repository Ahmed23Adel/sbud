//
//  EventByIdResponse.swift
//  sbud
//
//  Created by ahmed on 25/04/2026.
//

import Foundation

// MARK: - Creator

nonisolated struct CreatorInfo: Decodable, Sendable {
    var id: String
    var name: String
    var surName: String
    var profileImageUrl: String?
}

// MARK: - Activity Details

protocol ResponseActivityDetails: Decodable, Sendable {
    var activityType: ActivityType { get }
}

nonisolated struct ResponseActivityDetailsRunning: ResponseActivityDetails, Decodable, Sendable {
    var activityType: ActivityType = .running
    var targetDistanceInKm: Double?
    var targetPace: Double?

    private enum CodingKeys: String, CodingKey {
        case targetDistanceInKm
        case targetPace
    }
}
nonisolated struct ResponseActivityDetailsCycling: ResponseActivityDetails, Decodable, Sendable {
    var activityType: ActivityType = .cycling
    var targetDistanceInKm: Double?
    var powerInWatt: Double?
    var cadenceInRpm: Int?

    private enum CodingKeys: String, CodingKey {
        case targetDistanceInKm
        case powerInWatt
        case cadenceInRpm
    }
}

nonisolated struct ResponseActivityDetailsGym: ResponseActivityDetails, Decodable, Sendable {
    var activityType: ActivityType = .gym
    var dayType: String?

    private enum CodingKeys: String, CodingKey {
        case dayType
    }
}

// MARK: - Activity Details wrapper (handles polymorphic decoding)

nonisolated struct AnyActivityDetails: Decodable, Sendable {
    var value: any ResponseActivityDetails

    private enum CodingKeys: String, CodingKey {
        case activityType
    }

    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let activityType = try container.decode(String.self, forKey: .activityType)

        switch activityType {
        case "Running":
            value = try ResponseActivityDetailsRunning(from: decoder)
        case "Cycling":
            value = try ResponseActivityDetailsCycling(from: decoder)
        default:
            value = try ResponseActivityDetailsGym(from: decoder)
        }
    }
}

// Add this init to AnyActivityDetails
extension AnyActivityDetails {
    init(value: any ResponseActivityDetails) {
        self.value = value
    }
}

// MARK: - Location

nonisolated struct LocationPoint: Decodable, Sendable {
    var latitude: Double
    var longitude: Double
    var geohash: String
}

// MARK: - DateLocation

nonisolated struct DateLocationEntry: Decodable, Sendable {
    var id: String
    var startDateTime: Date
    var endDateTime: Date
    var locations: [LocationPoint]
}

// MARK: - Top-level response

nonisolated struct EventFullDetails: Decodable, Sendable {
    var id: String
    var title: String
    var creator: CreatorInfo
    var activityDetails: AnyActivityDetails
    var eventImage: String?
    var isDateConfirmed: Bool
    var isLocationConfirmed: Bool
    var isPublic: Bool
    var joiningCondition: String
    var maxAllowedToJoin: Int?
    var notes: String?
    var createdAt: Date
    var dateLocations: [DateLocationEntry]

    var activityType: ActivityType { activityDetails.value.activityType }
}

// MARK: - Samples
extension CreatorInfo {
    static let sample = CreatorInfo(
        id: "WKSidc5m3ff36toyy8X7z9xjJWz2",
        name: "Ahmed",
        surName: "Hussein",
        profileImageUrl: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRtF1Gz_Xsh2r_DfO5JaLspe4oKYcEGo-myBg&s"
    )
}

extension LocationPoint {
    static let sample = LocationPoint(
        latitude: 45.4642,
        longitude: 9.1900,
        geohash: "u0ndx37j"
    )
}

extension DateLocationEntry {
    static let sample = DateLocationEntry(
        id: "r112Nq2rLWVrOhujLcaL",
        startDateTime: Date().addingTimeInterval(3600),
        endDateTime: Date().addingTimeInterval(7200),
        locations: [.sample, .sample]
    )
}

extension EventFullDetails {
    static let sample = EventFullDetails(
        id: "xN6ncT0Foa0UdFy06GSL",
        title: "Morning Run",
        creator: .sample,
        activityDetails: AnyActivityDetails(value: ResponseActivityDetailsRunning(
            activityType: .running,
            targetDistanceInKm: 6.5,
            targetPace: 8.5
        )),
        eventImage: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRtF1Gz_Xsh2r_DfO5JaLspe4oKYcEGo-myBg&s",
        isDateConfirmed: false,
        isLocationConfirmed: false,
        isPublic: true,
        joiningCondition: "requestFromHost",
        maxAllowedToJoin: 150,
        notes: "Come join me",
        createdAt: Date(),
        dateLocations: [.sample, .sample]
    )
}
