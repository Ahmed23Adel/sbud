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
    @StateObject var viewModel = AvailbilityViewModel(locationManager: LocationManager.shared)
    
    var body: some View {
        ZStack {
            Color.backgroundColor
            AnchorMapConditionalView(
                anchorAvailabilityEvents: viewModel.anchorAvailabilityEvents,
                anchorClusters: viewModel.anchorsClusters,
                shouldShowIndividuals: viewModel.shouldShowIndividuals,
                cameraPosition: $viewModel.cameraPosition,
                onCameraChangeFunc: viewModel.handleMapCameraChange)
            
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
    AvailbilityView()
}
