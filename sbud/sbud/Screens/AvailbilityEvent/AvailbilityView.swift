//
//  AvailbilityView.swift
//  sbud
//
//  Created by ahmed on 21/12/2025.
//

import SwiftUI
import MapKit

struct AvailbilityView: View {
    @StateObject var viewModel = AvailbilityViewModel(locationManager: LocationManager())
    var body: some View {
        ZStack{
            Color.backgroundColor
            Map(position: $viewModel.cameraPosition){
                
            }
            .mapControls {
                MapUserLocationButton()
            }
            
        }
    }
}

#Preview {
    AvailbilityView()
}
