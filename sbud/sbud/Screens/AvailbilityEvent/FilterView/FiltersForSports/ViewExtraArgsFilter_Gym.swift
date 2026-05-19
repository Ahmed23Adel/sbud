//
//  ViewExtraArgsFilter_Gym.swift
//  sbud
//
//  Created by ahmed on 04/05/2026.
//

import SwiftUI
import SwiftUI

struct ViewExtraArgsFilterGym: View {
    @ObservedObject var filter: ExtraArgsFilterHolderGym

    var body: some View {
        VStack(spacing: 0) {
            OptionalTextOptionSelector(
                header: "Day Type",
                selected: $filter.gymDayType
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
