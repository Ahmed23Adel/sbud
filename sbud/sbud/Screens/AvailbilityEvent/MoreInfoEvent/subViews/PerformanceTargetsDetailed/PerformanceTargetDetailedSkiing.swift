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
        HStack(spacing: 10) {
            SinglePerformanceTargetDetailed(
                targetHeader: "Speed",
                unitHeader: "Km/h",
                targetValue: String(t.proposedSpeedInKmH))
            SinglePerformanceTargetDetailed(
                targetHeader: "Vertical Drop",
                unitHeader: "m",
                targetValue: String(t.proposedVerticalDropInM))
        }
        .padding(.horizontal, 10)
    }
}
#Preview("Skiing"){
    PerformanceTargetDetailedSkiing(t: ExtraArgsHolderSkiing())
}

