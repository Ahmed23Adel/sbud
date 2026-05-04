//
//  viewMyEventDetails.swift
//  sbud
//
//  Created by ahmed on 01/05/2026.
//

import SwiftUI

struct ViewMyEventDetails: View {
    @State var viewModel: ViewModelMyEventDetails
    @EnvironmentObject private var coordinator: ProfileCoordinator
    init(eventId: String){
        _viewModel = State(wrappedValue: ViewModelMyEventDetails(eventId: eventId))
    }
    var body: some View {
        ZStack{
            Color.darkBackground
                .ignoresSafeArea()
            VStack{
                if let coverImg = viewModel.myEventDertails?.eventImage {
                    FadingEventImage(coverImgURL: coverImg)
                        .ignoresSafeArea()
                    Spacer()
                }
                else {
                    ProgressView()
                        .padding(.top, 50)
                    Spacer()
                }
                
            }
            .ignoresSafeArea()
            ScrollView {
                VStack{
                    if let details = viewModel.myEventDertails{
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
                        
                        LocationMapCard(dateLocations: details.dateLocations)
                            .padding()
                        
                        Button{
                            
                            coordinator.goToEventConversations(eventId: viewModel.eventId, eventTitle: details.title)
                        } label: {
                            HStack(spacing: 12) {
                                Image(systemName: "tray.fill")
                                    .font(.system(size: 20))
                                Text("View Messages")
                            }
                            .font(.system(size: 17, weight: .heavy))
                            .foregroundColor(.black)
                            .frame(maxWidth: .infinity)
                            .frame(height: 68)
                            .background(
                                Capsule()
                                    .fill(Color.mainColor)
                            )
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 12)
                        
                        // Invite a host
                        Button{
                            coordinator.showHostsSheet(eventId: viewModel.eventId)
                        } label: {
                            Text("Invite/Edit hosts")
                                .font(.system(size: 17, weight: .heavy))
                                .foregroundColor(Color(red: 0.15, green: 0.25, blue: 0.0))
                            
                                .frame(maxWidth: .infinity)
                                .frame(height: 68)
                                .background(
                                    Capsule()
                                        .fill(Color("palelime"))
                                    
                                )
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 20)
                        .transition(.opacity)
                    }
                    
                    
                }
                .padding(.top, 200)
                .toolbar{
                    ToolbarItem{
                        Button("Edit"){
                            
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    ViewMyEventDetails(eventId: "")
}
