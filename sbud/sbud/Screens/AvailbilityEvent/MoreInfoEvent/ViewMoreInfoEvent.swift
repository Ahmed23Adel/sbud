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
                    }  else if let details = viewModel.fullDetails{
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
                        
                        CreatorContactDetailed(creatorInfo: details.creator)
                        
                        
                        LocationMapCard(dateLocations: details.dateLocations)
                            .padding()
                        
                        // Attending people list
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
//#Preview {
//    ViewMoreInfoEvent(basicEvent: .preview)
//}
