//
//  FlattenedEventsList.swift
//  sbud
//
//  Created by ahmed on 07/02/2026.
//

import SwiftUI
import MapKit

struct ViewFlattenedEventsList: View {
    @StateObject var viewModel: ViewModelFlattenedEventsList
    
    init(region: MKCoordinateRegion, filterResutls: AvailabilityFiltersResults){
        _viewModel = StateObject(wrappedValue: ViewModelFlattenedEventsList(
            region: region, filterResults: filterResutls))
    }
    var body: some View {
        Group{
            if viewModel.isLoading{
                LoadingView()
            } else{
                VStack{
                    List{
                        ForEach(viewModel.events.indices, id: \.self){ index in
                            EventRow(event: viewModel.events[index])
                                .onAppear{
                                    if index == viewModel.events.count - 3 {
                                        viewModel.loadEventsPaginnated()
                                    }
                                }
                        }
                        .padding(64)
                        if viewModel.isLoadingNewPage{
                            Spacer()
                            ProgressView()
                        }
                    }
                    
                }
            }
        }
        .alert("Error", isPresented: $viewModel.showAlert) {
            Button("Ok", role: .cancel) {}
        } message: {
            Text(viewModel.alertMsg)
        }
        .ignoresSafeArea()
        
            
        
    }
}

struct EventRow: View{
    var event: Event
    var body: some View {
        Text("event \(String(event.eventId))")
    }
    
    
}

#Preview {
    ViewFlattenedEventsList(region: MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 43.99, longitude: 9.44),
        span: MKCoordinateSpan(
            latitudeDelta: 0.001,
            longitudeDelta: 0.001
        )
    ), filterResutls: AvailabilityFiltersResults())
}
