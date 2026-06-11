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
    @EnvironmentObject private var mainCoordinator: MainCoordinator
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
                    MidnightLoadingView(text: "Loading event details")
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
                        
                        if viewModel.role == .acceptedHost {
                                                    let pendingCount = viewModel.queueResponse?.pendingCount ?? 0
                                                    let waitlistCount = viewModel.queueResponse?.waitlistCount ?? 0
                                                    Button {
                                                        Task {
                                                            await viewModel.loadQueue()
                                                            viewModel.showQueue = true
                                                        }
                                                    } label: {
                                                        HStack(spacing: 10) {
                                                            Image(systemName: "person.badge.clock")
                                                                .font(.system(size: 15, weight: .semibold))
                                                            Text(pendingCount > 0 ? "Review Requests (\(pendingCount) pending)" : "No Pending Requests")
                                                                .font(.system(size: 15, weight: .semibold))
                                                        }
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 14)
                                .background(pendingCount > 0 ? Color.mainColor : Color.backgroundColor.opacity(0.5))
                                .foregroundColor(pendingCount > 0 ? .black : .white)
                                .clipShape(RoundedRectangle(cornerRadius: UIConstants.cornerRadius))
                                }
                            .padding(.horizontal, 24)
                            .padding(.bottom, 20)
                        }

                        
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
                    }
                }
                .padding(.horizontal)
                .padding(.top, 280)
                .padding(.bottom, 100)
            }
            .refreshable { await viewModel.refresh() }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        shareEvent(eventId: viewModel.myEventDertails?.id ?? "")
                    } label: {
                        Image(systemName: "square.and.arrow.up")
                    }
                }
            }
            .ignoresSafeArea()

            if !viewModel.isLoading, let eventDetails = viewModel.myEventDertails {
                VStack {
                    Spacer()
                    HStack {
                        // Summary button — mirrors the same button in ViewMyEventDetails
                        BasicFloatingButton(iconName: "chart.dots.scatter") {
                            coordinator.goToSessionSummary(evnet: eventDetails)
                        }
                        .padding(.leading, 36)

                        Spacer()

                        // Join session button — only shown when a session is currently active
                        if viewModel.isShowJoinSessionButton {
                            BasicFloatingButton(iconName: "flag.pattern.checkered"){
                                // TODO: fix
                                mainCoordinator.startOthersSession(eventDetails: eventDetails, isSessionCreated: true)
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
}

private extension ViewOthersEventDetails {
    func shareEvent(eventId: String) {
        guard !eventId.isEmpty,
              let url = URL(string: "https://sbud-backend.onrender.com/event/\(eventId)") else { return }
        let av = UIActivityViewController(activityItems: [url], applicationActivities: nil)
        UIApplication.shared.connectedScenes
            .compactMap { $0 as? UIWindowScene }
            .first?.windows.first?.rootViewController?
            .present(av, animated: true)
    }
}

#Preview {
    ViewOthersEventDetails(eventId: "eventId")
}
