//
//  ViewExtraArgsFilter_Swimming.swift
//  sbud
//
//  Created by ahmed on 04/05/2026.
//

import SwiftUI

struct ViewExtraArgsFilterSwimming: View {
    @ObservedObject var filter: ExtraArgsFilterHolderSwimming

    var body: some View {
        VStack(spacing: 0) {
            OptionalTextOptionSelector(
                header: "Stroke",
                selected: $filter.stroke
            )
            GenericRangeTarget(
                header: "Distance",
                unitHeader: "M",
                minValue: $filter.minDistance,
                maxValue: $filter.maxDistance
            )
            GenericRangeTarget(
                header: "Pace",
                unitHeader: "MIN/100M",
                minValue: $filter.minPace,
                maxValue: $filter.maxPace
            )
        }
    }
}
