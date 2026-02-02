////
////  Wheel.swift
////  sbud
////
////  Created by ahmed on 27/12/2025.
////

import SwiftUI

struct FiltersView: View {
    @StateObject private var viewModel: FiltersViewModel

    init(availabilityFiltersResults: Binding<AvailabilityFiltersResults>) {
        self._viewModel = StateObject(
            wrappedValue: FiltersViewModel(
                availabilityFiltersResults: availabilityFiltersResults))
    }

    var body: some View {
        ZStack {
            FloatingIconsBackground(iconBaseName: IconsAdaptor(viewModel.selectedActivityType).convert())
                .animation(.easeInOut, value: viewModel.selectedActivityType)
            VStack {
                VStack {
                    DatePicker(
                        "Start date & Time",
                        selection: $viewModel.availabilityFiltersResults.startDateTime,
                        displayedComponents: [.date, .hourAndMinute]
                    )
                    .datePickerStyle(.compact)
                    .font(.headline)
                    .tint(.mainColor)

                    DatePicker(
                        "End date & Time",
                        selection: $viewModel.availabilityFiltersResults.endDateTime,
                        displayedComponents: [.date, .hourAndMinute]
                    )
                    .datePickerStyle(.compact)
                    .font(.headline)
                    .tint(.mainColor)
                }

                .padding()
                .background(
                    Color.backgroundColor.overlay(Color.white.opacity(0.5))
                )
                .cornerRadius(32)
                .padding(16)
                .popUp()

                Spacer()

                Wheel(
                    imageNames: viewModel.icons,
                    names: viewModel.activityNames,
                    selectedIndex: $viewModel.selectedActivityIndex
                )
                .offset(y: 120)
            }

        }
        .ignoresSafeArea()
    }
}

#Preview {
    @Previewable @State var tmp = AvailabilityFiltersResults()
    FiltersView(availabilityFiltersResults: $tmp)
}
