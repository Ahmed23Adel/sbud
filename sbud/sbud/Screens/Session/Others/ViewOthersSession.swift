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
        _viewModel = State(initialValue: ViewModelOthersSession(
            eventDetails: eventDetails,
            isSessionCreated: isSessionCreated
        ))
    }

    var body: some View {
        Group {
            if viewModel.isLoading {
                MidnightLoadingView(text: "STARTING SESSION")
                    .ignoresSafeArea()
            } else {
                mainContent
            }
        }
        .onAppear {
            viewModel.setMainCoordinator(mainCoordinator)
        }
    }

    // MARK: – Main content

    private var mainContent: some View {
        ZStack(alignment: .bottom) {
            Color.surfaceBg.ignoresSafeArea()
            GridPatternView().ignoresSafeArea().opacity(0.5)

            VStack(spacing: 0) {

                // ── Header: activity icon + event title + LIVE ────────────
                ViewEventSummary(event: viewModel.eventDetails)

                // ── Activity metrics + live map ───────────────────────────
                ViewMetricsSummaryConditional(
                    metricCollector: viewModel.metricsCollector,
                    activityType: viewModel.eventDetails.activityType
                )
                .frame(maxHeight: .infinity)

                Color.clear.frame(height: 88)
            }

            // ── Sticky End Session bar ────────────────────────────────────
            endSessionBar
        }
        .ignoresSafeArea(edges: .bottom)
        .confirmationDialog(
            "End Session",
            isPresented: $viewModel.isShowSimpleConfirm,
            titleVisibility: .visible
        ) {
            Button("End session", role: .destructive) { viewModel.endSession() }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to end the session?")
        }
        .confirmationDialog(
            "End Session Early?",
            isPresented: $viewModel.isShowEarlyEndWarning,
            titleVisibility: .visible
        ) {
            Button("End anyway", role: .destructive) { viewModel.endSession() }
            Button("Wait", role: .cancel) {}
        } message: {
            Text("Your data won't be included in the average. Wait for the creator to end the session.")
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

    // MARK: – End session bar

    private var endSessionBar: some View {
        VStack(spacing: 0) {
            LinearGradient(
                colors: [.clear, Color.surfaceBg.opacity(0.95)],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 24)

            Button {
                viewModel.onEndSessionTapped()
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: "stop.fill")
                        .font(.system(size: 13, weight: .black))
                    Text("END SESSION")
                        .font(.system(size: 13, weight: .black, design: .monospaced))
                        .tracking(2)
                }
                .foregroundColor(.black)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(
                    LinearGradient(
                        colors: [.neonPink, Color(red: 1.0, green: 0.38, blue: 0.18)],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
                .shadow(color: .neonPink.opacity(0.45), radius: 14, x: 0, y: 4)
            }
            .padding(.horizontal, 20)
            .padding(.bottom, 36)
            .background(Color.surfaceBg.opacity(0.95))
        }
    }
}
