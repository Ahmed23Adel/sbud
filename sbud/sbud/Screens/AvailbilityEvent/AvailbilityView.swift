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
                
                ForEach(viewModel.anchorsClusters) { cluster in
                    Annotation(
                        "\(cluster.cluster.count) available",
                        coordinate: CLLocationCoordinate2D(
                            latitude: cluster.cluster.location.latitude,
                            longitude: cluster.cluster.location.longitude
                        )
                    ) {
                        ClusterAnnotationView(count: cluster.cluster.count)
                            .onTapGesture {
                                // Handle cluster tap
                            }
                    }
                }
            }
            .mapStyle(.standard(elevation: .realistic))
            .mapControls {
                MapUserLocationButton()
                MapCompass()
                MapScaleView()
            }
            
            // Top overlay with info
            VStack {
                if let cityPrefix = GeohashService.shared.cityPrefix {
                    HStack {
                        Text("Area: \(cityPrefix)")
                            .font(.caption)
                            .padding(8)
                            .background(Color.black.opacity(0.7))
                            .foregroundColor(.white)
                            .cornerRadius(8)
                        
                        Spacer()
                        
                        Text("\(viewModel.anchorsClusters.count) clusters")
                            .font(.caption)
                            .padding(8)
                            .background(Color.black.opacity(0.7))
                            .foregroundColor(.white)
                            .cornerRadius(8)
                    }
                    .padding()
                }
                
                Spacer()
            }
            
            // Bottom button to fit all clusters
            VStack {
                Spacer()
                
                HStack {
                    Spacer()
                    
                    Button(action: {
                        viewModel.zoomToFitClusters()
                    }) {
                        Image(systemName: "scope")
                            .font(.title2)
                            .padding()
                            .background(Color.white)
                            .foregroundColor(.blue)
                            .clipShape(Circle())
                            .shadow(radius: 3)
                    }
                    .padding()
                }
            }
            
            
            
            
        }
        .ignoresSafeArea()
    }
}


#Preview {
    AvailbilityView()
}
