//
//  PerformanceTargetDetailedSwimming.swift
//  sbud
//
//  Created by ahmed on 27/04/2026.
//

import SwiftUI

struct PerformanceTargetDetailedSwimming: View {
    let t: ExtraArgsHolderSwimming
    var body: some View {
        VStack(spacing: 10) {
            HStack(spacing: 10) {
                SinglePerformanceTargetDetailed(
                    targetHeader: "Distance",
                    unitHeader: "m",
                    targetValue: String(t.proposedDistanceInM))
                SinglePerformanceTargetDetailed(
                    targetHeader: "Pace",
                    unitHeader: "Min/100m",
                    targetValue: String(t.proposedPacePer100M))
            }
            HStack(spacing: 10) {
                SinglePerformanceTargetDetailed(
                    targetHeader: "Duration",
                    unitHeader: "Min",
                    targetValue: String(t.proposedDurationInMin))
                SinglePerformanceTargetDetailed(
                    targetHeader: "Stroke",
                    unitHeader: "",
                    targetValue: t.proposedStroke.rawValue)
            }
        }
        .padding(.horizontal, 10)
    }
}


#Preview("Swimming") { PerformanceTargetDetailedSwimming(t: ExtraArgsHolderSwimming()) }

