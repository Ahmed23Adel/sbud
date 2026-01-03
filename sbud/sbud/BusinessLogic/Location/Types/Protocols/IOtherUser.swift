//
//  IUser.swift
//  sbud
//
//  Created by ahmed on 23/12/2025.
//

import Foundation

protocol IOtherUser: Identifiable, Identifiable, Equatable{
    var id: String { get }
    var activities: [ActivityTypes] { get }
    var experienceLevels: [ExperienceLevels] { get }
    var bio: String { get }
    var birthDate: Date { get }
    var createdAt: Date { get }
    var lastActiveAt: Date { get }
    var primaryActivity: ActivityTypes { get }
    var profilePicture: String { get }
    var totalWorkouts: Int { get }
    var timeZone: String { get }
    
    
}
