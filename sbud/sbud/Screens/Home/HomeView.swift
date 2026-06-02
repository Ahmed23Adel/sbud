//
//  HomeView.swift
//  sbud
//
//  Created by ahmed on 21/12/2025.
//

import SwiftUI

struct HomeView: View {
    var viewModel: HomeViewModel
    let onTapMyEvent: (String) -> Void
    let onTapOthersEvent: (String) -> Void
    let onTapProfile: (String) -> Void

    var body: some View {
        ZStack {
            Color(red: 0.05, green: 0.05, blue: 0.05).ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 20) {

                    UpcomingEventsSection(
                        events: viewModel.upcomingEvents,
                        isLoading: viewModel.isLoading && viewModel.upcomingEvents.isEmpty,
                        onTapEvent: { event in
                            if event.role == .creator {
                                onTapMyEvent(event.eventId)
                            } else {
                                onTapOthersEvent(event.eventId)
                            }
                        }
                    )
                    .animation(.easeInOut(duration: 0.4), value: viewModel.upcomingEvents.count)

                    PrivateEventsSection(
                        events: viewModel.privateEvents,
                        isLoading: viewModel.isLoading && viewModel.privateEvents.isEmpty,
                        onTapEvent: { event in onTapOthersEvent(event.eventId) }
                    )
                    .animation(.easeInOut(duration: 0.4), value: viewModel.privateEvents.count)

                    RecommendedEventsSection(
                        events: viewModel.recommendedEvents,
                        isLoading: viewModel.isLoading && viewModel.recommendedEvents.isEmpty,
                        onTapEvent: { event in onTapOthersEvent(event.eventId) },
                        onJoin: { event in
                            Task { await viewModel.joinEvent(eventId: event.eventId) }
                        }
                    )
                    .animation(.easeInOut(duration: 0.3), value: viewModel.recommendedEvents.count)

                    FriendsActivitySection(
                                            items: viewModel.friendsActivity,
                                            isLoading: viewModel.isLoading && viewModel.friendsActivity.isEmpty,
                                            onTapProfile: onTapProfile,
                                            onTapEvent: { item in
                                                if item.isCurrentUserCreator {
                                                    onTapMyEvent(item.eventId)
                                                } else {
                                                    onTapOthersEvent(item.eventId)
                                                }
                                            }
                    )
                    .animation(.easeInOut(duration: 0.4), value: viewModel.friendsActivity.count)

                    NewPeopleSection(
                        people: viewModel.meetPeople,
                        isLoading: viewModel.isLoading && viewModel.meetPeople.isEmpty,
                        onTapProfile: onTapProfile
                    )
                    .animation(.easeInOut(duration: 0.4), value: viewModel.meetPeople.count)

                    Spacer().frame(height: 80)
                }
                .padding(.top, 16)
            }
        }
        .navigationBarHidden(true)
    }
}

