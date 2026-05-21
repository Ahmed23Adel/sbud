//
//  ViewOthersEvents.swift
//  sbud
//
//  Created by ahmed on 01/05/2026.
//


import SwiftUI

struct ViewOthersEvents: View {
    let userId: String
    @State private var selectedTab: EventsTab = .created
    let onEventTap: (String) -> Void
    
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
                CreatedEventsView(userId: userId, onEventTap: onEventTap)
                    .tag(EventsTab.created)
                    

                HostedEventsView(userId: userId)
                    .tag(EventsTab.hostedEvents)

                ParticipatedEventsView(userId: userId)
                    .tag(EventsTab.participatedEvents)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.easeInOut, value: selectedTab)
        }
        
        .background(Color.darkBackground)
    }
}

// MARK: - Tab Enum

enum EventsTab: String, CaseIterable, Identifiable {
    case created
    case hostedEvents
    case participatedEvents

    var id: String { rawValue }

    var title: String {
        switch self {
        case .created:           return "Created"
        case .hostedEvents:      return "Hosted"
        case .participatedEvents: return "Participated"
        }
    }
}

// MARK: - Sub Views


struct HostedEventsView: View {
    let userId: String
    var body: some View {
        Text("Hosted Events for \(userId)")
    }
}

struct ParticipatedEventsView: View {
    let userId: String
    var body: some View {
        Text("Participated Events for \(userId)")
    }
}

// MARK: - Preview
//
//#Preview {
//    ViewOthersEvents(userId: "user123")
//}

