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
    @State var viewModel: ViewModelFlattenedEventsList
    @EnvironmentObject private var coordinator: AvailabilityCoordinator
    
    init(region: MKCoordinateRegion, filterResutls: AvailabilityFiltersResults){
        _viewModel = State(wrappedValue: ViewModelFlattenedEventsList(
            region: region, filterResults: filterResutls))
    }
    var body: some View {
        ZStack{
            Color.darkBackground
            
            Group{
                if viewModel.isLoading{
                    MidnightLoadingView(text: "Loading events")
                } else{
                    VStack{
                        List{
                            ForEach(viewModel.events.indices, id: \.self) { index in
                                Group {
                                    EventRow(event: viewModel.events[index])
                                        .onAppear {
                                            let count = viewModel.events.count
                                            if index == count - 3 {
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
// MARK: - EventRow

struct EventRow: View {
    @EnvironmentObject private var coordinator: AvailabilityCoordinator
    var event: PaginatedEvent

    private let accentColor = Color(red: 0.0, green: 227.0/255.0, blue: 253.0/255.0)

    private var dateRangeText: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        let start = formatter.string(from: event.startDate)
        formatter.dateFormat = "MMM d, HH:mm"
        let end = formatter.string(from: event.endDate)
        return "\(start) → \(end)"
    }

    var body: some View {
        HStack(spacing: 0) {

            // Left accent bar
            Rectangle()
                .fill(accentColor)
                .frame(width: 3)

            HStack(spacing: 12) {

                // Avatar
                KFImage(URL(string: event.eventImage))
                    .placeholder { ProgressView() }
                    .resizable()
                    .scaledToFill()
                    .frame(width: 52, height: 52)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(accentColor.opacity(0.4), lineWidth: 1.5))

                // Main content
                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Image(systemName: event.activityType.icon)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(accentColor)

                        Text(event.activityType.rawValue)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(accentColor)

                        Spacer()

                        // Visibility badge
                        Text(event.isPublic ? "Public" : "Only friends")
                            .font(.system(size: 10))
                            .foregroundColor(event.isPublic ? .black : Color.mainColor)
                            .padding(.vertical, 5)
                            .padding(.horizontal, 10)
                            .background(event.isPublic ? Color(red: 0, green: 227/255, blue: 253/255) : Color.mainColor)
                            .clipShape(RoundedRectangle(cornerRadius: UIConstants.cornerRadius))
                    }

                    Text(event.creatorName)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .lineLimit(1)

                    HStack(spacing: 4) {
                        Image(systemName: "calendar")
                            .font(.system(size: 11))
                            .foregroundColor(.white.opacity(0.5))
                        Text(dateRangeText)
                            .font(.system(size: 12))
                            .foregroundColor(.white.opacity(0.6))

                        if !event.isDateConfirmed {
                            Text("· TBC")
                                .font(.system(size: 11, weight: .medium))
                                .foregroundColor(.yellow.opacity(0.8))
                        }
                    }
                }

                Spacer()

                // Options count
                VStack(spacing: 2) {
                    Text("\(event.numFlattenedEvents)")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundColor(accentColor)
                    Text("options")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.white.opacity(0.5))
                        .textCase(.uppercase)
                        .tracking(0.5)
                }
                .frame(width: 52)
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 14)
        }
        .background(Color.backgroundColor)
        .onTapGesture {
            coordinator.showMoreInfo(eventId: event.eventId)
        }
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
