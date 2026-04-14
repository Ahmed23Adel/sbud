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
                    ProgressView("Caricamento eventi...")
                } else if viewModel.myEvents.isEmpty {
                    VStack {
                        Image(systemName: "calendar.badge.exclamationmark")
                            .font(.largeTitle)
                            .foregroundColor(.gray)
                        Text("Non hai ancora creato nessun evento.")
                            .foregroundColor(.gray)
                            .padding(.top, 8)
                    }
                } else {
                    List(viewModel.myEvents, id: \.id) { event in
                        
                        // 👇 ECCO IL COLLEGAMENTO ALLA TUA VISTA 👇
                        NavigationLink {
                            ViewMoreInfoEvent(basicEvent: event)
                        } label: {
                            // Come appare la singola riga nella lista
                            VStack(alignment: .leading, spacing: 5) {
                                Text(event.activityType)
                                    .font(.headline)
                                
                                Text("Creato il: \(event.createdAt.formatted(date: .abbreviated, time: .shortened))")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            .padding(.vertical, 4)
                        }
                        
                    }
                    .listStyle(PlainListStyle())
                    .refreshable {
                        viewModel.fetchMyEvents()
                    }
                }
            }
            .navigationTitle("My events:")
            .onAppear {
                if viewModel.myEvents.isEmpty {
                    viewModel.fetchMyEvents()
                }
            }
        }
    }
}

#Preview {
    PersonalView()
}
