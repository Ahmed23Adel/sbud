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
    var coverImgURL: String = ""
    var title: String = ""
    var description: String = ""
    var activityType: ActivityType = .running
    var activityExtraArgs = NewEventExtraArgsHoder()
    // MARK: Step2
    var isEventPublic = true
    var joiningCondition: JoinCondition = .requestFromCreator
    var eventCapacity = "150"
    
}
