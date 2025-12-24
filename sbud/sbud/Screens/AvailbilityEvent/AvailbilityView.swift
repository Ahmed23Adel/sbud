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
            
            Map(position: $viewModel.cameraPosition) {
                UserAnnotation()
                
                if viewModel.shouldShowIndividuals{
                    ForEach(viewModel.individualsAnchors) { event in
                        Annotation(
                            "ev",
                            coordinate: CLLocationCoordinate2D(
                                latitude: event.event.geoPoint.latitude,
                                longitude: event.event.geoPoint.longitude
                            )
                        ) {
                            
                            IndividualAnnotationView(event: event)
                                .onAppear {
                                    print("✅ Annotation rendered at: [\(event.event.geoPoint.latitude), \(event.event.geoPoint.longitude)]")
                                }
                        }
                    }
                    
                } else{
                    ForEach(viewModel.anchorsClusters) { cluster in
                        Annotation(
                            "\(cluster.count) available",
                            coordinate: CLLocationCoordinate2D(
                                latitude: cluster.cluster.location.latitude,
                                longitude: cluster.cluster.location.longitude
                            )
                        ) {
                            
                            ClusterAnnotationView(count: cluster.count)
                        }
                    }
                }
                
            }
            .onMapCameraChange { context in
                viewModel.handleMapCameraChange(context.region)
            }
            .mapStyle(.standard(elevation: .realistic))
            .mapControls {
                MapUserLocationButton()
                MapCompass()
                MapScaleView()
                
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
    AvailbilityView()
}
