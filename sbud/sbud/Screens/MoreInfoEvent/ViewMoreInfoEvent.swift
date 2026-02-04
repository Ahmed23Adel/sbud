//
//  MoreInfoEvent.swift
//  sbud
//
//  Created by ahmed on 02/02/2026.
//

import SwiftUI
import FirebaseFirestore
import Kingfisher
import Lottie

struct ViewMoreInfoEvent: View {
    @StateObject var viewModel: ViewModelMoreInfoEvent
    
    init(basicEvent: AvailabilityEvent){
        _viewModel = StateObject(wrappedValue: ViewModelMoreInfoEvent(event: basicEvent))
    }
    var body: some View {
        
        ZStack{
            Color.darkBackground
            VStack{
                KFImage(URL(string: viewModel.event.eventImage))
                    .placeholder{
                        ProgressView()
                    }
                    .resizable()
                    .scaledToFill()
                    .frame(height: 250)
                    .cornerRadius(16)
                
                if viewModel.event.isLoading{
                    LoadingView()
                } else{
                    DateLocationRow(isDateConfirmed: viewModel.event.isDateConfirmed, isLocationConfirmed: viewModel.event.isLocationConfirmed)
                        .padding(.vertical, 8)
                    
                }
                Spacer()
            }
            
        }
        .ignoresSafeArea()
    }
}

#Preview {
    ViewMoreInfoEvent(basicEvent: AvailabilityEvent(
        id: "cf5f3e6b-a62b-4c43-85f5-e47ca287419f",
        geoPoint: GeoPoint(latitude: 45.4642, longitude: 9.1900),
        dateLocationId: "milano_centro_001",
        activityType: "Coffee",
        startDateTime: Date().addingTimeInterval(3600),
        endDateTime: Date().addingTimeInterval(7200),
        createdAt: Date(),
        g: GeoLocation(geopoint: Coordinate(latitude: 43, longitude: 9.4), geohash: "u0ndx37j"),
        isDateConfirmed: true,
        isLocationConfirmed: false,
        isPublic: true,
        eventImage: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRtF1Gz_Xsh2r_DfO5JaLspe4oKYcEGo-myBg&s"
    ))
}
