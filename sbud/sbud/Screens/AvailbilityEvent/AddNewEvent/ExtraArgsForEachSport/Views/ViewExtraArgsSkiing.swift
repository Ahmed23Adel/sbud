//
//  ViewExtraArgsSkiing.swift
//  sbud
//
//  Created by ahmed on 26/04/2026.
//

import SwiftUI

struct ViewExtraArgsSkiing: View {
    @Bindable var args: ExtraArgsHolderSkiing

    var body: some View {
        VStack(spacing: 16) {
            GenericPerformanceTarget(
                targetHeader: "Avg Speed",
                unitHeader: "KM/H",
                targetValue: $args.proposedAvgSpeedInKmH
            )
            GenericPerformanceTarget(
                targetHeader: "Avg Vertical Drop",
                unitHeader: "M",
                targetValue: $args.proposedAvgVerticalDropInM
            )
            GenericPerformanceTargetInt(
                targetHeader: "Number of Runs",
                unitHeader: "RUNS",
                targetValue: $args.proposedNumberOfRuns
            )
            GenericPerformanceTarget(
                targetHeader: "Duration",
                unitHeader: "MIN",
                targetValue: $args.proposedDurationInMin
            )
        }
    }
}

#Preview {
    ViewExtraArgsSkiing(args: ExtraArgsHolderSkiing())
}
