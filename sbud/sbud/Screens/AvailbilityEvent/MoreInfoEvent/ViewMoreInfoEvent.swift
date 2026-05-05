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
    @StateObject var viewModel: ViewModelMoreInfoEvent
    @EnvironmentObject var coordinator: AvailabilityCoordinator
    
    let logger = Logger(subsystem: "sbud", category: "ViewMoreInfoEvent")
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
                                logger.info("CreatorContactDetailed \(type(of: coordinator))")
                                logger.info("details.creator.id: \(details.creator.id)")
                                coordinator.push(.profileView(userId: details.creator.id))
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
