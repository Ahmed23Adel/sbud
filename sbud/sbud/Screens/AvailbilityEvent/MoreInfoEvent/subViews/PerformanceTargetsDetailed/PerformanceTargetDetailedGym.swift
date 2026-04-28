//
//  PerformanceTargetDetailedGym.swift
//  sbud
//
//  Created by ahmed on 25/04/2026.
//

import SwiftUI

struct PerformanceTargetDetailedGym: View {
    let t: ExtraArgsHolderGym
    var body: some View {
        HStack {
            SinglePerformanceTargetDetailed(
                targetHeader: "Day Type",
                unitHeader: "",
                targetValue: t.proposedDayType.rawValue)
        }
        .padding(.horizontal, 10)
    }
}

#Preview {
    PerformanceTargetDetailedGym(t: ExtraArgsHolderGym())
}
