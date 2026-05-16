//
//  othersSession.swift
//  sbud
//
//  Created by ahmed on 15/05/2026.
//

import SwiftUI
import SwiftData

struct ViewOthersSession: View {
    @State private var viewModel: ViewModelOthersSession
    @EnvironmentObject private var mainCoordinator: MainCoordinator
    @Environment(\.modelContext) private var context

    init(eventDetails: EventFullDetails, isSessionCreated: Bool) {
        _viewModel = State(initialValue: ViewModelOthersSession(eventDetails: eventDetails, isSessionCreated: isSessionCreated))
    }

    var body: some View {
        Group {
            if viewModel.isLoading {
                LoadingView()
                    .ignoresSafeArea()
            } else {
                ZStack {
                    Color.darkBackground
                        .ignoresSafeArea()
                    
                    VStack(spacing: 0) {
                        ScrollView {
                            VStack {
                                SessionTimerView(startDate: viewModel.startDateTime)
                                    .padding(.top, 100)
                                ViewEventSummary(event: viewModel.eventDetails)
                                ViewMetricsSummaryConditional(
                                    metricCollector: viewModel.metricsCollector,
                                    activityType: viewModel.eventDetails.activityType)
                            }
                        }
                        
                        Button("End session") {
                            viewModel.onEndSessionTapped()
                        }
                        .buttonStyle(DestructiveButton())
                        .padding(.bottom)
                        .padding(.horizontal)
                        .background(Color.darkBackground)
                    }
                }                // 1. Creator already ended — just confirm
                .confirmationDialog(
                    "End Session",
                    isPresented: $viewModel.isShowSimpleConfirm,
                    titleVisibility: .visible
                ) {
                    Button("End session", role: .destructive) { viewModel.endSession() }
                    Button("Cancel", role: .cancel) { }
                } message: {
                    Text("Are you sure you want to end the session?")
                }
                // 2. Creator hasn't ended yet — warn about exclusion
                .confirmationDialog(
                    "End Session Early?",
                    isPresented: $viewModel.isShowEarlyEndWarning,
                    titleVisibility: .visible
                ) {
                    Button("End anyway", role: .destructive) { viewModel.endSession() }
                    Button("Wait", role: .cancel) { }
                } message: {
                    Text("Your data will not be included in the average. Please wait until the creator ends the session.")
                }
                .alert(viewModel.alertMsg, isPresented: $viewModel.isShowAlert) {
                    Button("OK", role: .cancel) {
                        mainCoordinator.navigateTo(.homePage)
                    }
                }
                .onAppear {
                    viewModel.setModelContext(context: context)
                    if viewModel.isSessionCreated {
                        viewModel.readLocalSessionDetails()
                    } else {
                        viewModel.saveSessionLocally()
                    }
                }
            }
        }
        .onAppear {
            viewModel.setMainCoordinator(mainCoordinator)
        }
    }
}
