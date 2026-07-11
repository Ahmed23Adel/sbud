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

            // MARK: - Custom Tab Bar 
            HStack(spacing: 0) {
                ForEach(EventsTab.allCases) { tab in
                    Button {
                        withAnimation(.easeInOut(duration: 0.2)) {
                            selectedTab = tab
                        }
                    } label: {
                        Text(tab.title.uppercased())
                            .font(.system(size: 11, weight: .black, design: .monospaced))
                            .kerning(1)
                            .foregroundColor(selectedTab == tab ? .black : .white.opacity(0.4))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(
                                Group {
                                    if selectedTab == tab {
                                        RoundedRectangle(cornerRadius: 10)
                                            .fill(Color("palelime"))
                                    }
                                }
                            )
                    }
                    .animation(.easeInOut(duration: 0.2), value: selectedTab)
                }
            }
            .padding(4)
            .background(Color(white: 0.12))
            .clipShape(RoundedRectangle(cornerRadius: 13))
            .padding(.horizontal, 16)
            .padding(.vertical, 12)

            // MARK: - Swipeable Content
            TabView(selection: $selectedTab) {
                CreatedEventsView(userId: userId, onEventTap: onEventTap)
                    .tag(EventsTab.created)

                HostedEventsView(userId: userId, onEventTap: onEventTap)
                    .tag(EventsTab.hostedEvents)

                ParticipatedEventsView(userId: userId, onEventTap: onEventTap)
                    .tag(EventsTab.participatedEvents)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
            .animation(.easeInOut, value: selectedTab)
        }
        .background(Color(white: 0.07))
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                PageSectionTitle(title: "ALL EVENTS")
            }
        }
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
        case .created:            return "Created"
        case .hostedEvents:       return "Hosted"
        case .participatedEvents: return "Participated"
        }
    }
}
