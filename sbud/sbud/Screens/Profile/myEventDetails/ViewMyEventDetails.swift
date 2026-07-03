//
//  viewMyEventDetails.swift
//  sbud
//
//  Created by ahmed on 01/05/2026.
//

import SwiftUI

struct ViewMyEventDetails: View {
    @State var viewModel: ViewModelMyEventDetails
    @EnvironmentObject private var coordinator: ProfileCoordinator
    @EnvironmentObject private var mainCoordinator: MainCoordinator
    @State var isPulsing = false
    @Environment(\.dismiss) var dismiss
    init(eventId: String) {
        _viewModel = State(wrappedValue: ViewModelMyEventDetails(eventId: eventId))
    }

    var body: some View {
        ZStack {
            Color.darkBackground.ignoresSafeArea()

            EventDetailBackground(coverImgURL: viewModel.myEventDertails?.eventImage)

            ScrollView {
                if let details = viewModel.myEventDertails {
                    VStack(spacing: 0) {
                        eventContent(details)
                            .padding(.top, 200)
                            .padding(.horizontal, 24)
                            .frame(maxWidth: .infinity)

                        
                    }
                    .toolbar {
                        ToolbarItem(placement: .topBarTrailing) {
                            Button {
                                shareEvent(eventId: viewModel.myEventDertails?.id ?? "")
                            } label: {
                                Image(systemName: "square.and.arrow.up")
                            }
                        }
                        ToolbarItem(placement: .topBarTrailing) {
                            Button("Edit") {
                                viewModel.showEditEvent = true
                            }
                        }
                    }
                }
            }
            .refreshable { await viewModel.refresh() }

            if !viewModel.isLoading{
                VStack {
                    Spacer()
                    HStack {
                        BasicFloatingButton(iconName: "chart.dots.scatter"){
                            coordinator.goToSessionSummary(evnet: viewModel.myEventDertails!)
                        }
                        .padding(.leading, 36)

                        Spacer()
                        if viewModel.isSessionCreated {
                            BasicFloatingButton(iconName: "flag.pattern.checkered"){
                                viewModel.navigateToConfirmationForSessionOrNavigateToSessionDetails()
                            }
                            .padding(.trailing)
                            .scaleEffect(isPulsing ? 1.4 : 1.0)
                            .animation(
                                .easeInOut(duration: 0.4).repeatForever(autoreverses: true),
                                value: isPulsing
                            )
                            .onAppear{
                                isPulsing = true
                            }
                        } else {
                            BasicFloatingButton(iconName: "flag.pattern.checkered"){
                                viewModel.navigateToConfirmationForSessionOrNavigateToSessionDetails()
                            }
                            .padding(.trailing)
                        }
                    }
                }
            }
            if viewModel.isLoading {
                MidnightLoadingView(text: "Loading event details").ignoresSafeArea()
            }
        }
        .sheet(item: $viewModel.activeSheet) { (sheet: MyEventDetailsSheet) in
            switch sheet {
            case .confirmation:
                confirmationSheet
            case .startSessionConfirmation:
                StartSessionConfirmation(eventDetails: viewModel.myEventDertails ?? .empty)
                    .environmentObject(coordinator)
            }
                
        }
        .onAppear{
            viewModel.setMainCoordinator(mainCoordinator: mainCoordinator)
        }
        .fullScreenCover(isPresented: $viewModel.showEditEvent) {
            if let details = viewModel.myEventDertails {
                NavigationStack {
                    ViewMyEventEdit(event: details)
                }
            }
        }
        .onChange(of: viewModel.showEditEvent) { _, isShowing in
            if !isShowing {
                Task { await viewModel.refresh() }
            }
        }
        .fullScreenCover(isPresented: $viewModel.showQueue) {
            queueCover
        }
        .alert("Delete Event", isPresented: $viewModel.showDeleteConfirmation) {
            Button("Delete", role: .destructive) {
                Task {
                    await viewModel.deleteEvent()
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This action cannot be undone. Are you sure you want to delete this event?")
        }
        .onChange(of: viewModel.eventDeleted) { _, newValue in
            if newValue {
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    dismiss()
                }
            }
        }
    }

    // MARK: - Subviews

    @ViewBuilder
    private func eventContent(_ details: EventFullDetails) -> some View {
        VStack {
               
            HStack(alignment: .top) {
                
                EventMetaBadgesRow(
                    isDateConfirmed: details.isDateConfirmed,
                    isLocationConfirmed: details.isLocationConfirmed,
                    joinCondition: details.joinCondition,
                    isPublic: details.isPublic,
                    maxAllowedToJoin: details.maxAllowedToJoin
                )
                
                Spacer()
                
                
                Button {
                    coordinator.goToEventConversations(
                        eventId: viewModel.eventId,
                        eventTitle: details.title
                    )
                } label: {
                    VStack(spacing: 4) {
                        ZStack(alignment: .topTrailing) {
                            Image(systemName: "tray.fill")
                                .font(.system(size: 24))
                                .foregroundColor(.white)
                            
                            
                            EventUnreadBadge(eventId: viewModel.eventId)
                                .scaleEffect(0.75)
                                .offset(x: 14, y: -10)
                        }
                        Text("Inbox")
                            .font(.system(size: 11, weight: .bold))
                            .foregroundColor(.black)
                    }
                    .padding(.vertical, 8)
                    .padding(.horizontal, 14)
                    .background(Color.mainColor)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
            .padding(.bottom, 12)

            EventInfoSection(
                title: details.title,
                activityType: details.activityType,
                activityDetails: details.activityDetails,
                notes: details.notes,
                dateLocations: details.dateLocations
            )
            if details.isDateConfirmed,
               let finalStart = details.finalStartDateTime,
               let finalEnd   = details.finalEndDateTime,
               let firstLoc   = details.dateLocations.first?.locations.first {

                EventWeatherWidget(
                    finalStart: finalStart,
                    finalEnd:   finalEnd,
                    latitude:   firstLoc.latitude,
                    longitude:  firstLoc.longitude
                )
                .padding(.horizontal)
            }

            EventActionButtons(
                eventId: viewModel.eventId,
                eventTitle: details.title,
                isDateConfirmed: details.isDateConfirmed,
                isLocationConfirmed: details.isLocationConfirmed,
                role: viewModel.role,
                queueResponse: viewModel.queueResponse,
                onConfirmTap: {
                    viewModel.activeSheet = .confirmation
                },
                onMessagesTap: {
                    coordinator.goToEventConversations(
                        eventId: viewModel.eventId,
                        eventTitle: details.title
                    )
                },
                onHostsTap: {
                    coordinator.showHostsSheet(eventId: viewModel.eventId)
                },
                onQueueTap: {
                    Task {
                        await viewModel.loadQueue()
                        viewModel.showQueue = true
                    }
                }
            )

            deleteButtonSection
            
            Spacer().frame(height: 40)
        }
    }

    @ViewBuilder
    private var confirmationSheet: some View {
        if let details = viewModel.myEventDertails {
            ConfirmEventSheet(dateLocations: details.dateLocations) { selectedDateEntry, selectedLoc, finalStart, finalEnd in
                viewModel.activeSheet = nil
                Task {
                    await viewModel.confirmEventFinalChoice(
                        selectedDateEntry: selectedDateEntry,
                        selectedLocation: selectedLoc,
                        finalStartDate: finalStart,
                        finalEndDate: finalEnd
                    )
                }
            }
            .presentationDetents([.large])
            .presentationDragIndicator(.visible)
        }
    }

    @ViewBuilder
    private var queueCover: some View {
        if let q = viewModel.queueResponse {
            QueueView(
                queueResponse: q,
                isLoading: viewModel.isLoadingQueue,
                onRespond: { userId, accept in
                    Task { await viewModel.respondToRequest(requesterId: userId, accept: accept) }
                },
                onDismiss: {
                    viewModel.showQueue = false
                },
                onTapProfile: { userId in
                    viewModel.showQueue = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
//                        coordinator.goToProfileFromQueue(userId: userId)
                    }
                }
            )
        }
    }

    private func shareEvent(eventId: String) {
        guard !eventId.isEmpty,
              let url = URL(string: "https://sbud-backend.onrender.com/event/\(eventId)") else { return }
        let av = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first?.windows.first?.rootViewController?
            .present(av, animated: true)
    }

    @ViewBuilder
    private var deleteButtonSection: some View {
        VStack {
            Spacer().frame(height: 40)
            Button {
                viewModel.showDeleteConfirmation = true
            } label: {
                Text("Delete Event")
            }
            .buttonStyle(DestructiveButton())
            .disabled(viewModel.isDeletingEvent)
            .opacity(viewModel.isDeletingEvent ? 0.6 : 1.0)
            .padding(.bottom, 16)
        }
    }
}

#Preview {
    ViewMyEventDetails(eventId: "")
}
