//
//  FlattenedEventsList.swift
//  sbud
//
//  Created by ahmed on 07/02/2026.
//

import SwiftUI
import MapKit
import Kingfisher

struct ViewFlattenedEventsList: View {
    @StateObject var viewModel: ViewModelFlattenedEventsList
    @EnvironmentObject private var coordinator: AvailabilityCoordinator
    
    init(region: MKCoordinateRegion, filterResutls: AvailabilityFiltersResults){
        _viewModel = StateObject(wrappedValue: ViewModelFlattenedEventsList(
            region: region, filterResults: filterResutls))
    }
    var body: some View {
        ZStack{
            Color.darkBackground
            
            Group{
                if viewModel.isLoading{
                    LoadingView()
                } else{
                    VStack{
                        List{
                            ForEach(viewModel.events.indices, id: \.self) { index in
                                Group {
                                    EventRow(event: viewModel.events[index])
                                        .onAppear {
                                            if index == viewModel.events.count - 3 {
                                                viewModel.loadEventsPaginnated()
                                            }
                                        }
                                        .environmentObject(coordinator)
                                }
                                .listRowBackground(Color.backgroundColor)
                                .listRowInsets(EdgeInsets())
                            }
                            if viewModel.isLoadingNewPage{
                                Spacer()
                                ProgressView()
                            }
                        }
                        .padding(.bottom, 65)
                        .scrollContentBackground(.hidden)
                        .background(Color.darkBackground)
                        
                    }
                    .padding(.top, 60)
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
    @EnvironmentObject private var coordinator: AvailabilityCoordinator
    var event: AvailabilityEvent
    
    var body: some View {
        ZStack{
            Color.backgroundColor
            HStack{
                KFImage(URL(string: event.eventImage))
                    .placeholder {
                        ProgressView()
                    }
                    .resizable()
                    .scaledToFill()
                    .frame(width: 32, height: 32)
                    .clipShape(Circle())
                    .padding()
                
                VStack{
                    Text(event.creatorName)
                        .font(.title)
                        .foregroundColor(Color.white)
                }
                
                Spacer()
            }
        }
        .onTapGesture {
            coordinator.push(.moreInfoEvent(event))
        }
        .ignoresSafeArea()
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
