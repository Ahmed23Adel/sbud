//
//  AvailbilityView.swift
//  sbud
//
//  Created by ahmed on 21/12/2025.
//

import SwiftUI
import MapKit
internal import FirebaseFirestoreInternal

struct AvailbilityView: View {
    @StateObject var viewModel = AvailbilityViewModel(
        locationManager: LocationManager.shared,
        availabilityFiltersResults: AvailabilityFiltersResults())
    @EnvironmentObject private var coordinator: AvailabilityCoordinator

    var body: some View {
        ZStack {
            // Map view - always rendered, hidden when not selected
            AnchorMapConditionalView(
                anchorAvailabilityEvents: viewModel.anchorAvailabilityEvents,
                anchorClusters: viewModel.anchorsClusters,
                shouldShowIndividuals: viewModel.shouldShowIndividuals,
                cameraPosition: $viewModel.cameraPosition,
                onCameraChangeFunc: viewModel.handleMapCameraChange)
            .ignoresSafeArea()
            .environmentObject(coordinator)
            .opacity(viewModel.selectedTab == 0 ? 1 : 0)

            // List view - always rendered, hidden when not selected
            ViewFlattenedEventsList(
                region: viewModel.currentRegion ?? MKCoordinateRegion(
                    center: CLLocationCoordinate2D(latitude: 43.9, longitude: 9.4),
                    span: MKCoordinateSpan(latitudeDelta: 0.001, longitudeDelta: 0.001)
                ),
                filterResutls: viewModel.availabilityFiltersResults)
            .id(viewModel.listViewRefreshId)
            .ignoresSafeArea()
            .opacity(viewModel.selectedTab == 1 ? 1 : 0)
            .environmentObject(coordinator)

            // Segmented picker
            VStack {
                Picker("View mode", selection: $viewModel.selectedTab) {
                    Text("Map").tag(0)
                    Text("List").tag(1)
                }
                .pickerStyle(.segmented)
                .padding()
                .onChange(of: viewModel.selectedTab) {
                    viewModel.updateListId()
                }
                Spacer()
            }
            .frame(width: UIConstants.bigCardWidth - 100)
            .offset(y: 40)

            // Filter button
            VStack {
                Spacer()
                HStack {
                    GlassFloatingButton(systemName: "plus") {
                        coordinator.showAddNewEvent()
                    }
                    Spacer()
                    GlassFloatingButton(systemName: "line.3.horizontal.decrease") {
                        coordinator.showFilterSheet(availFilters: $viewModel.availabilityFiltersResults)
                    }
                }
                .padding(.bottom, 100)
                .padding(.trailing, 16)
                .padding(.leading, 16)
            }
        }
        .alert("Error", isPresented: $viewModel.showErrorAlert) {
            Button("Ok", role: .cancel) {}
        } message: {
            Text(viewModel.alertMsg)
        }
        .ignoresSafeArea()
    }
}
#Preview {
    AvailbilityView(viewModel: AvailbilityViewModel(
        locationManager: LocationManager.shared,
        availabilityFiltersResults: AvailabilityFiltersResults()))
}
