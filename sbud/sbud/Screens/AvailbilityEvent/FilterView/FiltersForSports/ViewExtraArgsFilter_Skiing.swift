//
//  ViewExtraArgsFilter_Skiing.swift
//  sbud
//
//  Created by ahmed on 04/05/2026.
//

import SwiftUI

struct ViewExtraArgsFilterSkiing: View {
    @ObservedObject var filter: ExtraArgsFilterHolderSkiing

    var body: some View {
        VStack(spacing: 0) {
            GenericRangeTarget(
                header: "Avg Speed",
                unitHeader: "KM/H",
                minValue: $filter.minAvgSpeedInKmH,
                maxValue: $filter.maxAvgSpeedInKmH
            )
            GenericRangeTarget(
                header: "Avg Vertical Drop",
                unitHeader: "M",
                minValue: $filter.minAvgVerticalDropInM,
                maxValue: $filter.maxAvgVerticalDropInM
            )
            GenericRangeTargetInt(
                header: "Number of Runs",
                unitHeader: "RUNS",
                minValue: $filter.minNumberOfRuns,
                maxValue: $filter.maxNumberOfRuns
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
