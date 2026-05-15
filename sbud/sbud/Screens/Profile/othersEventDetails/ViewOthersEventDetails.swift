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
    
    @State var isPulsing = false
    
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
            
            if !viewModel.isLoading && viewModel.isShowJoinSessionButton{
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        BasicFloatingButton(iconName: "flag.pattern.checkered"){
                            
                        }
                        .padding(.trailing)
                        .scaleEffect(isPulsing ? 1.4 : 1.0)
                        .animation(
                            .easeInOut(duration: 0.4).repeatForever(autoreverses: true),
                            value: isPulsing
                        )
                        .onAppear{
                            isPulsing = true
                        }
                        
                    }
                }
            }
        }
    }
}

#Preview {
    ViewOthersEventDetails(eventId: "eventId")
}
