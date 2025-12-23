//
//  User.swift
//  sbud
//
//  Created by ahmed on 23/12/2025.
//

import Foundation

class OtherUser: IOtherUser{
    private(set) var id: String
    private(set) var activities: [ActivityTypes]
    private(set) var experienceLevels: [ExperienceLevels]
    private(set) var bio: String
    private(set) var birthDate: Date
    private(set) var createdAt: Date
    private(set) var lastActiveAt: Date
    private(set) var primaryActivity: ActivityTypes
    private(set) var profilePicture: String
    private(set) var totalWorkouts: Int
    private(set) var timeZone: String
    
    init(id: String, activities: [ActivityTypes], experienceLevels: [ExperienceLevels], bio: String, birthDate: Date, createdAt: Date, lastActiveAt: Date, primaryActivity: ActivityTypes, profilePicture: String, totalWorkouts: Int, timeZone: String) {
        self.id = id
        self.activities = activities
        self.experienceLevels = experienceLevels
        self.bio = bio
        self.birthDate = birthDate
        self.createdAt = createdAt
        self.lastActiveAt = lastActiveAt
        self.primaryActivity = primaryActivity
        self.profilePicture = profilePicture
        self.totalWorkouts = totalWorkouts
        self.timeZone = timeZone
    }
    
    static func == (lhs: OtherUser, rhs: OtherUser) -> Bool {
        lhs.id == rhs.id
    }
    
    
}
