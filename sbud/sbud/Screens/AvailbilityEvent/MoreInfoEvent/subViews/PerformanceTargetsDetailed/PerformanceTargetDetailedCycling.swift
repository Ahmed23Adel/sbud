//
//  PerformanceTargetDetailedCycling.swift
//  sbud
//
//  Created by ahmed on 25/04/2026.
//

import SwiftUI
struct PerformanceTargetDetailedCycling: View {
    let t: ExtraArgsHolderCycling
    var body: some View {
        VStack(spacing: 10) {
            HStack(spacing: 10) {
                SinglePerformanceTargetDetailed(
                    targetHeader: "Distance",
                    unitHeader: "Km",
                    targetValue: String(t.proposedDistanceInKm))
                SinglePerformanceTargetDetailed(
                    targetHeader: "Speed",
                    unitHeader: "Km/h",
                    targetValue: String(t.proposedSpeedInKmH))
            }
            HStack(spacing: 10) {
                SinglePerformanceTargetDetailed(
                    targetHeader: "Duration",
                    unitHeader: "Min",
                    targetValue: String(t.proposedDurationInMin))
                SinglePerformanceTargetDetailed(
                    targetHeader: "Type",
                    unitHeader: "",
                    targetValue: t.proposedCyclingType.rawValue)
            }
        }
        .padding(.horizontal, 10)
    }
}

#Preview {
    PerformanceTargetDetailedCycling(t: ExtraArgsHolderCycling())
}
