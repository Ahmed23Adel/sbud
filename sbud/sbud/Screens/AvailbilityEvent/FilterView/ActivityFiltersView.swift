//
//  ActivityFiltersView.swift
//  sbud
//
//  Created by ahmed on 04/05/2026.
//

import SwiftUI

struct ActivityFiltersView: View {
    @ObservedObject var viewModel: FiltersViewModel
    @ObservedObject var filters: AvailabilityFiltersResults 
    @FocusState private var isAnyFieldFocused: Bool

    private let scaledDownSize: CGFloat = 0.3

    var body: some View {
        ZStack(alignment: .bottom) {

            FloatingIconsBackground(activityType: viewModel.selectedActivityType)
                .animation(.easeInOut, value: viewModel.selectedActivityType)
                .ignoresSafeArea()

            ScrollView {
                VStack(spacing: 20) {
                    Spacer().frame(height: 8)
                    
                    FilterCard{
                        FilterSectionHeader(title: "Gender", icon: "person.2")
                        
                        OptionalTextOptionSelector(
                            header: "",
                            selected: $viewModel.availabilityFiltersResults.gender
                        )
                    }
                    .background(Color.backgroundColor)
                    
                    FilterCard {
                        FilterSectionHeader(
                            title: viewModel.selectedActivityType.rawValue.capitalized + " Filters",
                            icon: AvailabilityConfig.icons[viewModel.selectedActivityIndex]
                        )
                        sportFilterView
                            .focused($isAnyFieldFocused)
                    }
                    .background(Color.backgroundColor)

                    Spacer().frame(height: 300)
                }
                .padding(.horizontal, 16)
            }
            .scrollDismissesKeyboard(.interactively)

            
        }
        .padding(.top, 40)
        .ignoresSafeArea()
        .navigationTitle("Activity Filters")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItemGroup(placement: .keyboard) {
                Spacer()
                Button {
                    isAnyFieldFocused = false
                } label: {
                    Image(systemName: "keyboard.chevron.compact.down")
                        .foregroundStyle(Color.mainColor)
                }
            }
        }
    }

    @ViewBuilder
    private var sportFilterView: some View {
        let f = viewModel.availabilityFiltersResults
        switch viewModel.selectedActivityType {
        case .running:  ViewExtraArgsFilterRunning(filter: f.runningFilter)
        case .cycling:  ViewExtraArgsFilterCycling(filter: f.cyclingFilter)
        case .gym:      ViewExtraArgsFilterGym(filter: f.gymFilter)
        case .skiing:   ViewExtraArgsFilterSkiing(filter: f.skiingFilter)
        case .swimming: ViewExtraArgsFilterSwimming(filter: f.swimmingFilter)
        case .hiking:   ViewExtraArgsFilterHiking(filter: f.hikingFilter)
        case .yoga:     ViewExtraArgsFilterYoga(filter: f.yogaFilter)
        case .tennis:   ViewExtraArgsFilterTennis(filter: f.tennisFilter)
        }
    }
}

//
//#Preview {
//    ActivityFiltersView()
//}
