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
        VStack{
            HStack(spacing: 10) {
                SinglePerformanceTargetDetailed(
                    targetHeader: "Type",
                    unitHeader: "",
                    targetValue: t.proposedCyclingType.rawValue)
                SinglePerformanceTargetDetailed(
                    targetHeader: "Power",
                    unitHeader: "W",
                    targetValue: String(t.proposedPowerInWatt))
            }
            HStack(spacing: 10){
                SinglePerformanceTargetDetailed(
                    targetHeader: "Cadence",
                    unitHeader: "RPM",
                    targetValue: String(t.proposedCadenceInRPM))
            }
        }
        .padding(.horizontal, 10)
    }
}

#Preview {
    PerformanceTargetDetailedCycling(t: ExtraArgsHolderCycling())
}
