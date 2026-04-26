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
                selected: $args.cyclingType
            )
            GenericPerformanceTarget(
                targetHeader: "Target Power",
                unitHeader: "WATTS",
                targetValue: $args.proposedPowerInWatt
            )
            GenericPerformanceTarget(
                targetHeader: "Target Cadence",
                unitHeader: "RPM",
                targetValue: $args.proposedCadenceInRPM
            )
        }
    }
}

#Preview {
    ViewExtraArgsCycling(args: ExtraArgsHolderCycling())
}
