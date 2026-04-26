//
//  ViewExtraArgsHiking.swift
//  sbud
//
//  Created by ahmed on 26/04/2026.
//

import SwiftUI

struct ViewExtraArgsHiking: View {
    @Bindable var args: ExtraArgsHolderHiking

    var body: some View {
        VStack(spacing: 16) {
            GenericPerformanceTarget(
                targetHeader: "Target Distance",
                unitHeader: "KM",
                targetValue: $args.proposedDistanceInKm
            )
            GenericPerformanceTarget(
                targetHeader: "Elevation Gain",
                unitHeader: "M",
                targetValue: $args.proposedElevationGainInM
            )
        }
    }
}

#Preview {
    ViewExtraArgsHiking(args: ExtraArgsHolderHiking())
}
