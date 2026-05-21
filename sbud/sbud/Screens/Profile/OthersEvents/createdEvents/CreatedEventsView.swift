//
//  CreatedEventsView.swift
//  sbud
//
//  Created by ahmed on 21/05/2026.
//

import SwiftUI

struct CreatedEventsView: View {
    @State var viewModel: ViewModelMyEvents
    @EnvironmentObject var coordinator: ProfileCoordinator
    let onEventTap: (String) -> Void
    
    init(userId: String, onEventTap: @escaping (String) -> Void) {
        _viewModel = State(initialValue: ViewModelMyEvents(userId: userId))
        self.onEventTap = onEventTap
    }
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                ForEach(viewModel.sections, id: \.0) { status, events in
                    EventsSectionHeader(status: status)
                    VStack(spacing: 8) {
                        ForEach(events) { event in
                            MyEventRow(event: event)
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
            .onAppear{
//                viewModel.setCoordinator()
            }
        }
    }
}


//#Preview {
//    CreatedEventsView()
//}
