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
    let onEventTap: (String) -> Void         // created events → myEventDetails
    let onOthersEventTap: (String) -> Void   // hosted/participated → othersEventDetails

    var body: some View {
        VStack(spacing: 0) {
            Picker("Events", selection: $selectedTab) {
                ForEach(EventsTab.allCases) { tab in
                    Text(tab.title).tag(tab)
                }
            }
            .pickerStyle(.segmented)
            .padding(.horizontal)
            .padding(.vertical, 12)

            TabView(selection: $selectedTab) {
                CreatedEventsView(userId: userId, onEventTap: onEventTap)
                    .tag(EventsTab.created)

                HostedEventsView(userId: userId, onEventTap: onOthersEventTap)
                    .tag(EventsTab.hostedEvents)

                ParticipatedEventsView(userId: userId, onEventTap: onOthersEventTap)
                    .tag(EventsTab.participatedEvents)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.easeInOut, value: selectedTab)
        }
        .background(Color.darkBackground)
    }
}
