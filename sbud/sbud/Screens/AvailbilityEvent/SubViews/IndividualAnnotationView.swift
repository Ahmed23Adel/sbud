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

    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                Image("anchor")
                    .resizable()
                    .scaledToFit()
                    .frame(width: 44, height: 44)
                KFImage(URL(string: event.event.ownerProfilePicture))
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
    }
}

#Preview {
    IndividualAnnotationView(event:
        AnchorAvailabilityEvent(
            event: AvailabilityEvent(
                id: "cf5f3e6b-a62b-4c43-85f5-e47ca287419f",
                geoPoint: GeoPoint(latitude: 45.43817043216585, longitude: 9.219661393563264),
                // siwftlint:disable:next line_length
                ownerProfilePicture: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcRtF1Gz_Xsh2r_DfO5JaLspe4oKYcEGo-myBg&s"))
    )
}
