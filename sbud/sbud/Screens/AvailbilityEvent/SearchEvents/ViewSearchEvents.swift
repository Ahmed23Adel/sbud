//
//  ViewSearchEvents.swift
//  sbud
//
//  Created by ahmed on 26/05/2026.
//

import SwiftUI
import MapKit
import Kingfisher

struct ViewSearchEvents: View {
    @State var viewModel: ViewModelSearchEvents
    @EnvironmentObject private var coordinator: AvailabilityCoordinator

    var body: some View {
        ZStack {
            Color.darkBackground

            VStack(spacing: 0) {
                VStack(spacing: 12) {
                    Spacer()
                        .frame(height: 12)
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.white.opacity(0.5))

                        TextField("Search events by title", text: $viewModel.searchQuery)
                            .textFieldStyle(.plain)
                            .foregroundColor(.white)
                            .accessibilityIdentifier("search.queryField")
                            .onSubmit {
                                Task {
                                    await viewModel.performSearch()
                                }
                            }

                        if !viewModel.searchQuery.isEmpty {
                            Button(action: {
                                viewModel.searchQuery = ""
                                viewModel.searchResults = []
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.white.opacity(0.5))
                            }
                            .accessibilityIdentifier("search.clearButton")
                        }
                    }
                    .padding(.horizontal, 12)
                    .padding(.vertical, 10)
                    .background(Color.backgroundColor)
                    .cornerRadius(16)

                    HStack(spacing: 12) {
                        Text("Search Mode:")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(.white.opacity(0.7))

                        Button(action: { viewModel.useFilters = false }) {
                            Text("Title Only")
                                .font(.system(size: 12, weight: viewModel.useFilters ? .regular : .semibold))
                                .foregroundColor(viewModel.useFilters ? .white.opacity(0.5) : .mainColor)
                                .padding(.vertical, 6)
                                .padding(.horizontal, 12)
                                .background(viewModel.useFilters ? Color.clear : Color.mainColor.opacity(0.2))
                                .cornerRadius(6)
                        }

                        Button(action: {
                            if viewModel.filterResults != nil {
                                viewModel.useFilters = true
                            }
                        }) {
                            Text("With Filters")
                                .font(.system(size: 12, weight: viewModel.useFilters ? .semibold : .regular))
                                .foregroundColor(viewModel.useFilters ? .mainColor : .white.opacity(0.5))
                                .padding(.vertical, 6)
                                .padding(.horizontal, 12)
                                .background(viewModel.useFilters ? Color.mainColor.opacity(0.2) : Color.clear)
                                .cornerRadius(6)
                        }
                        .disabled(viewModel.filterResults == nil)
                        .opacity(viewModel.filterResults != nil ? 1.0 : 0.5)

                        Spacer()
                    }
                    .padding(.horizontal, 4)
                }
                .padding(14)
                .background(Color.darkBackground)

                Group {
                    if viewModel.isLoading && viewModel.searchResults.isEmpty {
                        MidnightLoadingView(text: "Searching events")
                    } else if viewModel.searchResults.isEmpty && !viewModel.searchQuery.isEmpty {
                        VStack(spacing: 12) {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 40))
                                .foregroundColor(.white.opacity(0.3))
                            Text("No events found")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white.opacity(0.6))
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.darkBackground)
                    } else if !viewModel.searchResults.isEmpty {
                        VStack {
                            List {
                                ForEach(Array(viewModel.searchResults.enumerated()), id: \.element.id) { index, event in
                                    Group {
                                        SearchEventRow(event: event)
                                            .onAppear {
                                                let count = viewModel.searchResults.count
                                                if index == count - 3 {
                                                    Task {
                                                        await viewModel.loadMoreResults()
                                                    }
                                                }
                                            }
                                            .environmentObject(coordinator)
                                    }
                                    .listRowBackground(Color.backgroundColor)
                                    .listRowInsets(EdgeInsets())
                                }
                                if viewModel.isLoadingNewPage {
                                    HStack {
                                        Spacer()
                                        ProgressView()
                                        Spacer()
                                    }
                                    .listRowBackground(Color.backgroundColor)
                                }
                            }
                            .padding(.bottom, 65)
                            .scrollContentBackground(.hidden)
                            .background(Color.darkBackground)
                        }
                    } else {
                        VStack(spacing: 20) {
                            Image(systemName: "magnifyingglass")
                                .font(.system(size: 40))
                                .foregroundColor(.white.opacity(0.3))
                            Text("Enter a title to search")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.white.opacity(0.6))
                        }
                        .frame(maxWidth: .infinity, maxHeight: .infinity)
                        .background(Color.darkBackground)
                    }
                }
            }
            .padding(.top, 60)
        }
        .alert("Error", isPresented: $viewModel.showAlert) {
            Button("Ok", role: .cancel) {}
        } message: {
            Text(viewModel.alertMsg)
        }
        .ignoresSafeArea()
        .onChange(of: viewModel.useFilters) { _, _ in
            Task {
                await viewModel.performSearch()
            }
        }
        .navigationTitle("Search Events")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("Search Events")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(.mainColor)
            }
        }
    }
}

// MARK: - SearchEventRow

struct SearchEventRow: View {
    @EnvironmentObject private var coordinator: AvailabilityCoordinator
    var event: SearchEventResult

    private let accentColor = Color(red: 0.0, green: 227.0/255.0, blue: 253.0/255.0)

    private static let startFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "MMM d"
        return f
    }()

    private static let endFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "MMM d, HH:mm"
        return f
    }()

    private var dateRangeText: String {
        let start = Self.startFormatter.string(from: event.startDateTime)
        let end = Self.endFormatter.string(from: event.endDateTime)
        return "\(start) → \(end)"
    }

    var body: some View {
        HStack(spacing: 0) {
            Rectangle()
                .fill(accentColor)
                .frame(width: 3)

            HStack(spacing: 12) {
                KFImage(URL(string: event.eventImage))
                    .placeholder { ProgressView() }
                    .resizable()
                    .scaledToFill()
                    .frame(width: 52, height: 52)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(accentColor.opacity(0.4), lineWidth: 1.5))

                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Image(systemName: ActivityType(rawValue: event.activityType)?.icon ?? "figure.walk")
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(accentColor)

                        Text(event.activityType)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(accentColor)

                        Spacer()

                        Text(event.isPublic ? "Public" : "Only friends")
                            .font(.system(size: 10))
                            .foregroundColor(event.isPublic ? .black : Color.mainColor)
                            .padding(.vertical, 5)
                            .padding(.horizontal, 10)
                            .background(event.isPublic ? Color(red: 0, green: 227/255, blue: 253/255) : Color.mainColor)
                            .clipShape(RoundedRectangle(cornerRadius: UIConstants.cornerRadius))
                    }

                    Text(event.title)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.white)
                        .lineLimit(1)

                    Text(event.creatorName)
                        .font(.system(size: 12, weight: .regular))
                        .foregroundColor(.white.opacity(0.7))
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
    ViewSearchEvents(
        viewModel: ViewModelSearchEvents(
            region: MKCoordinateRegion(
                center: CLLocationCoordinate2D(latitude: 43.99, longitude: 9.44),
                span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)
            )
        )
    )
}
