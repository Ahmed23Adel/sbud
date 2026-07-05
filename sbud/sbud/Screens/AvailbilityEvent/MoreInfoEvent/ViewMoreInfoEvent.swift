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
    @State private var showHostsList = false

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
                MidnightLoadingView(text: "Loading event")
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .ignoresSafeArea()
                    .accessibilityIdentifier("moreInfo.loadingView")
            }

            ScrollView {
                VStack {
                    if viewModel.isErrorLoading {
                        VStack {
                            Spacer()
                            Text("Error loading full details of event, pleaes try again")
                                .font(.title)
                                .fontWeight(.bold)
                                .accessibilityIdentifier("moreInfo.errorText")
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
                                .accessibilityIdentifier("moreInfo.eventTitle")
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
                                    coordinator.showProfile(userId: details.creator.id)
                                },
                                onTapContact: {
                                    var chatUser = UserProfile(id: details.creator.id)
                                    chatUser.name = details.creator.name
                                    chatUser.surName = details.creator.surName
                                    chatUser.profileImageUrl = details.creator.profileImageUrl
                                    let eTitle = details.title
                                    coordinator.showChat(user: chatUser, eventId: viewModel.eventId, eventTitle: eTitle)
                                }
                            )
                            .padding(.horizontal)
                        }

                        ViewHostsButton {
                            showHostsList = true
                        }

                        LocationMapCard(dateLocations: details.dateLocations).padding()
                            .padding(.horizontal)
                        
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
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    guard let eventId = viewModel.fullDetails?.id,
                          let url = URL(string: "https://sbud-backend.onrender.com/event/\(eventId)") else { return }
                    let av = UIActivityViewController(activityItems: [url], applicationActivities: nil)
                    UIApplication.shared.connectedScenes
                        .compactMap { $0 as? UIWindowScene }
                        .first?.windows.first?.rootViewController?
                        .present(av, animated: true)
                } label: {
                    Image(systemName: "square.and.arrow.up")
                }
            }
        }
        .fullScreenCover(isPresented: $showHostsList) {
            ViewHostsList(
                eventId: viewModel.eventId,
                onTapHost: { userId in
                    showHostsList = false
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.35) {
                        coordinator.showProfile(userId: userId)
                    }
                },
                onDismiss: { showHostsList = false }
            )
        }
    }
}

