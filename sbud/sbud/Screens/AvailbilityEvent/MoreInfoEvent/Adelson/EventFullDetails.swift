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

// MARK: - Location

nonisolated struct LocationPoint: Decodable, Sendable {
    var latitude: Double
    var longitude: Double
    var geohash: String
}

// MARK: - DateLocation

nonisolated struct DateLocationEntry: Decodable, Sendable, Identifiable {
    var id: String
    var startDateTime: Date
    var endDateTime: Date
    var locations: [LocationPoint]
}

// MARK: - Top-level response

nonisolated struct EventFullDetails: Decodable, Sendable, Equatable, Hashable {
    var id: String
    var title: String
    var creator: CreatorInfo
    var activityDetails: ExtraArgsHolder
    var eventImage: String?
    var isDateConfirmed: Bool
    var isLocationConfirmed: Bool
    var isPublic: Bool
    var joinCondition: JoinCondition
    var maxAllowedToJoin: Int?
    var notes: String?
    var createdAt: Date
    var dateLocations: [DateLocationEntry]

    var activityType: ActivityType { activityDetails.selectedActivity }

    enum CodingKeys: String, CodingKey {
        case id, title, creator, activityDetails, eventImage
        case isDateConfirmed, isLocationConfirmed, isPublic
        case joiningCondition, maxAllowedToJoin, notes, createdAt, dateLocations
    }

    init(
        id: String,
        title: String,
        creator: CreatorInfo,
        activityDetails: ExtraArgsHolder,
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
        activityDetails = try container.decode(ExtraArgsHolder.self, forKey: .activityDetails)
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
    
    static func == (lhs: EventFullDetails, rhs: EventFullDetails) -> Bool {
        return lhs.id ==  rhs.id
    }
    
    func hash(into hasher: inout Hasher){
        hasher.combine(id)
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
        activityDetails: ExtraArgsHolder(),
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

extension EventFullDetails {
    static let empty = EventFullDetails(
        id: "",
        title: "",
        creator: .sample,
        activityDetails: ExtraArgsHolder(),
        eventImage: "",
        isDateConfirmed: false,
        isLocationConfirmed: false,
        isPublic: true,
        joinCondition: .requestFromHost,
        maxAllowedToJoin: 150,
        notes: "",
        createdAt: Date(),
        dateLocations: [.sample, .sample]
    )
}
