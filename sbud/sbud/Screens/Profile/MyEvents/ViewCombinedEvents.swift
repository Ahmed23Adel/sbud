//
//  ViewCombinedEvents.swift
//  sbud
//
//  Created by ahmed on 14/05/2026.
//


import SwiftUI

struct ViewCombinedEvents: View {
    @EnvironmentObject var coordinator: ProfileCoordinator
    let userId: String
    @State private var myEventsExpanded: Bool = true
    @State private var joinedEventsExpanded: Bool = false

    var body: some View {
        ZStack {
            Color(red: 0.05, green: 0.05, blue: 0.05).ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 12) {
                    collapsibleWrapper(
                        title: "My Events",
                        icon: "calendar",
                        isExpanded: $myEventsExpanded,
                        onExpand: { joinedEventsExpanded = false }
                    ) {
                        ViewMyEvents(userId: userId)
                            .environmentObject(coordinator)
                    }

                    collapsibleWrapper(
                        title: "Participated Events",
                        icon: "person.2.fill",
                        isExpanded: $joinedEventsExpanded,
                        onExpand: { myEventsExpanded = false }
                    ) {
                        ViewJoinedEvents()
                            .environmentObject(coordinator)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.top, 12)
                .padding(.bottom, 80)
            }
        }
        .navigationTitle("Events")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Collapsible Wrapper

    @ViewBuilder
    private func collapsibleWrapper<Content: View>(
        title: String,
        icon: String,
        isExpanded: Binding<Bool>,
        onExpand: @escaping () -> Void,
        @ViewBuilder content: @escaping () -> Content
    ) -> some View {
        VStack(spacing: 0) {
            // Header
            Button {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.75)) {
                    if isExpanded.wrappedValue {
                        isExpanded.wrappedValue = false
                    } else {
                        onExpand()
                        isExpanded.wrappedValue = true
                    }
                }
            } label: {
                HStack(spacing: 10) {
                    Image(systemName: icon)
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(isExpanded.wrappedValue ? .white : .gray)

                    Text(title.uppercased())
                        .font(.system(size: 11, weight: .black, design: .monospaced))
                        .tracking(1.5)
                        .foregroundColor(isExpanded.wrappedValue ? .white : .gray)

                    Spacer()

                    Image(systemName: "chevron.down")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(isExpanded.wrappedValue ? .white : .gray)
                        .rotationEffect(.degrees(isExpanded.wrappedValue ? 0 : -90))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white.opacity(isExpanded.wrappedValue ? 0.07 : 0.03))
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.white.opacity(isExpanded.wrappedValue ? 0.15 : 0.06), lineWidth: 1)
                        )
                )
            }
            .buttonStyle(.plain)

            // Content
            if isExpanded.wrappedValue {
                content()
                    .transition(
                        .asymmetric(
                            insertion: .opacity.combined(with: .move(edge: .top)),
                            removal: .opacity.combined(with: .move(edge: .top))
                        )
                    )
            }
        }
    }
}
