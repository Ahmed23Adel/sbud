////
////  Wheel.swift
////  sbud
////
////  Created by ahmed on 27/12/2025.
////

import SwiftUI


struct FiltersView: View {
    @StateObject private var viewModel: FiltersViewModel
    
    init(availabilityFiltersResults: AvailabilityFiltersResults){
        self._viewModel = StateObject(wrappedValue: FiltersViewModel(availabilityFiltersResults: availabilityFiltersResults))
    }
    
    var body: some View {
        ZStack {
            Color.backgroundColor
            VStack {
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
    FiltersView(availabilityFiltersResults: AvailabilityFiltersResults())
}
