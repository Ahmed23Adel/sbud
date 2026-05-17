//
//  MyEvents.swift
//  sbud
//
//  Created by ahmed on 30/04/2026.
//

// There will be activites of type
// proposed
// confirmed
// completed
import SwiftUI

struct ViewMyEvents: View {
    @State var viewModel: ViewModelMyEvents
    @EnvironmentObject var coordinator: ProfileCoordinator

    init(userId: String) {
        _viewModel = State(initialValue: ViewModelMyEvents(userId: userId))
    }

    var body: some View {
        ZStack {
            Color(red: 0.05, green: 0.05, blue: 0.05).ignoresSafeArea()

            VStack(spacing: 0) {
                TabSwitcher(
                    tabs: [
                        (title: "CREATED", tab: MyEventsTab.created),
                        (title: "HOSTING", tab: MyEventsTab.hosting)
                    ],
                    selected: $viewModel.selectedTab
                )
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 8)

                TabView(selection: $viewModel.selectedTab) {
                    createdContent.tag(MyEventsTab.created)
                    hostingContent.tag(MyEventsTab.hosting)
                }
                .tabViewStyle(.page(indexDisplayMode: .never))
                .animation(.easeInOut(duration: 0.25), value: viewModel.selectedTab)
            }
        }
        .navigationTitle("My Events")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .alert("Error", isPresented: $viewModel.isShowAlert) {
            Button("Ok", role: .cancel) {}
        } message: {
            Text(viewModel.alertMsg)
        }
    }

    private var createdContent: some View {
        Group {
            if viewModel.usersEvents.isEmpty {
                EmptyStateView(message: "Events you create will appear here.")
            } else {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        ForEach(viewModel.sections, id: \.0) { status, events in
                            sectionHeader(for: status)
                            VStack(spacing: 8) {
                                ForEach(events) { event in
                                    MyEventRow(event: event)
                                        .padding(.horizontal, 16)
                                        .environmentObject(coordinator)
                                        .onTapGesture {
                                            coordinator.goToMyEventDetails(eventId: event.eventId)
                                        }
                                }
                            }
                            .padding(.bottom, 16)
                        }
                    }
                    .padding(.top, 8)
                    .padding(.bottom, 80)
                }
            }
        }
    }

    private var hostingContent: some View {
        Group {
            if viewModel.isLoadingHosting {
                ProgressView().tint(.white)
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else if viewModel.hostingEvents.isEmpty {
                EmptyStateView(message: "Events you're hosting will appear here.")
            } else {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        ForEach(viewModel.hostingSections, id: \.0) { status, events in
                            sectionHeader(for: status)
                            VStack(spacing: 8) {
                                ForEach(events) { event in
                                    HostingEventRow(event: event) {
                                        coordinator.goToMyEventDetails(eventId: event.eventId)
                                    }
                                    .padding(.horizontal, 16)
                                }
                            }
                            .padding(.bottom, 16)
                        }
                    }
                    .padding(.top, 8)
                    .padding(.bottom, 80)
                }
            }
        }
    }
}

    private func sectionHeader(for status: UsersEventStatus) -> some View {
        HStack(spacing: 8) {
            Image(systemName: status.icon)
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(status.color)
            Text(status.rawValue.uppercased())
                .font(.system(size: 10, weight: .bold))
                .tracking(1.5)
                .foregroundColor(status.color)
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
    }

#Preview {
    NavigationStack {
        ViewMyEvents(userId: "ExbXn3HBUHSrgjwCfYAgKi260k32")
            .environmentObject(MainCoordinator())
    }
}
