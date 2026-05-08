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
                VStack(spacing: 0) {
                    if viewModel.isErrorLoading {
                        Text("Error loading event, please try again")
                            .font(.title).fontWeight(.bold).padding(.top, 100)
                    } else if let details = viewModel.fullDetails {

                        ProposalVsDeterminedPhase(
                            isDateConfirmed: details.isDateConfirmed,
                            isLocationConfirmed: details.isLocationConfirmed
                        )

                        HStack {
                            JoiningProtocolDetailed(joiningProtocol: details.joinCondition)
                            VisibilityDetailed(isPublic: details.isPublic)
                            if let max = details.maxAllowedToJoin {
                                capacityBadge(max: max)
                            }
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
                        }

                        LocationMapCard(dateLocations: details.dateLocations).padding()

                        if !viewModel.isCurrentUserHost {
                            JoinEventButton(
                                joinCondition: details.joinCondition,
                                joinState: viewModel.joinState,
                                isLoading: viewModel.isJoiningLoading,
                                onJoin: { Task { await viewModel.joinEvent() } },
                                onWithdraw: { Task { await viewModel.withdraw() } },
                                onLeave: { Task { await viewModel.leave() } }
                            )
                            .padding(.vertical, 8)
                        }

                        Spacer().frame(height: 120)
                    }
                }
                .padding(.top, viewModel.fullDetails?.eventImage != nil ? 200 : 60)
            }
            .scrollIndicators(.hidden)
        }
        .ignoresSafeArea(edges: .top)
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
