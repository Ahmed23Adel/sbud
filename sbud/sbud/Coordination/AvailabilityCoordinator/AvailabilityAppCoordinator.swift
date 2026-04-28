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
    @StateObject private var availabilityViewModel = AvailbilityViewModel(
        locationManager: LocationManager.shared,
        availabilityFiltersResults: AvailabilityFiltersResults()
    )

    private let impactFeedbackGenerator = UIImpactFeedbackGenerator(style: .medium)

    var body: some View {
        NavigationStack(path: $coordinator.navigationPath) {
            AvailbilityView(viewModel: availabilityViewModel)
                .ignoresSafeArea()
                .toolbar(.hidden, for: .navigationBar)
                .navigationDestination(for: AvailabilityNavigationDestination.self) { destination in
                    destinationView(for: destination)
                }
                .environmentObject(coordinator)
                .sheet(item: Binding(
                    get: {
                        if case .filter = coordinator.activeSheet { return coordinator.activeSheet }
                        return nil
                    },
                    set: { coordinator.activeSheet = $0 }
                )) { sheetType in
                    sheetContent(for: sheetType)
                }
                .onChange(of: coordinator.activeSheet?.id) { _, newValue in
                    if newValue != nil {
                        impactFeedbackGenerator.impactOccurred(intensity: 0.8)
                    }
                }
        }
        .ignoresSafeArea()
    }

    @ViewBuilder
    private func sheetContent(for sheetType: AvailabilitySheetType) -> some View {
        switch sheetType {
        case .filter:
            FiltersView(availabilityFiltersResults: $availaibilityFiltesrResults)
        case .eventPreview:
            EmptyView()
        }
    }

    @ViewBuilder
    private func destinationView(for destination: AvailabilityNavigationDestination) -> some View {
        switch destination {
        case .moreInfoEvent(let eventId):
            ViewMoreInfoEvent(eventId: eventId)
        case .addNewEvent:
            CoordinatorAddNewEvent()
        }
    }
}

#Preview {
    AvailabilityAppCoordinator()
}
