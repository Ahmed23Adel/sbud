//
//  ViewExtraArgsSwimming.swift
//  sbud
//
//  Created by ahmed on 26/04/2026.
//

import SwiftUI

struct ViewExtraArgsSwimming: View {
    @Bindable var args: ExtraArgsHolderSwimming

    var body: some View {
        VStack(spacing: 16) {
            TextOptionSelector(
                header: "Swimming Stroke",
                selected: $args.proposedStroke,
            )
            
            GenericPerformanceTarget(
                targetHeader: "Target Distance",
                unitHeader: "M",
                targetValue: $args.proposedDistanceInM
            )
            GenericPerformanceTarget(
                targetHeader: "Target Pace",
                unitHeader: "MIN/100M",
                targetValue: $args.proposedPacePer100M
            )
        }
    }
}

#Preview {
    ViewExtraArgsSwimming(args: ExtraArgsHolderSwimming())
}
