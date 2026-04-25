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
    var activityType: String { get }
}

nonisolated struct ResponseActivityDetailsRunning: ResponseActivityDetails, Decodable, Sendable {
    var activityType: String
    var targetDistanceInKm: Double?
    var targetPace: Double?
}

nonisolated struct ResponseActivityDetailsCycling: ResponseActivityDetails, Decodable, Sendable {
    var activityType: String
    var targetDistanceInKm: Double?
    var powerInWatt: Double?
    var cadenceInRpm: Int?
}

nonisolated struct ResponseActivityDetailsGym: ResponseActivityDetails, Decodable, Sendable {
    var activityType: String
    var dayType: String?
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
}
