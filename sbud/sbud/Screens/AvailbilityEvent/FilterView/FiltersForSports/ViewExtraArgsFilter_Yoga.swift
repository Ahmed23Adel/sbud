//
//  ViewExtraArgsFilter_Yoga.swift
//  sbud
//
//  Created by ahmed on 04/05/2026.
//

import SwiftUI
struct ViewExtraArgsFilterYoga: View {
    @ObservedObject var filter: ExtraArgsFilterHolderYoga

    var body: some View {
        VStack(spacing: 0) {
            OptionalTextOptionSelector(
                header: "Style",
                selected: $filter.style
            )
            GenericRangeTarget(
                header: "Duration",
                unitHeader: "MIN",
                minValue: $filter.minDurationInMin,
                maxValue: $filter.maxDurationInMin
            )
            GenericRangeTarget(
                header: "Intensity",
                unitHeader: "1–10",
                minValue: $filter.minIntensity,
                maxValue: $filter.maxIntensity
            )
        }
    }
}
