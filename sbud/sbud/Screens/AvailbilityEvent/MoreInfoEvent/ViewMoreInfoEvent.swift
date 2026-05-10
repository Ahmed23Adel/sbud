//
//  MoreInfoEvent.swift
//  sbud
//
//  Created by ahmed on 02/02/2026.
//

import SwiftUI

struct ViewMoreInfoEvent: View {
    @State private var viewModel: ViewModelMoreInfoEvent
    @EnvironmentObject var coordinator: AvailabilityCoordinator

    init(eventId: String) {
        _viewModel = State(wrappedValue: ViewModelMoreInfoEvent(eventId: eventId))
    }

    var body: some View {
        ZStack {
            Color.darkBackground.ignoresSafeArea()

            if viewModel.isLoading || viewModel.role == nil {
                LoadingView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .ignoresSafeArea()
            } else {
                switch viewModel.role! {
                case .creator:
                    CreatorEventView(eventId: viewModel.eventId)
                        .environmentObject(coordinator)
                case .acceptedHost:
                    HostEventView(eventId: viewModel.eventId)
                        .environmentObject(coordinator)
                case .regularUser:
                    UserEventView(eventId: viewModel.eventId)
                        .environmentObject(coordinator)
                }
            }
        }
        .ignoresSafeArea()
    }
}
