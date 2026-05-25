//
//  viewOthersEventDetails.swift
//  sbud
//
//  Created by ahmed on 15/05/2026.
//

import SwiftUI
import FirebaseAuth

struct ViewOthersEventDetails: View {
    @State var viewModel: ViewModelOthersEventDetails
    @EnvironmentObject private var coordinator: ProfileCoordinator
    @EnvironmentObject private var mainCoordinator: MainCoordinator
    @State var isPulsing = false
    @State private var showHostsList = false
    @State private var showChat = false

    init(eventId: String) {
        _viewModel = State(initialValue: ViewModelOthersEventDetails(eventId: eventId))
    }

    var body: some View {
        ZStack {
            Color.darkBackground.ignoresSafeArea()

            VStack {
                if let coverImg = viewModel.myEventDertails?.eventImage {
                    FadingEventImage(coverImgURL: coverImg).ignoresSafeArea()
                    Spacer()
                } else {
                    MidnightLoadingView(text: "Loading event details").ignoresSafeArea()
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
                            if let max = details.maxAllowedToJoin {
                                CapacityBadge(max: max)
                            }
                            Spacer()
                        }
                        .padding(.leading, 14)

                        HStack {
                            Text(details.title)
                                .font(.title)
                                .foregroundColor(.white)
                                .italic()
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
                        
                        Button {
                            showHostsList = true
                        } label: {
                            HStack {
                                Image(systemName: "person.2.fill")
                                    .foregroundColor(Color("palelime"))
                                Text("View Hosts")
                                    .font(.system(size: 15, weight: .semibold))
                                    .foregroundColor(.white)
                                Spacer()
                                Image(systemName: "chevron.right")
                                    .foregroundColor(.gray)
                                    .font(.system(size: 12))
                            }
                            .padding()
                            .background(Color.backgroundColor)
                            .clipShape(RoundedRectangle(cornerRadius: UIConstants.cornerRadius))
                            .padding(.horizontal)
                        }

                        if Auth.auth().currentUser?.uid != details.creator.id {
                            CreatorContactDetailed(
                                creatorInfo: details.creator,
                                onTapProfile: {
                                    coordinator.goToOthersProfile(userId: details.creator.id)
                                },
                                onTapContact: {
                                    showChat = true
                                }
                            )
                            .padding(.horizontal)
                        }

                        LocationMapCard(dateLocations: details.dateLocations)
                            .padding()
                        
                        if viewModel.role == .acceptedHost {
                            let pendingCount = viewModel.queueResponse?.pendingCount ?? 0
                            let waitlistCount = viewModel.queueResponse?.waitlistCount ?? 0
                            Button {
                                Task {
                                    await viewModel.loadQueue()
                                    viewModel.showQueue = true
                                }
                            } label: {
                                HStack(spacing: 10) {
                                    Image(systemName: "person.badge.clock")
                                        .font(.system(size: 15, weight: .semibold))
                                    Text(pendingCount > 0 ? "Review Requests (\(pendingCount) pending)" : "No Pending Requests")
                                        .font(.system(size: 15, weight: .semibold))
                                }
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 14)
                                .background(pendingCount > 0 ? Color.mainColor : Color.backgroundColor.opacity(0.5))
                                .foregroundColor(pendingCount > 0 ? .black : .white)
                                .clipShape(RoundedRectangle(cornerRadius: UIConstants.cornerRadius))
                            }
                            .padding(.horizontal, 24)
                            .padding(.bottom, 20)
                        }

                    }
                }
                .padding(.horizontal)
                .padding(.top, 280)
                .padding(.bottom, 100)
            }
            .ignoresSafeArea()

            if !viewModel.isLoading && viewModel.isShowJoinSessionButton {
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        BasicFloatingButton(iconName: "flag.pattern.checkered") {
                            mainCoordinator.startOthersSession(
                                eventDetails: viewModel.myEventDertails!,
                                isSessionCreated: true
                            )
                        }
                        .padding(.trailing)
                        .scaleEffect(isPulsing ? 1.4 : 1.0)
                        .animation(.easeInOut(duration: 0.4).repeatForever(autoreverses: true), value: isPulsing)
                        .onAppear { isPulsing = true }
                    }
                }
            }
        }
        .sheet(isPresented: $showChat) {
            chatSheet
        }
        .fullScreenCover(isPresented: $viewModel.showQueue) {
            queueCover
        }
        .fullScreenCover(isPresented: $showHostsList) {
            ViewHostsList(
                eventId: viewModel.eventId,
                onTapHost: { userId in
                    showHostsList = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                        coordinator.goToOthersProfile(userId: userId)
                    }
                },
                onDismiss: { showHostsList = false }
            )
        }
    }

    @ViewBuilder
    private var chatSheet: some View {
        if let details = viewModel.myEventDertails {
            let chatUser: UserProfile = {
                var u = UserProfile(id: details.creator.id)
                u.name = details.creator.name
                u.surName = details.creator.surName
                u.profileImageUrl = details.creator.profileImageUrl
                return u
            }()
            ChatView(user: chatUser, eventId: viewModel.eventId, eventTitle: details.title)
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
                        coordinator.goToOthersProfile(userId: userId)
                    }
                }
            )
        }
    }
}

#Preview {
    ViewOthersEventDetails(eventId: "eventId")
}
