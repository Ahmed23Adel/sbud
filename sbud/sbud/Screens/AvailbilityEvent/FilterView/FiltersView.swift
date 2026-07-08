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
        NavigationStack{
            ZStack {
                FloatingIconsBackground(activityType: viewModel.selectedActivityType)
                    .animation(.easeInOut, value: viewModel.selectedActivityType)
                VStack {
                    FilterCard{
                        FilterSectionHeader(title: "When", icon: "calendar")
                        DatePicker(
                            "From",
                            selection: $viewModel.availabilityFiltersResults.startDateTime,
                            displayedComponents: [.date, .hourAndMinute]
                        )
                        .datePickerStyle(.compact)
                        .font(.subheadline)
                        .tint(.mainColor)
                        .accessibilityIdentifier("filters.startDatePicker")

                        DatePicker(
                            "Until",
                            selection: $viewModel.availabilityFiltersResults.endDateTime,
                            displayedComponents: [.date, .hourAndMinute]
                        )
                        .datePickerStyle(.compact)
                        .font(.subheadline)
                        .tint(.mainColor)
                        .accessibilityIdentifier("filters.endDatePicker")
                    }
                    .background(Color.backgroundColor)
                    .padding()
                    
                    NavigationLink {
                        ActivityFiltersView(viewModel: viewModel, filters: viewModel.availabilityFiltersResults)
                    } label: {
                        FilterCard {
                            HStack {
                                FilterSectionHeader(
                                    title: viewModel.selectedActivityType.rawValue.capitalized + " Filters",
                                    icon: AvailabilityConfig.icons[viewModel.selectedActivityIndex]
                                )
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundStyle(Color.mainColor)
                            }
                        }
                    }
                    .accessibilityIdentifier("filters.activityFiltersLink")
                    .background(Color.backgroundColor)
                    .padding(.horizontal)
                    .buttonStyle(.plain)

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
}

#Preview {
    @Previewable @State var tmp = AvailabilityFiltersResults()
    FiltersView(availabilityFiltersResults: $tmp)
}
