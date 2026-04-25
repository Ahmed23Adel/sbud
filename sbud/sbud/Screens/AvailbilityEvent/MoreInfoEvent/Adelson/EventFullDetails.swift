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
    var joinCondition: JoinCondition
    var maxAllowedToJoin: Int?
    var notes: String?
    var createdAt: Date
    var dateLocations: [DateLocationEntry]

    var activityType: ActivityType { activityDetails.value.activityType }

    enum CodingKeys: String, CodingKey {
        case id, title, creator, activityDetails, eventImage
        case isDateConfirmed, isLocationConfirmed, isPublic
        case joiningCondition, maxAllowedToJoin, notes, createdAt, dateLocations
    }

    init(
        id: String,
        title: String,
        creator: CreatorInfo,
        activityDetails: AnyActivityDetails,
        eventImage: String? = nil,
        isDateConfirmed: Bool,
        isLocationConfirmed: Bool,
        isPublic: Bool,
        joinCondition: JoinCondition,
        maxAllowedToJoin: Int? = nil,
        notes: String? = nil,
        createdAt: Date,
        dateLocations: [DateLocationEntry]
    ) {
        self.id = id
        self.title = title
        self.creator = creator
        self.activityDetails = activityDetails
        self.eventImage = eventImage
        self.isDateConfirmed = isDateConfirmed
        self.isLocationConfirmed = isLocationConfirmed
        self.isPublic = isPublic
        self.joinCondition = joinCondition
        self.maxAllowedToJoin = maxAllowedToJoin
        self.notes = notes
        self.createdAt = createdAt
        self.dateLocations = dateLocations
    }
    
    init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        creator = try container.decode(CreatorInfo.self, forKey: .creator)
        activityDetails = try container.decode(AnyActivityDetails.self, forKey: .activityDetails)
        eventImage = try container.decodeIfPresent(String.self, forKey: .eventImage)
        isDateConfirmed = try container.decode(Bool.self, forKey: .isDateConfirmed)
        isLocationConfirmed = try container.decode(Bool.self, forKey: .isLocationConfirmed)
        isPublic = try container.decode(Bool.self, forKey: .isPublic)
        maxAllowedToJoin = try container.decodeIfPresent(Int.self, forKey: .maxAllowedToJoin)
        notes = try container.decodeIfPresent(String.self, forKey: .notes)
        createdAt = try container.decode(Date.self, forKey: .createdAt)
        dateLocations = try container.decode([DateLocationEntry].self, forKey: .dateLocations)

        let rawJoiningCondition = try container.decode(String.self, forKey: .joiningCondition)
        switch rawJoiningCondition {
        case "autoJoin": joinCondition = .autoJoin
        case "requestFromHost": joinCondition = .requestFromHost
        default: joinCondition = .requestFromHost
        }
    }
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
        joinCondition: .requestFromHost,
        maxAllowedToJoin: 150,
        notes: "Come join me",
        createdAt: Date(),
        dateLocations: [.sample, .sample]
    )
}

extension AnyActivityDetails {
    static let sampleRunning = AnyActivityDetails(value: ResponseActivityDetailsRunning(
        targetDistanceInKm: 6.5,
        targetPace: 5.5
    ))

    static let sampleCycling = AnyActivityDetails(value: ResponseActivityDetailsCycling(
        targetDistanceInKm: 30.0,
        powerInWatt: 250.0,
        cadenceInRpm: 90
    ))

    static let sampleGym = AnyActivityDetails(value: ResponseActivityDetailsGym(
        dayType: "Push"
    ))
}
