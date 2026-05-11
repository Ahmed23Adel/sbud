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
import Kingfisher
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
                HStack(spacing: 8) {
                    tabButton(title: "Created", tab: .created)
                    tabButton(title: "Hosting", tab: .hosting)
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 8)

                switch viewModel.selectedTab {
                case .created:
                    createdContent
                case .hosting:
                    hostingContent
                }
            }
        }
        .navigationTitle("My Events")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Error", isPresented: $viewModel.isShowAlert) {
            Button("Ok", role: .cancel) {}
        } message: {
            Text(viewModel.alertMsg)
        }
    }

    private var createdContent: some View {
        Group {
            if viewModel.usersEvents.isEmpty {
                emptyState(message: "Events you create will appear here.")
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
                emptyState(message: "Events you're hosting will appear here.")
            } else {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        ForEach(viewModel.hostingSections, id: \.0) { status, events in
                            sectionHeader(for: status)
                            VStack(spacing: 8) {
                                ForEach(events) { event in
                                    hostingEventRow(event: event)
                                        .padding(.horizontal, 16)
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

    // MARK: - Hosting Event Row
    private func hostingEventRow(event: HostingEvent) -> some View {
        HStack(spacing: 0) {
            Rectangle()
                .fill(event.usersEventStatus.color)
                .frame(width: 3)

            HStack(spacing: 12) {
                KFImage(URL(string: event.eventImage))
                    .placeholder {
                        Color.gray.opacity(0.3)
                            .overlay(Image(systemName: "photo").foregroundColor(.gray))
                    }
                    .resizable()
                    .scaledToFill()
                    .frame(width: 52, height: 52)
                    .clipShape(Circle())

                VStack(alignment: .leading, spacing: 4) {
                    HStack(spacing: 6) {
                        Image(systemName: event.activityTypeEnum.icon)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(Color(red: 0.0, green: 227.0/255.0, blue: 253.0/255.0))
                        Text(event.activityTypeEnum.rawValue)
                            .font(.system(size: 13, weight: .semibold))
                            .foregroundColor(Color(red: 0.0, green: 227.0/255.0, blue: 253.0/255.0))
                        Spacer()
                        Text("Host")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(Color("palelime"))
                            .padding(.horizontal, 8).padding(.vertical, 3)
                            .background(Color("palelime").opacity(0.15))
                            .clipShape(Capsule())
                    }
                    Text(event.title)
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .lineLimit(1)
                }

                Spacer()
            }
            .padding(.horizontal, 14)
            .padding(.vertical, 14)
        }
        .background(Color.backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: UIConstants.cornerRadius))
    }

    // MARK: - Shared
    private func tabButton(title: String, tab: MyEventsTab) -> some View {
        Button {
            viewModel.selectedTab = tab
        } label: {
            Text(title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(viewModel.selectedTab == tab ? .black : .gray)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 10)
                .background(
                    viewModel.selectedTab == tab ? Color.mainColor : Color(white: 0.12)
                )
                .clipShape(RoundedRectangle(cornerRadius: 10))
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

    private func emptyState(message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "calendar.badge.exclamationmark")
                .font(.system(size: 48))
                .foregroundColor(.white.opacity(0.2))
            Text("NO EVENTS YET")
                .font(.system(size: 14, weight: .black, design: .monospaced))
                .foregroundColor(.white.opacity(0.3))
                .kerning(1.5)
            Text(message)
                .font(.system(size: 12, design: .monospaced))
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

#Preview {
    NavigationStack {
        ViewMyEvents(userId: "ExbXn3HBUHSrgjwCfYAgKi260k32")
            .environmentObject(MainCoordinator())
    }
}
