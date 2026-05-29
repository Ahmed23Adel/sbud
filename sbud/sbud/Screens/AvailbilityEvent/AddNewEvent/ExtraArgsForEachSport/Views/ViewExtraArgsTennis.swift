//
//  ViewExtraArgsTennis.swift
//  sbud
//
//  Created by ahmed on 26/04/2026.
//

import SwiftUI


struct ViewExtraArgsTennis: View {
    @Bindable var args: ExtraArgsHolderTennis

    var body: some View {
        VStack(spacing: 16) {
            TextOptionSelector(
                header: "Tennis Format",
                selected: $args.proposedFormat
            )
            GenericPerformanceTarget(
                targetHeader: "Sets",
                unitHeader: "SETS",
                targetValue: $args.proposedSets
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
    ViewExtraArgsTennis(args: ExtraArgsHolderTennis())
}
