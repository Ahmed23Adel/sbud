//
//  UserEventView.swift
//  sbud
//
//  Created by Erdal on 07.05.2026.
//

import SwiftUI

struct UserEventView: View {
    @State private var viewModel: UserEventViewModel
    @EnvironmentObject var coordinator: AvailabilityCoordinator

    init(eventId: String) {
        _viewModel = State(wrappedValue: UserEventViewModel(eventId: eventId))
    }

    var body: some View {
        ZStack {
            Color.darkBackground

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
                VStack {
                    if viewModel.isErrorLoading {
                        VStack {
                            Spacer()
                            Text("Error loading full details of event, please try again")
                                .font(.title).fontWeight(.bold)
                            Spacer()
                        }
                    } else if let details = viewModel.fullDetails {
                        eventHeader(details: details)

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

                        LocationMapCard(dateLocations: details.dateLocations).padding()

                        JoinEventButton(
                            joinCondition: details.joinCondition,
                            joinState: viewModel.joinState,
                            isLoading: viewModel.isJoiningLoading,
                            onJoin: { Task { await viewModel.joinEvent() } },
                            onWithdraw: { Task { await viewModel.withdraw() } },
                            onLeave: { Task { await viewModel.leave() } }
                        )
                        .padding(.vertical, 8)

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

    @ViewBuilder
    private func eventHeader(details: EventFullDetails) -> some View {
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
