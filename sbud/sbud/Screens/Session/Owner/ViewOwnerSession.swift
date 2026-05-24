//
//  ownerSession.swift
//  sbud
//
//  Created by ahmed on 15/05/2026.
//
//
//  ViewOwnerSession.swift
//  sbud
//


import SwiftUI
import SwiftData

struct ViewOwnerSession: View {
    @State private var viewModel: ViewModelOwnerSession
    @EnvironmentObject private var mainCoordinator: MainCoordinator
    @Environment(\.modelContext) private var context
    var delegate: SessionCoordinatorDelegate

    init(eventDetails: EventFullDetails, isSessionCreated: Bool, delegate: SessionCoordinatorDelegate) {
        _viewModel = State(initialValue: ViewModelOwnerSession(
            eventDetails: eventDetails,
            isSessionCreated: isSessionCreated
        ))
        self.delegate = delegate
    }

    var body: some View {
        Group {
            if viewModel.isLoading {
                MidnightLoadingView(text: "LOADING SESSION")
                    .ignoresSafeArea()
            } else {
                mainContent
                    .padding(.top, 36)
            }
        }
        .onAppear {
            viewModel.setMainCoordinator(mainCoordinator)
        }
    }

    // MARK: – Main content
    // Fixed layout — no ScrollView. Everything fits on screen:
    //   [Header: icon + title + LIVE badge]
    //   [Timer | Distance]
    //   [Metric cards]
    //   [Map — fills remaining space]
    //   [End session bar — sticky bottom]

    private var mainContent: some View {
        ZStack(alignment: .bottom) {
            Color.surfaceBg.ignoresSafeArea()
            GridPatternView().ignoresSafeArea().opacity(0.5)

            VStack(spacing: 0) {

                // ── Header: activity icon + event title + LIVE ────────────
                ViewEventSummary(event: viewModel.eventDetails)

                // ── Activity-specific metrics + live map ──────────────────
                // Metrics view fills all remaining space above the end bar
                ViewMetricsSummaryConditional(
                    metricCollector: viewModel.metricsCollector,
                    activityType: viewModel.eventDetails.activityType
                )
                .frame(maxHeight: .infinity)

                // Spacer so content doesn't slide under the end bar
                Color.clear.frame(height: 88)
            }

            // ── Sticky End Session bar ────────────────────────────────────
            endSessionBar
        }
        .ignoresSafeArea(edges: .bottom)
        .alert(viewModel.alertMsg, isPresented: $viewModel.isShowAlert) {
            Button("OK", role: .cancel) {
                mainCoordinator.goToHome()
            }
        }
        .confirmationDialog(
            "End Session",
            isPresented: $viewModel.isShowEndConfirm,
            titleVisibility: .visible
        ) {
            Button("End session", role: .destructive) { viewModel.endSession() }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Are you sure you want to end this session?")
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

    // MARK: – End session bar

    private var endSessionBar: some View {
        VStack(spacing: 0) {
            // Fade mask over map edge
            LinearGradient(
                colors: [.clear, Color.surfaceBg.opacity(0.95)],
                startPoint: .top,
                endPoint: .bottom
            )
            .frame(height: 24)

            Button {
                viewModel.isShowEndConfirm = true
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
