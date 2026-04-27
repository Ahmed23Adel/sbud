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
                if viewModel.isLoading && viewModel.myEvents.isEmpty {
                    ProgressView("Loading event...")
                } else if viewModel.myEvents.isEmpty {
                    VStack {
                        Image(systemName: "calendar.badge.exclamationmark")
                            .font(.largeTitle)
                            .foregroundColor(.gray)
                        Text("You haven't create an event yet")
                            .foregroundColor(.gray)
                            .padding(.top, 8)
                    }
                } else {
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
                    // AGGIORNATO: Ora usiamo await, così l'animazione di refresh aspetta il termine del download!
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
