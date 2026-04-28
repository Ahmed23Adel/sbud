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
                targetHeader: "Target Speed",
                unitHeader: "KM/H",
                targetValue: $args.proposedSpeedInKmH
            )
            GenericPerformanceTarget(
                targetHeader: "Vertical Drop",
                unitHeader: "M",
                targetValue: $args.proposedVerticalDropInM
            )
        }
    }
}

#Preview {
    ViewExtraArgsSkiing(args: ExtraArgsHolderSkiing())
}
