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
        }
        .ignoresSafeArea()
    }
}


#Preview {
    AvailbilityView()
}
