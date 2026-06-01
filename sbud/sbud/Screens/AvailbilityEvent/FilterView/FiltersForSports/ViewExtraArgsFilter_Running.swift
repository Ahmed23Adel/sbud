//
//  ViewExtraArgsFilter_Running.swift
//  sbud
//
//  Created by ahmed on 04/05/2026.
//

import SwiftUI

struct ViewExtraArgsFilterRunning: View {
    @ObservedObject var filter: ExtraArgsFilterHolderRunning

    var body: some View {
        VStack(spacing: 0) {
            OptionalTextOptionSelector(
                header: "Running Type",
                selected: $filter.runningType
            )
            GenericRangeTarget(
                header: "Distance",
                unitHeader: "KM",
                minValue: $filter.minDistanceInKm,
                maxValue: $filter.maxDistanceInKm
            )
            GenericRangeTarget(
                header: "Pace",
                unitHeader: "MIN/KM",
                minValue: $filter.minPace,
                maxValue: $filter.maxPace
            )
            GenericRangeTarget(
                header: "Duration",
                unitHeader: "MIN",
                minValue: $filter.minDurationInMin,
                maxValue: $filter.maxDurationInMin
            )
        }
    }
}
