//
//  PerformanceTargetDetailedSkiing.swift
//  sbud
//
//  Created by ahmed on 27/04/2026.
//

import SwiftUI
struct PerformanceTargetDetailedSkiing: View {
    let t: ExtraArgsHolderSkiing
    var body: some View {
        VStack(spacing: 10) {
            HStack(spacing: 10) {
                SinglePerformanceTargetDetailed(
                    targetHeader: "Avg Speed",
                    unitHeader: "Km/h",
                    targetValue: String(t.proposedAvgSpeedInKmH))
                SinglePerformanceTargetDetailed(
                    targetHeader: "Avg Drop",
                    unitHeader: "m",
                    targetValue: String(t.proposedAvgVerticalDropInM))
            }
            HStack(spacing: 10) {
                SinglePerformanceTargetDetailed(
                    targetHeader: "Runs",
                    unitHeader: "",
                    targetValue: String(t.proposedNumberOfRuns))
                SinglePerformanceTargetDetailed(
                    targetHeader: "Duration",
                    unitHeader: "Min",
                    targetValue: String(t.proposedDurationInMin))
            }
        }
        .padding(.horizontal, 10)
    }
}


#Preview("Skiing"){
    PerformanceTargetDetailedSkiing(t: ExtraArgsHolderSkiing())
}

