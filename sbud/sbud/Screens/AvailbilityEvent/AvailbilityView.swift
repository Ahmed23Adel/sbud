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
            
            AnchorMapConditionalView(
                anchorAvailabilityEvents: viewModel.anchorAvailabilityEvents,
                anchorClusters: viewModel.anchorsClusters,
                shouldShowIndividuals: viewModel.shouldShowIndividuals,
                cameraPosition: $viewModel.cameraPosition,
                onCameraChangeFunc: viewModel.handleMapCameraChange)
        
            VStack {
                Spacer()
                HStack {
                    Spacer()
                    GlassFloatingButton(systemName: "line.3.horizontal.decrease"){
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
//
//#Preview {
//    AvailbilityView(viewModel: <#AvailbilityViewModel#>)
//}
