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
    
    var bio: String? = nil
    var isProfileCompleted: Bool = false
    var pushToken: String? = nil

    var age: Int? {
        guard let birthDate else { return nil }
        return Calendar.current.dateComponents([.year], from: birthDate, to: Date()).year
    }
    
    init(id: String) {
        self.id = id
    }

}
