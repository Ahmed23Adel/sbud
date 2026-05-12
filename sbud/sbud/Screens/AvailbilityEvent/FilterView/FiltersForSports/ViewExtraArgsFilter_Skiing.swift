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
                header: "Speed",
                unitHeader: "KM/H",
                minValue: $filter.minSpeed,
                maxValue: $filter.maxSpeed
            )
            GenericRangeTarget(
                header: "Vertical Drop",
                unitHeader: "M",
                minValue: $filter.minDrop,
                maxValue: $filter.maxDrop
            )
        }
    }
}
