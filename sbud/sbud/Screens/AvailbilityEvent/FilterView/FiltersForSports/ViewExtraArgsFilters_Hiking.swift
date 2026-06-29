//
//  ViewExtraArgsFilters_Hiking.swift
//  sbud
//
//  Created by ahmed on 04/05/2026.
//

import SwiftUI
struct ViewExtraArgsFilterHiking: View {
    @ObservedObject var filter: ExtraArgsFilterHolderHiking

    var body: some View {
        VStack(spacing: 0) {
            GenericRangeTarget(
                header: "Distance",
                unitHeader: "KM",
                minValue: $filter.minDistanceInKm,
                maxValue: $filter.maxDistanceInKm
            )
            GenericRangeTarget(
                header: "Elevation Gain",
                unitHeader: "M",
                minValue: $filter.minElevationGainInM,
                maxValue: $filter.maxElevationGainInM
            )
            GenericRangeTarget(
                header: "Elevation Loss",
                unitHeader: "M",
                minValue: $filter.minElevationLossInM,
                maxValue: $filter.maxElevationLossInM
            )
            GenericRangeTarget(
                header: "Max Altitude",
                unitHeader: "M",
                minValue: $filter.minAltitudeInM,
                maxValue: $filter.maxAltitudeInM
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
