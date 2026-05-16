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
import FirebaseAuth
struct ViewMoreInfoEvent: View {
    @State var viewModel: ViewModelMoreInfoEvent
    @EnvironmentObject var coordinator: AvailabilityCoordinator

    let logger = Logger(subsystem: "sbud", category: "ViewMoreInfoEvent")

    init(eventId: String) {
        _viewModel = State(wrappedValue: ViewModelMoreInfoEvent(eventId: eventId))
    }

    var body: some View {
        ZStack {
            Color.darkBackground
                .ignoresSafeArea()

            VStack {
                if let url = viewModel.fullDetails?.eventImage {
                    FadingEventImage(coverImgURL: url).ignoresSafeArea()
                    Spacer()
                }
            }

            if viewModel.isLoading {
                LoadingView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .ignoresSafeArea()
            }

            ScrollView {
                VStack{
                    if viewModel.isErrorLoading {
                        VStack{
                            Spacer()
                            Text("Error loading full details of event, pleaes try again")
                            .font(.title)
                            .fontWeight(.bold)
                            Spacer()
                        }
                    } else if let details = viewModel.fullDetails {

                        ProposalVsDeterminedPhase(
                            isDateConfirmed: details.isDateConfirmed,
                            isLocationConfirmed: details.isLocationConfirmed
                        )
                        .padding(.horizontal)

                        HStack {
                            JoiningProtocolDetailed(joiningProtocol: details.joinCondition)
                            VisibilityDetailed(isPublic: details.isPublic)
                            if let max = details.maxAllowedToJoin {
                                CapacityBadge(max: max)
                            }
                            Spacer()
                        }
                        .padding(.leading, 14)
                        .padding(.horizontal)

                        HStack {
                            Text(details.title)
                                .font(.title).foregroundColor(.white).italic()
                                .padding(.horizontal)
                                .padding(.horizontal)
                            Spacer()
                        }

                        ViewActivityTypeForDetails(activityType: details.activityType)
                            .padding(.horizontal)
                        PerformanceTargetDetailedConditional(activityDetails: details.activityDetails)
                            .padding(.horizontal)

                        GenericMultilineTextView(
                            fieldName: "Description",
                            placeholder: "Ex: Come join us",
                            iconString: "pencil",
                            text: details.notes ?? ""
                        )
                        .padding(.horizontal)
                        if Auth.auth().currentUser?.uid != details.creator.id {
                            CreatorContactDetailed(
                                creatorInfo: details.creator,
                                onTapProfile: {
                                    logger.info("CreatorContactDetailed \(type(of: coordinator))")
                                    logger.info("details.creator.id: \(details.creator.id)")
                                    coordinator.push(.profileView(userId: details.creator.id))
                                },
                                onTapContact: {
                                    var chatUser = UserProfile(id: details.creator.id)
                                    chatUser.name = details.creator.name
                                    chatUser.surName = details.creator.surName
                                    chatUser.profileImageUrl = details.creator.profileImageUrl

                                    let eTitle = details.title
                                    coordinator.push(.chat(user: chatUser, eventId: viewModel.eventId, eventTitle: eTitle))
                                }
                            )
                            .padding(.horizontal)
                        }
                        LocationMapCard(dateLocations: details.dateLocations).padding()
                            .padding(.horizontal)
                        if !viewModel.isCurrentUserHost {
                            JoinEventButton(
                                joinCondition: details.joinCondition,
                                joinState: viewModel.joinState,
                                isLoading: viewModel.isJoiningLoading,
                                onJoin: { Task { await viewModel.joinEvent() } },
                                onWithdraw: { Task { await viewModel.withdraw() } },
                                onLeave: { Task { await viewModel.leave() } }
                            )
                            .padding(.horizontal)
                            .padding(.vertical, 8)
                        }

                        Spacer()
                    }
                }
                .padding(.top, 200)
                .padding(.bottom, 120)
            }
            .scrollIndicators(.hidden)
        }
        .ignoresSafeArea()
    }

    
}
