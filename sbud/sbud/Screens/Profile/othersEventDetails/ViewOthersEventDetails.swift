//
//  viewOthersEventDetails.swift
//  sbud
//
//  Created by ahmed on 15/05/2026.
//

import SwiftUI

struct ViewOthersEventDetails: View {
    @State var viewModel: ViewModelOthersEventDetails
    @EnvironmentObject private var coordinator: ProfileCoordinator
    
    init(eventId: String){
        _viewModel = State(initialValue: ViewModelOthersEventDetails(eventId: eventId))
    }
    
    var body: some View {
        ZStack {
            Color.darkBackground
                .ignoresSafeArea()
            
            VStack {
                if let coverImg = viewModel.myEventDertails?.eventImage {
                    FadingEventImage(coverImgURL: coverImg)
                        .ignoresSafeArea()
                    Spacer()
                } else {
                    LoadingView()
                        .ignoresSafeArea()
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
                        
                        LocationMapCard(dateLocations: details.dateLocations)
                            .padding()
                    }
                }
                .padding(.horizontal)
                .padding(.top, 280)
                .padding(.bottom, 100)
            }
            .ignoresSafeArea()
        }
    }
}

#Preview {
    ViewOthersEventDetails(eventId: "eventId")
}
