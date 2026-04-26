//
//  PerformanceTargetDetailedRunning.swift
//  sbud
//
//  Created by ahmed on 25/04/2026.
//

import SwiftUI

// TODO: Implment PerformanceTargetDetailedX
struct PerformanceTargetDetailedConditional: View {
    var activityDetails: AnyActivityDetails
    var body: some View {
        HStack{
            switch activityDetails.value.activityType{
            case .running:
                PerformanceTargetDetailedRunning(performanceTargets: activityDetails.value as! ResponseActivityDetailsRunning)
            case .cycling:
                PerformanceTargetDetailedRunning(performanceTargets: activityDetails.value as! ResponseActivityDetailsRunning)
            case .gym:
                PerformanceTargetDetailedRunning(performanceTargets: activityDetails.value as! ResponseActivityDetailsRunning)
            case .skiing:
                PerformanceTargetDetailedRunning(performanceTargets: activityDetails.value as! ResponseActivityDetailsRunning)
            case .swimming:
                PerformanceTargetDetailedRunning(performanceTargets: activityDetails.value as! ResponseActivityDetailsRunning)
            case .hiking:
                PerformanceTargetDetailedRunning(performanceTargets: activityDetails.value as! ResponseActivityDetailsRunning)
            case .yoga:
                PerformanceTargetDetailedRunning(performanceTargets: activityDetails.value as! ResponseActivityDetailsRunning)
            case .tennis:
                PerformanceTargetDetailedRunning(performanceTargets: activityDetails.value as! ResponseActivityDetailsRunning)
            }
        }
    }
}

#Preview {
    PerformanceTargetDetailedConditional(activityDetails: .sampleRunning)
}
