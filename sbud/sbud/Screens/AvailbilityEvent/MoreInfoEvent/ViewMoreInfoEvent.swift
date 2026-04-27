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
    
    
    init(basicEvent: AvailabilityEvent){
        _viewModel = StateObject(wrappedValue: ViewModelMoreInfoEvent(event: basicEvent))
    }
    var body: some View {
        ZStack{
            Color.darkBackground
            VStack{
                FadingEventImage(coverImgURL: viewModel.event.eventImage)
                    .ignoresSafeArea()
                Spacer()
            }
            ScrollView {
                VStack{
                    if viewModel.event.isLoading{
                        LoadingView()
                    }  else if viewModel.isErrorLoading{
                        VStack{
                            Spacer()
                            Text("Error loading full details of event, pleaes try again")
                                .font(.title)
                                .fontWeight(.bold)
                            Spacer()
                        }
                    }  else if let details = viewModel.fullDetails{
                        ProposalVsDeterminedPhase(isDateConfirmed: viewModel.event.isDateConfirmed, isLocationConfirmed: viewModel.event.isLocationConfirmed)
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
                        
                        CreatorContactDetailed(creatorInfo: details.creator, eventId: viewModel.event.eventId)
                        
                        
                        LocationMapCard(dateLocations: details.dateLocations)
                            .padding()
                        
                        // Attending people list
                        VStack(alignment: .leading) {
                            Text("People interested in this event:")
                                .font(.headline)
                                .foregroundColor(.white)
                                .padding(.horizontal)
                                .padding(.top)

                            EventContactsListView(eventId: viewModel.event.eventId)
                        }
                        .padding(.bottom, 50)
                    }
                }
                .padding(.top, 200)
            }
        }
        .ignoresSafeArea()
    }
}

#Preview {
    ViewMoreInfoEvent(basicEvent: .preview)
}
