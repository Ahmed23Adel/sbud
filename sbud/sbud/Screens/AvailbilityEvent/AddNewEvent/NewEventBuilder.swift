//
//  NewEventBuilder.swift
//  sbud
//
//  Created by ahmed on 31/03/2026.
//

import Foundation

@Observable
class NewEventBuilder{
    // MARK: Step1
    // TODO: To be replaced with user profile image
    var coverImgURL: String = "https://images.unsplash.com/photo-1654110455429-cf322b40a906?fm=jpg&q=60&w=3000&auto=format&fit=crop&ixlib=rb-4.1.0&ixid=M3wxMjA3fDB8MHxzZWFyY2h8Mnx8cHJvZmlsZSUyMHBpY3R1cmV8ZW58MHx8MHx8fDA%3D"
    var title: String = ""
    var description: String = ""
    var activityType: ActivityType = .running
    var activityExtraArgs = NewEventExtraArgsHoder()
    // MARK: Step2
    var isEventPublic = true
    var joiningCondition: JoinCondition = .requestFromCreator
    var eventCapacity = "150"
    
}
