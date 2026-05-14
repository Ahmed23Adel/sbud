//
//  ViewJoinedEvents.swift
//  sbud
//
//  Created by ahmed on 14/05/2026.
//

import SwiftUI

struct ViewJoinedEvents: View {
    @State var viewModel = ViewModelJoinedEvents()
    @EnvironmentObject var coordinator: ProfileCoordinator

    
    var body: some View {
        ZStack {
            Color(red: 0.05, green: 0.05, blue: 0.05).ignoresSafeArea()

            if viewModel.participatedEvents.isEmpty {
                emptyState
            } else {
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 0) {
                        ForEach(viewModel.sections, id: \.0) { status, events in
                            sectionHeader(for: status)
                            VStack(spacing: 8) {
                                ForEach(events) { event in
                                    MyEventRow(event: event)
                                        .padding(.horizontal, 16)
                                        .environmentObject(coordinator)
                                        .onTapGesture{
//                                            coordinator.goToMyEventDetails(eventId: event.eventId)
                                        }
                                }
                            }
                            .padding(.bottom, 16)
                        }
                    }
                    .padding(.top, 8)
                    .padding(.bottom, 80)
                }
            }
        }
        .navigationTitle("My Events")
        .navigationBarTitleDisplayMode(.inline)
        .alert("Error", isPresented: $viewModel.isShowAlert) {
            Button("Ok", role: .cancel) {}
        } message: {
            Text(viewModel.alertMsg)
        }
    }
    
    // MARK: - Section Header
    private func sectionHeader(for status: UsersEventStatus) -> some View {
        HStack(spacing: 8) {
            Image(systemName: status.icon)
                .font(.system(size: 11, weight: .bold))
                .foregroundColor(status.color)
            Text(status.rawValue.uppercased())
                .font(.system(size: 10, weight: .bold))
                .tracking(1.5)
                .foregroundColor(status.color)
            Spacer()
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 10)
    }

    // MARK: - Empty State
    private var emptyState: some View {
        VStack(spacing: 16) {
            Image(systemName: "calendar.badge.exclamationmark")
                .font(.system(size: 48))
                .foregroundColor(.white.opacity(0.2))
            Text("NO EVENTS YET")
                .font(.system(size: 14, weight: .black, design: .monospaced))
                .foregroundColor(.white.opacity(0.3))
                .kerning(1.5)
            Text("Events you participated will appear here.")
                .font(.system(size: 12, design: .monospaced))
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
//
//#Preview {
//    ViewJoinedEvents()
//}
