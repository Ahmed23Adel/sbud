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
                minValue: $filter.minDistance,
                maxValue: $filter.maxDistance
            )
            GenericRangeTarget(
                header: "Elevation Gain",
                unitHeader: "M",
                minValue: $filter.minElevation,
                maxValue: $filter.maxElevation
            )
        }
    }
}
