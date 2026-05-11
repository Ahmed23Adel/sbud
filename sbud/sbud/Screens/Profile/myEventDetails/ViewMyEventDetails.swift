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
    @State private var showingConfirmationSheet = false

    init(eventId: String) {
        _viewModel = State(wrappedValue: ViewModelMyEventDetails(eventId: eventId))
    }

    var body: some View {
        ZStack {
            Color.darkBackground.ignoresSafeArea()

            VStack {
                if let coverImg = viewModel.myEventDertails?.eventImage {
                    FadingEventImage(coverImgURL: coverImg).ignoresSafeArea()
                    Spacer()
                } else {
                    ProgressView().padding(.top, 50)
                    Spacer()
                }
            }
            .ignoresSafeArea()

            ScrollView {
                VStack {
                    if let details = viewModel.myEventDertails {

                        ProposalVsDeterminedPhase(
                            isDateConfirmed: details.isDateConfirmed,
                            isLocationConfirmed: details.isLocationConfirmed
                        )

                        HStack {
                            JoiningProtocolDetailed(joiningProtocol: details.joinCondition)
                            VisibilityDetailed(isPublic: details.isPublic)
                            if let max = details.maxAllowedToJoin { capacityBadge(max: max) }
                            Spacer()
                        }
                        .padding(.leading, 14)

                        HStack {
                            Text(details.title)
                                .font(.title).foregroundColor(.white).italic()
                                .padding(.horizontal)
                            Spacer()
                        }

                        ViewActivityTypeForDetails(activityType: details.activityType)
                        PerformanceTargetDetailedConditional(activityDetails: details.activityDetails)

                        GenericMultilineTextView(
                            fieldName: "Description",
                            placeholder: "Ex: Come join us",
                            iconString: "pencil",
                            text: details.notes ?? ""
                        )
                        
                        if let role = viewModel.role, role == .acceptedHost {
                            if let details = viewModel.myEventDertails {
                                CreatorContactDetailed(
                                    creatorInfo: details.creator,
                                    onTapProfile: {
                                        coordinator.goToProfileFromQueue(userId: details.creator.id)
                                    },
                                    onTapContact: {
                                        coordinator.goToEventConversations(eventId: viewModel.eventId, eventTitle: details.title)
                                    }
                                )
                            }
                        }
                        
                        LocationMapCard(dateLocations: details.dateLocations).padding()

                        if let role = viewModel.role {

                            if role == .creator {
                                if !details.isDateConfirmed || !details.isLocationConfirmed {
                                    actionButton(icon: "checkmark.seal.fill", title: "Confirm Final Details", color: .mainColor, textColor: .black) {
                                        showingConfirmationSheet = true
                                    }
                                }

                                actionButton(icon: "tray.fill", title: "View Messages", color: .mainColor, textColor: .black) {
                                    coordinator.goToEventConversations(eventId: viewModel.eventId, eventTitle: details.title)
                                }

                                actionButton(icon: "star.fill", title: "Invite/Edit Hosts", color: Color("palelime"), textColor: Color(red: 0.15, green: 0.25, blue: 0.0)) {
                                    coordinator.showHostsSheet(eventId: viewModel.eventId)
                                }
                            }

                            Button {
                                Task { await viewModel.loadQueue(); viewModel.showQueue = true }
                            } label: {
                                HStack(spacing: 10) {
                                    if viewModel.isLoadingQueue {
                                        ProgressView().tint(.black)
                                    } else {
                                        Image(systemName: "person.badge.clock").font(.system(size: 15, weight: .semibold))
                                        let pending = viewModel.queueResponse?.pendingCount ?? 0
                                        let wl = viewModel.queueResponse?.waitlistCount ?? 0
                                        Text(pending > 0
                                             ? "Review Requests (\(pending) pending\(wl > 0 ? ", \(wl) waitlist" : ""))"
                                             : "No Pending Requests")
                                            .font(.system(size: 15, weight: .semibold))
                                    }
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(viewModel.queueResponse?.pendingCount ?? 0 > 0 ? Color.mainColor : Color.backgroundColor.opacity(0.5))
                                .foregroundColor(viewModel.queueResponse?.pendingCount ?? 0 > 0 ? .black : .white)
                                .clipShape(RoundedRectangle(cornerRadius: UIConstants.cornerRadius))
                            }
                            .padding(.horizontal, 24)
                            .padding(.bottom, 20)
                        }

                        Spacer().frame(height: 40)
                    }
                }
                .padding(.top, 200)
                .toolbar {
                    ToolbarItem { Button("Edit") {} }
                }
            }

            if viewModel.isLoading {
                Color.black.opacity(0.4).ignoresSafeArea()
                ProgressView().tint(.white).scaleEffect(1.5)
            }
        }
        .sheet(isPresented: $showingConfirmationSheet) {
            if let details = viewModel.myEventDertails {
                ConfirmEventSheet(dateLocations: details.dateLocations) { selectedDateEntry, selectedLoc, finalStart, finalEnd in
                    showingConfirmationSheet = false
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
        .fullScreenCover(isPresented: $viewModel.showQueue) {
            if let q = viewModel.queueResponse {
                QueueView(
                    queueResponse: q,
                    isLoading: viewModel.isLoadingQueue,
                    onRespond: { userId, accept in
                        Task { await viewModel.respondToRequest(requesterId: userId, accept: accept) }
                    },
                    onDismiss: { viewModel.showQueue = false },
                    onTapProfile: { userId in
                        viewModel.showQueue = false
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                            coordinator.goToProfileFromQueue(userId: userId)
                        }
                    }
                )
            }
        }
    }

    private func actionButton(icon: String, title: String, color: Color, textColor: Color, action: @escaping () -> Void) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: icon).font(.system(size: 20))
                Text(title)
            }
            .font(.system(size: 17, weight: .heavy))
            .foregroundColor(textColor)
            .frame(maxWidth: .infinity)
            .frame(height: 68)
            .background(Capsule().fill(color))
        }
        .padding(.horizontal, 24)
        .padding(.bottom, 12)
    }

    private func capacityBadge(max: Int) -> some View {
        HStack(spacing: 4) {
            Image(systemName: "person.2").font(.system(size: 9))
            Text("Max \(max)").font(.system(size: 10))
        }
        .foregroundColor(.black)
        .padding(.vertical, 5).padding(.horizontal, 10)
        .background(Color.yellow.opacity(0.8))
        .clipShape(RoundedRectangle(cornerRadius: UIConstants.cornerRadius))
    }
}

#Preview {
    ViewMyEventDetails(eventId: "")
}
