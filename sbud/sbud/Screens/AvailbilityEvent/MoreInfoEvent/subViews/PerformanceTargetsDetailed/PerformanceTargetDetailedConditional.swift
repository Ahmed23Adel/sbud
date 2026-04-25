//
//  PerformanceTargetDetailedRunning.swift
//  sbud
//
//  Created by ahmed on 25/04/2026.
//

import SwiftUI

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
            }
        }
    }
}

#Preview {
    PerformanceTargetDetailedConditional(activityDetails: .sampleRunning)
}
