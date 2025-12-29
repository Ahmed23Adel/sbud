//
//  AvailabilityAppCoordinator.swift
//  sbud
//
//  Created by ahmed on 27/12/2025.
//

import SwiftUI

struct AvailabilityAppCoordinator: View {
    @StateObject private var coordinator = AvailabilityCoordinator()
    @StateObject private var availaibilityFiltesrResults = AvailabilityFiltersResults()
    
    var body: some View {
        AvailbilityView(viewModel: AvailbilityViewModel(
            locationManager: LocationManager.shared,
            availabilityFiltersResults: availaibilityFiltesrResults
            
        ))
            .environmentObject(coordinator)
            .sheet(item: $coordinator.activeSheet){ sheetType in
                sheetContent(for: sheetType)
            }
    }
    
    @ViewBuilder
    private func sheetContent(for sheetType: AvailabilitySheetType) -> some View{
        switch sheetType{
        case .filter:
            FiltersView(availabilityFiltersResults: availaibilityFiltesrResults)
        }
    }
}

#Preview {
    AvailabilityAppCoordinator()
}
