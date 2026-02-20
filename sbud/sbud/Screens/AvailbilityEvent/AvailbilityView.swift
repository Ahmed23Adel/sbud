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
    // I will assign it from coordinator to pass filters
    @StateObject var viewModel: AvailbilityViewModel
    @EnvironmentObject private var coordinator: AvailabilityCoordinator

    var body: some View {
        ZStack {
            Color.backgroundColor
            TabView(selection: $viewModel.selectedTab){
                AnchorMapConditionalView(
                    anchorAvailabilityEvents: viewModel.anchorAvailabilityEvents,
                    anchorClusters: viewModel.anchorsClusters,
                    shouldShowIndividuals: viewModel.shouldShowIndividuals,
                    cameraPosition: $viewModel.cameraPosition,
                    onCameraChangeFunc: viewModel.handleMapCameraChange)
                .environmentObject(coordinator)
                .tag(0)
                
                ViewFlattenedEventsList(
                    region: viewModel.currentRegion ?? MKCoordinateRegion(
                        center: CLLocationCoordinate2D(latitude: 43.9, longitude: 9.4),
                        span: MKCoordinateSpan(
                            latitudeDelta: 0.001, longitudeDelta: 0.001
                        )
                    ),
                    filterResutls: viewModel.availabilityFiltersResults)
                .id(viewModel.listViewRefreshId)
                .tag(1)
            }
            .ignoresSafeArea()
            .tabViewStyle(.page(indexDisplayMode: .never))
            
            VStack{
                Picker("View mode", selection: $viewModel.selectedTab){
                    Text("Map")
                        .tag(0)
                    Text("List")
                        .tag(1)
                }
                .pickerStyle(.segmented)
                .padding()
                Spacer()
            }
            .onChange(of: viewModel.selectedTab){
                viewModel.updateListId()
            }
            .frame(width: UIConstants.bigCardWidth - 100)
            .offset(y: 30)
            
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    GlassFloatingButton(systemName: "line.3.horizontal.decrease") {
                        coordinator.showSheet(.filter)
                    }

                }
                .padding(.bottom, 100)
                .padding(.trailing, 16)

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
