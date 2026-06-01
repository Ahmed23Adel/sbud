//
//  ExtraArgsRunning.swift
//  sbud
//
//  Created by ahmed on 06/03/2026.
//

import SwiftUI
import Combine

struct ViewExtraArgsRunning: View {
    @Bindable var args: ExtraArgsHolderRunning

    var body: some View {
        VStack(spacing: 16) {
            TextOptionSelector(
                header: "Running Type",
                selected: $args.proposedRunningType
            )
            GenericPerformanceTarget(
                targetHeader: "Target Distance",
                unitHeader: "KM",
                targetValue: $args.proposedDistance
            )
            GenericPerformanceTarget(
                targetHeader: "Target Pace",
                unitHeader: "MIN/KM",
                targetValue: $args.proposedPace
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
    ViewExtraArgsRunning(args: ExtraArgsHolderRunning())
}
