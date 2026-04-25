//
//  PerformanceTargetDetailedGym.swift
//  sbud
//
//  Created by ahmed on 25/04/2026.
//

import SwiftUI

struct PerformanceTargetDetailedGym: View {
    let performanceTargets: ResponseActivityDetailsGym
    var body: some View {
        SinglePerformanceTargetDetailed(
            targetHeader: "Day type",
            unitHeader: "",
            targetValue: performanceTargets.dayType!)
        .padding(.horizontal, 15)
    }
}

#Preview {
    PerformanceTargetDetailedGym(performanceTargets: ResponseActivityDetailsGym())
}
