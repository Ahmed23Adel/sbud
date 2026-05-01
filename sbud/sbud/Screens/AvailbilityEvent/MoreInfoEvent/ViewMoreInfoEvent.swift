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

struct ViewMoreInfoEvent: View {
    @StateObject var viewModel: ViewModelMoreInfoEvent
    @EnvironmentObject var coordinator: AvailabilityCoordinator

    init(eventId: String){
        _viewModel = StateObject(wrappedValue: ViewModelMoreInfoEvent(eventId: eventId))
    }

    var body: some View {
        ZStack{
            Color.darkBackground
            VStack{
                if let coverImgURL = viewModel.fullDetails?.eventImage{
                    FadingEventImage(coverImgURL: coverImgURL)
                    .ignoresSafeArea()
                    Spacer()
                }
            }
            if viewModel.isLoading{
                LoadingView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .ignoresSafeArea()
            }
            ScrollView {
                VStack{
                    if viewModel.isErrorLoading{
                        VStack{
                            Spacer()
                            Text("Error loading full details of event, pleaes try again")
                                .font(.title)
                                .fontWeight(.bold)
                            Spacer()
                        }
                    } else if let details = viewModel.fullDetails{
                        ProposalVsDeterminedPhase(isDateConfirmed: details.isDateConfirmed, isLocationConfirmed: details.isLocationConfirmed)
                        HStack(){
                            JoiningProtocolDetailed(joiningProtocol: details.joinCondition)
                            VisibilityDetailed(isPublic: details.isPublic)
                            Spacer()
                        }
                        .padding(.leading, 14)
                        HStack{
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
                            text: details.notes!)

                        CreatorContactDetailed(
                            creatorInfo: details.creator,
                            onTapProfile: {
                                coordinator.push(.creatorProfile(userId: details.creator.id))
                            },
                            onTapContact: {
                                // 1. Mapping of the creator
                                var chatUser = UserProfile(id: details.creator.id)
                                chatUser.name = details.creator.name
                                chatUser.surName = details.creator.surName
                                chatUser.profileImageUrl = details.creator.profileImageUrl
                                
                                // 2. doing push using viewModel.eventId!
                                coordinator.push(.chat(user: chatUser, eventId: viewModel.eventId))
                            }
                        )

                        LocationMapCard(dateLocations: details.dateLocations)
                            .padding()

                        LazyVStack(spacing: 0) {
                            ForEach(1...100, id: \.self){ num in
                                Text("num \(num)")
                                    .frame(maxWidth: .infinity, alignment: .leading)
                                    .padding()
                            }
                        }
                    }
                }
                .padding(.top, 200)
            }
        }
        .ignoresSafeArea()
    }
}
