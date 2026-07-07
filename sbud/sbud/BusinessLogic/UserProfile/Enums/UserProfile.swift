//
//  UserProfile.swift
//  sbud
//
//  Created by Erdal on 23/12/2025.
//
import Foundation

struct UserProfile: Codable, Identifiable, CustomStringConvertible {
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

    // MARK: - Performance (temel — Firestore'daki UserProfile doc'undan gelir)
    var totalSessions: Int = 0
    var totalDistanceKm: Double = 0
    var avgIntensity: Int = 0
    var lastActivityDate: Date? = nil
    var lastActivityName: String? = nil

    // MARK: - Performance (genişletilmiş — /users/{id}/stats endpoint'inden gelir)
    var totalDurationHours: Double? = nil
    var favoriteActivity: String? = nil
    var currentStreakDays: Int? = nil
    var monthlySessionCount: Int? = nil
    var activityStats: [String: ActivityStat]? = nil

    var isPrivate: Bool = false

    // MARK: - Privacy
    var showEmail: Bool = false
    var showPhone: Bool = false
    var showAddress: Bool = false

    var age: Int? {
        guard let birthDate else { return nil }
        return Calendar.current.dateComponents([.year], from: birthDate, to: Date()).year
    }

    var description: String {
        """
        UserProfile(
            id: \(id),
            name: \(name) \(surName),
            email: \(email),
            age: \(age ?? 0),
            totalSessions: \(totalSessions),
            totalDistanceKm: \(totalDistanceKm),
            avgIntensity: \(avgIntensity),
            favoriteActivity: \(favoriteActivity ?? "nil"),
            currentStreakDays: \(currentStreakDays ?? 0),
            monthlySessionCount: \(monthlySessionCount ?? 0),
            isPrivate: \(isPrivate)
        )
        """
    }

    init(id: String) {
        self.id = id
    }

    // MARK: - Apply stats from API response
    mutating func applyStats(_ stats: UserStatsResponse) {
        if let v = stats.totalSessions      { totalSessions = v }
        if let v = stats.totalDistanceKm    { totalDistanceKm = v }
        if let v = stats.avgIntensity       { avgIntensity = v }
        if let v = stats.totalDurationHours { totalDurationHours = v }
        if let v = stats.favoriteActivity   { favoriteActivity = v }
        if let v = stats.currentStreakDays  { currentStreakDays = v }
        if let v = stats.monthlySessionCount { monthlySessionCount = v }
        if let v = stats.activityStats      { activityStats = v }
        if let v = stats.lastActivityName   { lastActivityName = v }
        if let dateStr = stats.lastActivityDate {
            let formatter = ISO8601DateFormatter()
            formatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            lastActivityDate = formatter.date(from: dateStr)
                ?? ISO8601DateFormatter().date(from: dateStr)
        }
    }
}

extension UserProfile {
    static let empty = UserProfile(id: "")
}
