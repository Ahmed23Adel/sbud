//
//  MoreInfoEvent.swift
//  sbud
//
//  Created by ahmed on 02/02/2026.
//

import SwiftUI
import FirebaseFirestore
import Kingfisher
import Lottie
import OSLog

struct ViewMoreInfoEvent: View {
    @State var viewModel: ViewModelMoreInfoEvent
    @EnvironmentObject var coordinator: AvailabilityCoordinator
    @State private var showHostsList = false

    let logger = Logger(subsystem: "sbud", category: "ViewMoreInfoEvent")

    init(eventId: String) {
        _viewModel = State(wrappedValue: ViewModelMoreInfoEvent(eventId: eventId))
    }

    var body: some View {
        ZStack {
            Color.darkBackground
            VStack {
                if let coverImgURL = viewModel.fullDetails?.eventImage {
                    FadingEventImage(coverImgURL: coverImgURL)
                        .ignoresSafeArea()
                    Spacer()
                }
            }
            if viewModel.isLoading {
                LoadingView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .ignoresSafeArea()
            }
            ScrollView {
                VStack {
                    if viewModel.isErrorLoading {
                        VStack {
                            Spacer()
                            Text("Error loading full details of event, pleaes try again")
                                .font(.title).fontWeight(.bold)
                            Spacer()
                        }
                    } else if let details = viewModel.fullDetails {
                        ProposalVsDeterminedPhase(
                            isDateConfirmed: details.isDateConfirmed,
                            isLocationConfirmed: details.isLocationConfirmed
                        )
                        HStack {
                            JoiningProtocolDetailed(joiningProtocol: details.joinCondition)
                            VisibilityDetailed(isPublic: details.isPublic)
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
                            text: details.notes!
                        )

                        CreatorContactDetailed(
                            creatorInfo: details.creator,
                            onTapProfile: {
                                coordinator.push(.profileView(userId: details.creator.id))
                            },
                            onTapContact: {
                                var chatUser = UserProfile(id: details.creator.id)
                                chatUser.name = details.creator.name
                                chatUser.surName = details.creator.surName
                                chatUser.profileImageUrl = details.creator.profileImageUrl
                                coordinator.push(.chat(user: chatUser, eventId: viewModel.eventId, eventTitle: details.title))
                            }
                        )

                        // Hosts listesi butonu
                        Button {
                            showHostsList = true
                        } label: {
                            HStack(spacing: 10) {
                                Image(systemName: "star.fill")
                                    .font(.system(size: 14, weight: .semibold))
                                    .foregroundColor(Color(red: 0.15, green: 0.25, blue: 0.0))
                                Text("View Hosts")
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundColor(Color(red: 0.15, green: 0.25, blue: 0.0))
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .font(.system(size: 12))
                                    .foregroundColor(Color(red: 0.15, green: 0.25, blue: 0.0))
                            }
                            .padding()
                            .background(Color("palelime"))
                            .clipShape(RoundedRectangle(cornerRadius: UIConstants.cornerRadius))
                        }
                        .padding(.horizontal, 16)
                        .padding(.top, 4)

                        LocationMapCard(dateLocations: details.dateLocations)
                            .padding()

                        if viewModel.isCurrentUserHost {
                            queueButton
                                .padding(.horizontal, 24)
                                .padding(.bottom, 8)
                        }

                        if !viewModel.isCurrentUserHost {
                            JoinEventButton(
                                joinCondition: details.joinCondition,
                                joinState: viewModel.joinState,
                                isLoading: viewModel.isJoiningLoading,
                                onJoin: { Task { await viewModel.joinEvent() } },
                                onWithdraw: { Task { await viewModel.withdraw() } },
                                onLeave: { Task { await viewModel.leave() } }
                            )
                            .padding(.bottom, 20)
                        }
                    }
                }
                .padding(.top, 200)
                .padding(.bottom, 100)
            }
        }
        .ignoresSafeArea()
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
                            coordinator.push(.profileView(userId: userId))
                        }
                    }
                )
            }
        }
        .fullScreenCover(isPresented: $showHostsList) {
            ViewHostsList(
                eventId: viewModel.eventId,
                onTapHost: { userId in
                    showHostsList = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                        coordinator.push(.profileView(userId: userId))
                    }
                },
                onDismiss: { showHostsList = false }
            )
        }
    }

    private var queueButton: some View {
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
    }
}
