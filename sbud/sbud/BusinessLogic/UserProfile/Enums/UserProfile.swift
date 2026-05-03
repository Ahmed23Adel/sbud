//
//  UserProfile.swift
//  sbud
//
//  Created by Erdal on 23/12/2025.
//
import Foundation

struct UserProfile: Codable, Identifiable {
    let id: String

    var name: String = ""
    var surName: String = ""
    var email: String = ""
    var birthDate: Date? = nil
    var phoneNumber: String? = nil

    var gender: String? = nil
    var profileImageUrl: String? = nil

    var country: String = ""
    var city: String = ""
    var location: UserLocation = UserLocation(latitude: 0, longitude: 0, fullAddress: "")

    var preferredActivity: ActivityType = .running
    var metrics: ActivityMetrics = ActivityMetrics()

    var createdAt: Date = Date()
    var lastSeenAt: Date = Date()

    var bio: String = ""
    var isProfileCompleted: Bool = false
    var pushToken: String? = nil

    // MARK: - Social
    var friendsCount: Int = 0
    var trustScore: Double = 0.00

    // MARK: - Performance
    var totalSessions: Int = 0
    var totalDistanceKm: Double = 0
    var avgIntensity: Int = 0
    var lastActivityDate: Date? = nil
    var lastActivityName: String? = nil

    var isPrivate: Bool = false

    // MARK: - Privacy
    var showEmail: Bool = false
    var showPhone: Bool = false
    var showAddress: Bool = false

    var age: Int? {
        guard let birthDate else { return nil }
        return Calendar.current.dateComponents([.year], from: birthDate, to: Date()).year
    }

    init(id: String) {
        self.id = id
    }

    // MARK: - Custom Decoder
    init(from decoder: Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)

        id                = try c.decode(String.self, forKey: .id)
        name              = try c.decodeIfPresent(String.self, forKey: .name)              ?? ""
        surName           = try c.decodeIfPresent(String.self, forKey: .surName)           ?? ""
        email             = try c.decodeIfPresent(String.self, forKey: .email)             ?? ""
        birthDate         = try c.decodeIfPresent(Date.self,   forKey: .birthDate)
        phoneNumber       = try c.decodeIfPresent(String.self, forKey: .phoneNumber)
        gender            = try c.decodeIfPresent(String.self, forKey: .gender)
        profileImageUrl   = try c.decodeIfPresent(String.self, forKey: .profileImageUrl)
        country           = try c.decodeIfPresent(String.self, forKey: .country)           ?? ""
        city              = try c.decodeIfPresent(String.self, forKey: .city)              ?? ""
        location          = try c.decodeIfPresent(UserLocation.self, forKey: .location) ?? UserLocation(latitude: 0, longitude: 0, fullAddress: "")
        preferredActivity = try c.decodeIfPresent(ActivityType.self, forKey: .preferredActivity) ?? .running
        metrics           = try c.decodeIfPresent(ActivityMetrics.self, forKey: .metrics) ?? ActivityMetrics()
        createdAt         = try c.decodeIfPresent(Date.self,   forKey: .createdAt)         ?? Date()
        lastSeenAt        = try c.decodeIfPresent(Date.self,   forKey: .lastSeenAt)        ?? Date()
        bio               = try c.decodeIfPresent(String.self, forKey: .bio)               ?? ""
        isProfileCompleted = try c.decodeIfPresent(Bool.self,  forKey: .isProfileCompleted) ?? false
        pushToken         = try c.decodeIfPresent(String.self, forKey: .pushToken)

        friendsCount      = try c.decodeIfPresent(Int.self,    forKey: .friendsCount)      ?? 0
        trustScore        = try c.decodeIfPresent(Double.self, forKey: .trustScore)        ?? 0.0

        totalSessions     = try c.decodeIfPresent(Int.self,    forKey: .totalSessions)     ?? 0
        totalDistanceKm   = try c.decodeIfPresent(Double.self, forKey: .totalDistanceKm)   ?? 0
        avgIntensity      = try c.decodeIfPresent(Int.self,    forKey: .avgIntensity)      ?? 0
        lastActivityDate  = try c.decodeIfPresent(Date.self,   forKey: .lastActivityDate)
        lastActivityName  = try c.decodeIfPresent(String.self, forKey: .lastActivityName)

        isPrivate         = try c.decodeIfPresent(Bool.self,   forKey: .isPrivate)         ?? false
        showEmail         = try c.decodeIfPresent(Bool.self,   forKey: .showEmail)         ?? false
        showPhone         = try c.decodeIfPresent(Bool.self,   forKey: .showPhone)         ?? false
        showAddress       = try c.decodeIfPresent(Bool.self,   forKey: .showAddress)       ?? false
    }
}

extension UserProfile {
    static let empty = UserProfile(id: "")
}
