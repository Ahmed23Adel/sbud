//
//  PerformanceTargetDetailedHiking.swift
//  sbud
//
//  Created by ahmed on 27/04/2026.
//

import SwiftUI
struct PerformanceTargetDetailedHiking: View {
    let t: ExtraArgsHolderHiking
    var body: some View {
        VStack(spacing: 10) {
            HStack(spacing: 10) {
                SinglePerformanceTargetDetailed(
                    targetHeader: "Distance",
                    unitHeader: "Km",
                    targetValue: String(t.proposedDistanceInKm))
                SinglePerformanceTargetDetailed(
                    targetHeader: "Elev. Gain",
                    unitHeader: "m",
                    targetValue: String(t.proposedElevationGainInM))
            }
            HStack(spacing: 10) {
                SinglePerformanceTargetDetailed(
                    targetHeader: "Elev. Loss",
                    unitHeader: "m",
                    targetValue: String(t.proposedElevationLossInM))
                SinglePerformanceTargetDetailed(
                    targetHeader: "Max Alt.",
                    unitHeader: "m",
                    targetValue: String(t.proposedMaxAltitudeInM))
            }
            HStack(spacing: 10) {
                SinglePerformanceTargetDetailed(
                    targetHeader: "Duration",
                    unitHeader: "Min",
                    targetValue: String(t.proposedDurationInMin))
            }
        }
        .padding(.horizontal, 10)
    }
}

#Preview("Hiking"){
    PerformanceTargetDetailedHiking(t: ExtraArgsHolderHiking())
}

