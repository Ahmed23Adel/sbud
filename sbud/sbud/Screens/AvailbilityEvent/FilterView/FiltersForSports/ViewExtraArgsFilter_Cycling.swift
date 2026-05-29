//
//  ViewExtraArgsFilter_Cycling.swift
//  sbud
//
//  Created by ahmed on 04/05/2026.
//

import SwiftUI

struct ViewExtraArgsFilterCycling: View {
    @ObservedObject var filter: ExtraArgsFilterHolderCycling

    var body: some View {
        VStack(spacing: 0) {
            OptionalTextOptionSelector(
                header: "Cycling Type",
                selected: $filter.cyclingType
            )
            GenericRangeTarget(
                header: "Distance",
                unitHeader: "KM",
                minValue: $filter.minDistanceInKm,
                maxValue: $filter.maxDistanceInKm
            )
            GenericRangeTarget(
                header: "Speed",
                unitHeader: "KM/H",
                minValue: $filter.minSpeedInKmH,
                maxValue: $filter.maxSpeedInKmH
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
