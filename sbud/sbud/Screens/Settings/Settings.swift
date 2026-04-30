//
//  Settings.swift
//  sbud
//
//  Created by ahmed on 21/12/2025.
//

import SwiftUI

struct PersonalView: View {
    @StateObject private var viewModel = PersonalViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                // Show initial load ONLY if it is the first ever load
                if viewModel.isLoading && viewModel.myEvents.isEmpty {
                    ProgressView("Loading event...")
                } else {
                    // List is always present -->otherwise refresh doesn't work when it's empty
                    List(viewModel.myEvents, id: \.id) { event in
                        NavigationLink {
                            ViewMoreInfoEvent(basicEvent: event)
                        } label: {
                            VStack(alignment: .leading, spacing: 5) {
                                Text(event.activityType)
                                    .font(.headline)
                                
                                Text("Created on the: \(event.createdAt.formatted(date: .abbreviated, time: .shortened))")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.vertical, 4)
                        }
                    }
                    .listStyle(PlainListStyle())
                   //to show empty -->an overlay
                    .overlay {
                        if viewModel.myEvents.isEmpty {
                            VStack {
                                Image(systemName: "calendar.badge.exclamationmark")
                                    .font(.largeTitle)
                                    .foregroundColor(.gray)
                                Text("You haven't created an event yet")
                                    .foregroundColor(.gray)
                                    .padding(.top, 8)
                            }
                        }
                    }
                    .refreshable {
                        await viewModel.fetchMyEvents()
                    }
                }
            }
            .navigationTitle("My events:")
            .onAppear {
                if viewModel.myEvents.isEmpty {
                    Task {
                        await viewModel.fetchMyEvents()
                    }
                }
            }
        }
    }
}

#Preview {
    PersonalView()
}
