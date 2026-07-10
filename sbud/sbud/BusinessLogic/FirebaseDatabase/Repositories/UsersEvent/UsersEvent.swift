//
//  UsersEvent.swift
//  sbud
//
//  Created by ahmed on 30/04/2026.
//

import Foundation
import SwiftUI

enum UsersEventStatus: String, Codable {
    case proposed = "Proposed"
    case confirmed = "Confirmed"
    case completed = "Completed"

    var color: Color {
        switch self {
        case .proposed:  return Color("palelime")
        case .confirmed: return Color(red: 0.0, green: 227.0/255.0, blue: 253.0/255.0)
        case .completed: return Color(red: 0.0, green: 227.0/255.0, blue: 253.0/255.0)
        }
    }

    var icon: String {
        switch self {
        case .proposed:  return "clock"
        case .confirmed: return "checkmark.seal.fill"
        case .completed: return "flag.checkered"
        }
    }
}

struct UsersEvent: Codable, Identifiable {
    var id       = UUID()
    var activityType: ActivityType    = .running
    var title:        String          = ""
    var eventImage:   String          = ""
    var status:       UsersEventStatus = .proposed
    var eventId:      String          = ""
    var isPublic:     Bool            = true

    enum CodingKeys: String, CodingKey {
        case activityType, title, eventImage, status, isPublic
    }
}
