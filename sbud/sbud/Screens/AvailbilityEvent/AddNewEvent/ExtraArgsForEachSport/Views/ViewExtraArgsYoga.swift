//
//  ViewExtraArgsYoga.swift
//  sbud
//
//  Created by ahmed on 26/04/2026.
//

import SwiftUI

struct ViewExtraArgsYoga: View {
    @Bindable var args: ExtraArgsHolderYoga

    var body: some View {
        VStack(spacing: 16) {
            TextOptionSelector(
                header: "Yoga Style",
                selected: $args.proposedStyle
            )
            GenericPerformanceTarget(
                targetHeader: "Duration",
                unitHeader: "MIN",
                targetValue: $args.proposedDurationInMin
            )
            GenericPerformanceTarget(
                targetHeader: "Intensity Level",
                unitHeader: "1–10",
                targetValue: $args.proposedIntensityLevel
            )
        }
    }
}

#Preview {
    ViewExtraArgsYoga(args: ExtraArgsHolderYoga())
}
