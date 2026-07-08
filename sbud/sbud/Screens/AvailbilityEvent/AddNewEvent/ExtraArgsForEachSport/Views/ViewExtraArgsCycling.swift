//
//  ExtraArgsCycling.swift
//  sbud
//
//  Created by ahmed on 06/03/2026.
//

import SwiftUI

struct ViewExtraArgsCycling: View {
    @Bindable var args: ExtraArgsHolderCycling

    var body: some View {
        VStack(spacing: 16) {
            TextOptionSelector(
                header: "Cycling Type",
                selected: $args.proposedCyclingType
            )
            GenericPerformanceTarget(
                targetHeader: "Target Distance",
                unitHeader: "KM",
                targetValue: $args.proposedDistanceInKm
            )
            GenericPerformanceTarget(
                targetHeader: "Target Speed",
                unitHeader: "KM/H",
                targetValue: $args.proposedSpeedInKmH
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
    ViewExtraArgsCycling(args: ExtraArgsHolderCycling())
}
