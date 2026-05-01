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
        NavigationStack(path: $coordinator.navigationPath){
            AvailbilityView(viewModel: AvailbilityViewModel(
                locationManager: LocationManager.shared,
                availabilityFiltersResults: availaibilityFiltesrResults
            ))
            .ignoresSafeArea()
            .toolbar(.hidden, for: .navigationBar)
            .navigationDestination(for: AvailabilityNavigationDestination.self){ destination in
                destinationView(for: destination)
                    .environmentObject(coordinator)  
            }
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
        .ignoresSafeArea()
    }

    @ViewBuilder
    private func sheetContent(for sheetType: AvailabilitySheetType) -> some View {
        switch sheetType {
        case .filter:
            FiltersView(availabilityFiltersResults: $availaibilityFiltesrResults)
        }
    }

    @ViewBuilder
    private func destinationView(for destination: AvailabilityNavigationDestination) -> some View {
        switch destination {
        case .moreInfoEvent(let eventId):
            ViewMoreInfoEvent(eventId: eventId)
        case .addNewEvent:
            CoordinatorAddNewEvent()
        case .creatorProfile(let userId):
            ProfileView(userId: userId, onBack: { coordinator.pop() })
                .toolbar(.hidden, for: .navigationBar)
        case .chat(let user, let eventId): // ADD routing
            ChatView(user: user, eventId: eventId)
        }
    }
}

#Preview {
    AvailabilityAppCoordinator()
}
