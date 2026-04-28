//
//  PerformanceTargetDetailedTennis.swift
//  sbud
//
//  Created by ahmed on 27/04/2026.
//

import SwiftUI

struct PerformanceTargetDetailedTennis: View {
    let t: ExtraArgsHolderTennis
    var body: some View {
        VStack{
            HStack(spacing: 10) {
                SinglePerformanceTargetDetailed(
                    targetHeader: "Sets",
                    unitHeader: "",
                    targetValue: String(Int(t.proposedSets)))
                SinglePerformanceTargetDetailed(
                    targetHeader: "Duration",
                    unitHeader: "Min",
                    targetValue: String(t.proposedDurationInMin))
            }
            HStack(spacing: 10) {
                SinglePerformanceTargetDetailed(
                    targetHeader: "Format",
                    unitHeader: "",
                    targetValue: t.proposedFormat.rawValue)
            }
        }
        .padding(.horizontal, 10)
    }
}

#Preview("Tennis"){
    PerformanceTargetDetailedTennis(t: ExtraArgsHolderTennis())
}

