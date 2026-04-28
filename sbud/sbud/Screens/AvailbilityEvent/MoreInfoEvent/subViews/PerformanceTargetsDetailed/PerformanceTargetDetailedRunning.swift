//
//  PerformanceTargetDetailedRunning.swift
//  sbud
//
//  Created by ahmed on 25/04/2026.
//

import SwiftUI

struct PerformanceTargetDetailedRunning: View {
    let t: ExtraArgsHolderRunning
    var body: some View {
        VStack(spacing: 10) {
            HStack(spacing: 10) {
                SinglePerformanceTargetDetailed(
                    targetHeader: "Distance",
                    unitHeader: "Km",
                    targetValue: String(t.proposedDistance))
                SinglePerformanceTargetDetailed(
                    targetHeader: "Pace",
                    unitHeader: "Min/Km",
                    targetValue: String(t.proposedPace))
            }
            HStack(spacing: 10) {
                SinglePerformanceTargetDetailed(
                    targetHeader: "Type",
                    unitHeader: "",
                    targetValue: t.proposedRunningType.rawValue)
            }
        }
        .padding(.horizontal, 10)
    }
}

//
//#Preview {
//    PerformanceTargetDetailedRunning(performanceTargets: ResponseActivityDetailsRunning(
//        targetDistanceInKm: 6.5,
//        targetPace: 5.5
//    ))
//}
