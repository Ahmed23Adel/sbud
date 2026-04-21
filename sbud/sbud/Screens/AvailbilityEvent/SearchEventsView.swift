//
//  SearchEventsView.swift
//  sbud
//
//  Created by Riccardo Maria Cadario on 21/04/26.
//

import SwiftUI
import FirebaseFirestore
import Combine

// MARK: - ViewModel

class SearchEventsViewModel: ObservableObject {
    @Published var creatorNameQuery: String = ""
    @Published var startDate: Date
    @Published var endDate: Date
    @Published var events: [AvailabilityEvent] = []
    @Published var isLoading: Bool = false
    @Published var showAlert: Bool = false
    @Published var alertMsg: String = ""
    @Published var hasSearched: Bool = false

    private let filterResults: AvailabilityFiltersResults
    private let requester = PaginatedFlattenedEventsRequester()
    // Fetch a large page so client-side name filter has enough data to work with
    private let pageSize = 100

    // World-wide bounding box — bypasses the map region restriction
    private let worldTopLeft     = GeoPoint(latitude:  89.9, longitude: -179.9)
    private let worldBottomRight = GeoPoint(latitude: -89.9, longitude:  179.9)

    init(filterResults: AvailabilityFiltersResults) {
        self.filterResults = filterResults
        self.startDate     = filterResults.startDateTime
        self.endDate       = filterResults.endDateTime
    }

    func search() {
        guard endDate >= startDate else {
            alertMsg  = "End date must be after start date."
            showAlert = true
            return
        }
        events      = []
        hasSearched = true
        Task { await fetchAndFilter() }
    }

    @MainActor
    private func fetchAndFilter() async {
        isLoading = true
        defer { isLoading = false }

        do {
            let request = PaginatedFlattenedEventsRequest(
                topLeft:              worldTopLeft,
                bottomRight:          worldBottomRight,
                selectedActivityType: filterResults.selectedActivity.rawValue,
                selectedStartTime:    startDate,
                selectedEndTime:      endDate,
                page:                 1,
                pageSize:             pageSize
            )
            let response = try await requester.fetchEvents(requestParams: request)

            // Reuse the same cast pattern already used in ViewModelFlattenedEventsList
            var result: [AvailabilityEvent] = response.events.compactMap {
                $0.covertToAnchor().event as? AvailabilityEvent
            }

            // Client-side creator name filter (case-insensitive contains)
            let trimmed = creatorNameQuery.trimmingCharacters(in: .whitespaces).lowercased()
            if !trimmed.isEmpty {
                result = result.filter { $0.creatorName.lowercased().contains(trimmed) }
            }

            events = result

        } catch {
            alertMsg  = "Error searching events, please try again later."
            showAlert = true
        }
    }
}

// MARK: - View

struct SearchEventsView: View {
    @StateObject private var viewModel: SearchEventsViewModel
    @EnvironmentObject private var coordinator: AvailabilityCoordinator

    init(filterResults: AvailabilityFiltersResults) {
        _viewModel = StateObject(
            wrappedValue: SearchEventsViewModel(filterResults: filterResults)
        )
    }

    var body: some View {
        ZStack {
            Color.darkBackground.ignoresSafeArea()

            VStack(spacing: 0) {
                headerRow
                    .padding(.horizontal)
                    .padding(.top, 20)
                    .padding(.bottom, 12)

                filtersSection
                    .padding(.horizontal)

                Divider()
                    .background(Color.white.opacity(0.15))
                    .padding(.vertical, 12)

                resultsSection
            }
        }
        .alert("Error", isPresented: $viewModel.showAlert) {
            Button("Ok", role: .cancel) {}
        } message: {
            Text(viewModel.alertMsg)
        }
    }

    // MARK: Header

    private var headerRow: some View {
        HStack {
            Text("Search Events")
                .font(.title2.bold())
                .foregroundColor(.white)
            Spacer()
            Button { coordinator.dismissSheet() } label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.title2)
                    .foregroundColor(.white.opacity(0.6))
            }
        }
    }

    // MARK: Filters

    private var filtersSection: some View {
        VStack(spacing: 12) {
            // Creator name field
            HStack {
                Image(systemName: "person.fill")
                    .foregroundColor(.white.opacity(0.5))
                TextField("Creator name", text: $viewModel.creatorNameQuery)
                    .foregroundColor(.white)
                    .autocorrectionDisabled()
                    .textInputAutocapitalization(.never)
                    .submitLabel(.search)
                    .onSubmit { viewModel.search() }
                if !viewModel.creatorNameQuery.isEmpty {
                    Button { viewModel.creatorNameQuery = "" } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundColor(.white.opacity(0.4))
                    }
                }
            }
            .padding()
            .background(Color.backgroundColor)
            .cornerRadius(12)

            // Start date
            DatePicker(
                "From",
                selection: $viewModel.startDate,
                displayedComponents: [.date, .hourAndMinute]
            )
            .foregroundColor(.white)
            .tint(.white)
            .padding()
            .background(Color.backgroundColor)
            .cornerRadius(12)

            // End date — clamped to startDate
            DatePicker(
                "To",
                selection: $viewModel.endDate,
                in: viewModel.startDate...,
                displayedComponents: [.date, .hourAndMinute]
            )
            .foregroundColor(.white)
            .tint(.white)
            .padding()
            .background(Color.backgroundColor)
            .cornerRadius(12)

            // Search button
            Button { viewModel.search() } label: {
                HStack {
                    Image(systemName: "magnifyingglass")
                    Text("Search")
                        .fontWeight(.semibold)
                }
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.accentColor)
                .cornerRadius(12)
            }
        }
    }

    // MARK: Results

    @ViewBuilder
    private var resultsSection: some View {
        if viewModel.isLoading {
            Spacer()
            ProgressView().tint(.white)
            Spacer()

        } else if !viewModel.hasSearched {
            Spacer()
            VStack(spacing: 10) {
                Image(systemName: "magnifyingglass")
                    .font(.system(size: 44))
                    .foregroundColor(.white.opacity(0.25))
                Text("Enter a creator name or adjust the\ndate range and tap Search")
                    .foregroundColor(.white.opacity(0.4))
                    .multilineTextAlignment(.center)
                    .font(.subheadline)
            }
            .padding(.horizontal, 32)
            Spacer()

        } else if viewModel.events.isEmpty {
            Spacer()
            VStack(spacing: 10) {
                Image(systemName: "person.slash.fill")
                    .font(.system(size: 44))
                    .foregroundColor(.white.opacity(0.25))
                Text("No events found")
                    .foregroundColor(.white.opacity(0.4))
                    .font(.subheadline)
            }
            Spacer()

        } else {
            List {
                ForEach(viewModel.events, id: \.id) { event in
                    EventRow(event: event)
                        .environmentObject(coordinator)
                        .listRowBackground(Color.backgroundColor)
                        .listRowInsets(EdgeInsets())
                }
            }
            .scrollContentBackground(.hidden)
            .background(Color.darkBackground)
        }
    }
}

