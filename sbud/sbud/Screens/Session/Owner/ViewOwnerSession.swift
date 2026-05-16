//
//  ownerSession.swift
//  sbud
//
//  Created by ahmed on 15/05/2026.
//

import SwiftUI
import SwiftData

struct ViewOwnerSession: View {
    @State private var viewModel: ViewModelOwnerSession
    @EnvironmentObject private var mainCoordinator: MainCoordinator
    @Environment(\.modelContext) private var context
    
    
    init(eventDetails: EventFullDetails, isSessionCreated: Bool) {
        _viewModel = State(initialValue: ViewModelOwnerSession(eventDetails: eventDetails, isSessionCreated: isSessionCreated))
    }

    var body: some View {
        Group{
            if viewModel.isLoading{
                LoadingView()
                    .ignoresSafeArea()
            } else {
                ZStack{
                    Color.darkBackground
                        .ignoresSafeArea()
                    VStack{
                        SessionTimerView(startDate: viewModel.startDateTime)
                            .padding(.top, 100)
                        ViewEventSummary(event: viewModel.eventDetails)
                        
                        ViewMetricsSummaryConditional(
                            metricCollector: viewModel.metricsCollector,
                            activityType: viewModel.eventDetails.activityType)
                        
                        Spacer()
                        Button("End session"){
                            viewModel.isShowEndConfirm = true
                        }
                        .buttonStyle(DestructiveButton())
                        .padding(.bottom)
                    }
                }
                .alert(viewModel.alertMsg, isPresented: $viewModel.isShowAlert) {
                    Button("OK", role: .cancel) {
                        mainCoordinator.navigateTo(.homePage)
                    }
                }
                .confirmationDialog(
                    "End Session",
                    isPresented: $viewModel.isShowEndConfirm,
                    titleVisibility: .visible
                ) {
                    Button("End session", role: .destructive) { viewModel.endSession() }
                    Button("Cancel", role: .cancel) { }
                } message: {
                    Text("Are you sure you want to end the session?")
                }
                .onAppear {
                    viewModel.setModelContext(context: context)
                    if viewModel.isSessionCreated {
                        viewModel.readLocalSessionDetails()
                    } else {
                        viewModel.saveSessoinLocally()
                    }
                }
            }
        }
        .onAppear{
            viewModel.setMainCoordinator(mainCoordinator)
        }
    }
    
}
//
//#Preview {
//    ownerSession()
//}
