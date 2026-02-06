//
//  IndividualAnnotationView.swift
//  sbud
//
//  Created by ahmed on 24/12/2025.
//

import SwiftUI
import FirebaseFirestore
import Kingfisher

struct IndividualAnnotationView: View {
    let event: AnchorAvailabilityEvent
    @EnvironmentObject private var coordinator: AvailabilityCoordinator
    let allowNavigation: Bool
    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                Image("anchor")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 44, height: 44)
                KFImage(URL(string: event.event.eventImage))
                    .placeholder {
                        ProgressView()
                    }
                    .resizable()
                    .scaledToFill()
                    .frame(width: 18, height: 18)
                    .clipShape(Circle())
                    .offset(y: -4)
            }
            .popUp()

        }
        .onTapGesture {
            if allowNavigation{
                coordinator.push(.moreInfoEvent(event.event as! AvailabilityEvent))
            }
        }
        
    }
}

#Preview {
    IndividualAnnotationView(event:
        AnchorAvailabilityEvent(
            event: AvailabilityEvent(
                id: "cf5f3e6b-a62b-4c43-85f5-e47ca287419f",
                geoPoint: GeoPoint(latitude: 45.4642, longitude: 9.1900),
                dateLocationId: "milano_centro_001",
                activityType: "Coffee",
                startDateTime: Date().addingTimeInterval(3600), // 1 hour from now
                endDateTime: Date().addingTimeInterval(7200),   // 2 hours from now
                createdAt: Date(),
                g: GeoLocation(geopoint: Coordinate(latitude: 43, longitude: 9.4), geohash: "u0ndx37j"),
                isDateConfirmed: true,
                isLocationConfirmed: false,
                isPublic: true,
                eventImage: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRtF1Gz_Xsh2r_DfO5JaLspe4oKYcEGo-myBg&s"
            )), allowNavigation: false
    )
}
