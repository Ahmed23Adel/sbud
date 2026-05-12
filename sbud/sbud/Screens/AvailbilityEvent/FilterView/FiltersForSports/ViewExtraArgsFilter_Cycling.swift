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
                header: "Power",
                unitHeader: "WATT",
                minValue: $filter.minPower,
                maxValue: $filter.maxPower
            )
            GenericRangeTarget(
                header: "Cadence",
                unitHeader: "RPM",
                minValue: $filter.minCadence,
                maxValue: $filter.maxCadence
            )
        }
    }
}
