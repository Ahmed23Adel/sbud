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

            // MARK: - Content
            TabView(selection: $selectedTab) {
                CreatedEventsView(userId: userId, onEventTap: onCreatedEventTap, showNotifications: true)
                    .tag(EventsTab.created)

                HostedEventsView(userId: userId, onEventTap: onCreatedEventTap)
                    .tag(EventsTab.hostedEvents)

                ParticipatedEventsView(userId: userId, onEventTap: onParticipatedEventTap)
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
