//
//  iconsAdaptor.swift
//  sbud
//
//  Created by ahmed on 24/01/2026.
//

import Foundation
import SwiftUI
struct IconsAdaptor{
    let activityType: ActivityType
    
    init(_ activityType: ActivityType){
        self.activityType = activityType
    }
    
    func convert() -> IconsBaseName{
        withAnimation(.easeInOut){
            switch activityType {
            case .running:
                return .running
            case .cycling:
                return .cycling
            case .gym:
                return .gym
            }
        }
        
    }
}
