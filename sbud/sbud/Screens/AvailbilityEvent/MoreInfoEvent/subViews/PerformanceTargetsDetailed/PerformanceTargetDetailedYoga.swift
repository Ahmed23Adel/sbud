//
//  PerformanceTargetDetailedYoga.swift
//  sbud
//
//  Created by ahmed on 27/04/2026.
//

import SwiftUI

struct PerformanceTargetDetailedYoga: View {
    let t: ExtraArgsHolderYoga
    var body: some View {
        VStack{
            HStack(spacing: 10) {
                SinglePerformanceTargetDetailed(
                    targetHeader: "Duration",
                    unitHeader: "Min",
                    targetValue: String(t.proposedDurationInMin))
                SinglePerformanceTargetDetailed(
                    targetHeader: "Intensity",
                    unitHeader: "/ 10",
                    targetValue: String(t.proposedIntensityLevel))
            }
            HStack(spacing: 10) {
                SinglePerformanceTargetDetailed(
                    targetHeader: "Style",
                    unitHeader: "",
                    targetValue: t.proposedStyle.rawValue)
            }
        }
        .padding(.horizontal, 10)
    }
}

#Preview("Yoga"){
    PerformanceTargetDetailedYoga(t: ExtraArgsHolderYoga())
}

