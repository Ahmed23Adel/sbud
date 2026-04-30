//
//  MyEvents.swift
//  sbud
//
//  Created by ahmed on 30/04/2026.
//

// There will be activites of type
// proposed
// confirmed
// completed
import SwiftUI

struct ViewMyEvents: View {
    @State var viewModel: ViewModelMyEvents
    @EnvironmentObject var coordinator: MainCoordinator

    init(userId: String) {
        _viewModel = State(initialValue: ViewModelMyEvents(userId: userId))
    }

    var body: some View {
        ZStack {
            Color(red: 0.05, green: 0.05, blue: 0.05).ignoresSafeArea()

            VStack(spacing: 0) {
                navBar

                if viewModel.usersEvents.isEmpty {
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
        }
        .navigationBarHidden(true)
        .alert("Error", isPresented: $viewModel.isShowAlert) {
            Button("Ok", role: .cancel) {}
        } message: {
            Text(viewModel.alertMsg)
        }
    }

    // MARK: - Nav Bar
    private var navBar: some View {
        HStack {
            Button { coordinator.goBack() } label: {
                Image(systemName: "chevron.left")
                    .font(.system(size: 18, weight: .bold))
                    .foregroundColor(.white)
            }

            Spacer()

            Text("MY EVENTS")
                .font(.system(size: 15, weight: .black))
                .foregroundColor(.white)
                .kerning(1.5)

            Spacer()

            // Balance chevron
            Color.clear.frame(width: 18, height: 18)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 12)
        .background(Color(red: 0.05, green: 0.05, blue: 0.05))
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
        Spacer()
            .frame(maxHeight: .infinity)
            .overlay {
                VStack(spacing: 16) {
                    Image(systemName: "calendar.badge.exclamationmark")
                        .font(.system(size: 48))
                        .foregroundColor(.white.opacity(0.2))
                    Text("NO EVENTS YET")
                        .font(.system(size: 14, weight: .black, design: .monospaced))
                        .foregroundColor(.white.opacity(0.3))
                        .kerning(1.5)
                    Text("Events you create will appear here.")
                        .font(.system(size: 12, design: .monospaced))
                        .foregroundColor(.gray)
                }
            }
    }
}

#Preview {
    ViewMyEvents(userId: "ExbXn3HBUHSrgjwCfYAgKi260k32")
        .environmentObject(MainCoordinator())
}
