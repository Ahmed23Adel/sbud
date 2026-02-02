//
//  AvailabilityAppCoordinator.swift
//  sbud
//
//  Created by ahmed on 27/12/2025.
//

import SwiftUI
import UIKit

struct AvailabilityAppCoordinator: View {
    @StateObject private var coordinator = AvailabilityCoordinator()
    @State private var availaibilityFiltesrResults = AvailabilityFiltersResults()

    private let impactFeedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
    var body: some View {
        AvailbilityView(viewModel: AvailbilityViewModel(
            locationManager: LocationManager.shared,
            availabilityFiltersResults: availaibilityFiltesrResults

        ))
            .environmentObject(coordinator)
            .sheet(item: $coordinator.activeSheet) { sheetType in
                sheetContent(for: sheetType)
            }
            .onChange(of: coordinator.activeSheet) { _, newValue in
                if newValue != nil {
                    impactFeedbackGenerator.impactOccurred(intensity: 0.8)
                }
            }
    }

    @ViewBuilder
    private func sheetContent(for sheetType: AvailabilitySheetType) -> some View {
        switch sheetType {
        case .filter:
            FiltersView(availabilityFiltersResults: $availaibilityFiltesrResults)
        }
    }
}

#Preview {
    AvailabilityAppCoordinator()
}
