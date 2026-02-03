//
//  MoreInfoEvent.swift
//  sbud
//
//  Created by ahmed on 02/02/2026.
//

import SwiftUI
import FirebaseFirestore
import Kingfisher
struct ViewMoreInfoEvent: View {
    @StateObject var viewModel: ViewModelMoreInfoEvent
    
    init(basicEvent: AvailabilityEvent){
        _viewModel = StateObject(wrappedValue: ViewModelMoreInfoEvent(event: basicEvent))
    }
    var body: some View {
        
        ZStack{
            Color.backgroundColor
            VStack{
                KFImage(URL(string: viewModel.event.ownerProfilePicture))
                    .placeholder{
                        ProgressView()
                    }
                    .resizable()
                    .scaledToFill()
                    .frame(height: 250)
                    .cornerRadius(16)
                    
                Spacer()
                
                if viewModel.event.isLoading{
                    LoadingView()
                }
            }
            
        }
        .ignoresSafeArea()
    }
}

#Preview {
    ViewMoreInfoEvent(basicEvent: AvailabilityEvent(
        id: "dlksa;j309urjd",
        geoPoint: GeoPoint(latitude: 43.99, longitude: 9.44),
        ownerProfilePicture: "https://vastphotos.com/files/uploads/photos/10310/large-format-photo-print-of-mountains-and-lakes-l.jpg?v=20220712043521"
        
    ))
}
