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
    var receivedFeedbacks: [String: String]? = [:]

    // QUESTA FUNZIONE CALCOLA LA TOP 10 IN AUTOMATICO
    var top10Feedbacks: [(tag: String, count: Int)] {
        guard let feedbacks = receivedFeedbacks else { return [] }
        
        var counts: [String: Int] = [:]
        // Conta quante volte compare ogni aggettivo
        for adjective in feedbacks.values {
            counts[adjective, default: 0] += 1
        }
        
        // Ordina dal più votato al meno votato e prende i primi 10
        let sorted = counts
            .map { (tag: $0.key, count: $0.value) }
            .sorted { $0.count > $1.count }
        
        return Array(sorted.prefix(10))
    }

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

    
    var description: String {
            """
            UserProfile(
                id: \(id),
                name: \(name) \(surName),
                email: \(email),
                age: \(age ?? 0),
                phone: \(phoneNumber ?? "N/A"),
                gender: \(gender ?? "N/A"),
                country: \(country),
                city: \(city),
                preferredActivity: \(preferredActivity),
                bio: \(bio),
                friendsCount: \(friendsCount),
                trustScore: \(trustScore),
                totalSessions: \(totalSessions),
                totalDistanceKm: \(totalDistanceKm),
                avgIntensity: \(avgIntensity),
                isPrivate: \(isPrivate)
            )
            """
        }

    
    init(id: String) {
        self.id = id
        
    }

}

extension UserProfile {
    static let empty = UserProfile(id: "")
}
