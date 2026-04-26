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
        HStack(spacing: 10) {
            SinglePerformanceTargetDetailed(
                targetHeader: "Distance",
                unitHeader: "Km",
                targetValue: String(t.proposedDistanceInKm))
            SinglePerformanceTargetDetailed(
                targetHeader: "Elevation",
                unitHeader: "m",
                targetValue: String(t.proposedElevationGainInM))
        }
        .padding(.horizontal, 10)
    }
}
#Preview("Hiking"){
    PerformanceTargetDetailedHiking(t: ExtraArgsHolderHiking())
}

