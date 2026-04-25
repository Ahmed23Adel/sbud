//
//  PerformanceTargetDetailedCycling.swift
//  sbud
//
//  Created by ahmed on 25/04/2026.
//

import SwiftUI

struct PerformanceTargetDetailedCycling: View {
    let performanceTargets: ResponseActivityDetailsCycling
    var body: some View {
        HStack{
            SinglePerformanceTargetDetailed(
                targetHeader: "Power",
                unitHeader: "W",
                targetValue: String(performanceTargets.powerInWatt!))
            .padding(.leading, 10)
            
            SinglePerformanceTargetDetailed(
                targetHeader: "Cadence",
                unitHeader: "RPM",
                targetValue: String(performanceTargets.cadenceInRpm!))
            .padding(.trailing, 10)
        }
    }
}

#Preview {
    PerformanceTargetDetailedCycling(performanceTargets: ResponseActivityDetailsCycling(
        
    ))
}
