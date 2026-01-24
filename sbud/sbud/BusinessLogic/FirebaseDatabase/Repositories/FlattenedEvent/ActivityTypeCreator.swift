//
//  ActivityTypeCreator.swift
//  sbud
//
//  Created by ahmed on 24/01/2026.
//

import Foundation

struct ActivityTypeCreatorFromString{
    let activityTypeString:  String
    
    
    init(_ activityType: String){
        self.activityTypeString = activityType
    }
    
    func create() -> ActivityTypes{
        switch activityTypeString {
        case "Running":
            return .running
        case "Gym":
            return .gym
        case "Cycling":
            return .cycling
        default:
            return .running
        }
    }
    
    
}
