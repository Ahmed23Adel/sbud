//
//  PerformanceTargetDetailedRunning.swift
//  sbud
//
//  Created by ahmed on 25/04/2026.
//

import SwiftUI

struct PerformanceTargetDetailedRunning: View {
    let performanceTargets: ResponseActivityDetailsRunning
    var body: some View {
        HStack(spacing: 10){
            SinglePerformanceTargetDetailed(
                targetHeader: "Distance",
                unitHeader: "Km",
                targetValue: String(performanceTargets.targetDistanceInKm!))
            .padding(.leading, 10)
            
            SinglePerformanceTargetDetailed(
                targetHeader: "Pace",
                unitHeader: "Min/Km",
                targetValue: String(performanceTargets.targetPace!))
            .padding(.trailing, 10)
        }
    }
}

#Preview {
    PerformanceTargetDetailedRunning(performanceTargets: ResponseActivityDetailsRunning(
        targetDistanceInKm: 6.5,
        targetPace: 5.5
    ))
}
