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
                
            case .cycling:
            case .gym:
            }
        }
    }
}

#Preview {
    PerformanceTargetDetailedConditional(activityDetails: .sampleRunning)
}
