//
//  ViewCombinedEvents.swift
//  sbud
//
//  Created by ahmed on 14/05/2026.
//


import SwiftUI

struct ViewCombinedEvents: View {
    let userId: String
    @State private var selectedTab: EventsTab = .created
    let onCreatedEventTap: (String) -> Void
    let onParticipatedEventTap: (String) -> Void
    
    var body: some View {
        VStack(spacing: 0) {
            // Segmented Picker
            Picker("Events", selection: $selectedTab) {
                ForEach(EventsTab.allCases) { tab in
                    Text(tab.title).tag(tab)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            .padding(.vertical, 12)

            // Swipeable TabView
            TabView(selection: $selectedTab) {
                CreatedEventsView(userId: userId, onEventTap: onCreatedEventTap)
                    .tag(EventsTab.created)
                    

                HostedEventsView(userId: userId, onEventTap: onParticipatedEventTap)
                    .tag(EventsTab.hostedEvents)

                ParticipatedEventsView(userId: userId, onEventTap: onParticipatedEventTap)
                    .tag(EventsTab.participatedEvents)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.easeInOut, value: selectedTab)
        }
        
        .background(Color.darkBackground)
    }
}
