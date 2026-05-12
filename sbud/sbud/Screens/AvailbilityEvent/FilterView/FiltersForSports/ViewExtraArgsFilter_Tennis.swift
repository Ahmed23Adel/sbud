//
//  ViewExtraArgsFilter_Tennis.swift
//  sbud
//
//  Created by ahmed on 04/05/2026.
//

import SwiftUI

struct ViewExtraArgsFilterTennis: View {
    @ObservedObject var filter: ExtraArgsFilterHolderTennis

    var body: some View {
        VStack(spacing: 0) {
            OptionalTextOptionSelector(
                header: "Format",
                selected: $filter.format
            )
            GenericRangeTarget(
                header: "Sets",
                unitHeader: "SETS",
                minValue: $filter.minSets,
                maxValue: $filter.maxSets
            )
            GenericRangeTarget(
                header: "Duration",
                unitHeader: "MIN",
                minValue: $filter.minDuration,
                maxValue: $filter.maxDuration
            )
        }
    }
}
