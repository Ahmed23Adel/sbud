//
//  CreatedEventsView.swift
//  sbud
//
//  Created by ahmed on 21/05/2026.
//

import SwiftUI

struct CreatedEventsView: View {
    @State var viewModel: CreatedEventsViewModel
    @EnvironmentObject var coordinator: ProfileCoordinator
    let onEventTap: (String) -> Void
    // Only true when these are the viewer's own created events, where the
    // event-level unread/pending counts belong to them.
    var showNotifications: Bool = false

    init(userId: String, onEventTap: @escaping (String) -> Void, showNotifications: Bool = false) {
        _viewModel = State(initialValue: CreatedEventsViewModel(userId: userId))
        self.onEventTap = onEventTap
        self.showNotifications = showNotifications
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                ForEach(viewModel.sections, id: \.0) { status, events in
                    EventsSectionHeader(status: status)
                    VStack(spacing: 8) {
                        ForEach(events) { event in
                            MyEventRow(event: event, showNotifications: showNotifications)
                                .padding(.horizontal, 16)
                                .onTapGesture{
                                    onEventTap(event.eventId)
                                }
                        }
                    }
                    .padding(.bottom, 16)
                }
            }
            .padding(.top, 8)
            .padding(.bottom, 80)
            .alert("Error", isPresented: $viewModel.isShowAlert) {
                Button("Ok", role: .cancel) {}
            } message: {
                Text(viewModel.alertMsg)
            }
        }
        .onAppear {
            viewModel.reloadEvents()
        }
    }
}


//#Preview {
//    CreatedEventsView()
//}
