//
//  ViewHosts.swift
//  sbud
//

import SwiftUI
import Kingfisher

struct ViewHosts: View {
    @State var viewModel: ViewModelHosts

    init(eventId: String, userId: String) {
        _viewModel = State(initialValue: ViewModelHosts(eventId: eventId, userId: userId))
    }

    var body: some View {
        ZStack {
            Color.blackBackground.ignoresSafeArea()

            if viewModel.isLoading {
                ProgressView().tint(Color.mainColor)
            } else {
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 28) {
                        let hosts    = viewModel.friendHostItems.filter { $0.state == .host }
                        let pending  = viewModel.friendHostItems.filter { $0.state == .pending }
                        let declined = viewModel.friendHostItems.filter { $0.state == .rejected }
                        let none     = viewModel.friendHostItems.filter { $0.state == .notInvited }

                        if !hosts.isEmpty || !pending.isEmpty || !declined.isEmpty {
                            VStack(alignment: .leading, spacing: 10) {
                                SectionHeader(title: "INVITED", accent: .mainColor)
                                ForEach(hosts)    { row(for: $0) }
                                ForEach(pending)  { row(for: $0) }
                                ForEach(declined) { row(for: $0) }
                            }
                        }

                        if !none.isEmpty {
                            VStack(alignment: .leading, spacing: 10) {
                                SectionHeader(title: "FRIENDS", accent: .mainColor)
                                ForEach(none) { row(for: $0) }
                            }
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 24)
                    .padding(.bottom, 80)
                }
            }
        }
        .navigationTitle("Manage Hosts")
        .navigationBarTitleDisplayMode(.inline)
        .alert(viewModel.alertMsg, isPresented: $viewModel.isShowAlert) {
            Button("OK", role: .cancel) {}
        }
    }

    // Extracted to avoid repeating 4 closures inline across every ForEach
    private func row(for item: FriendHostItem) -> some View {
        FriendHostRow(
            item: item,
            accent: .mainColor,
            onInvite:   { Task { await viewModel.inviteHost(item: item) } },
            onCancel:   { Task { await viewModel.cancelInvitation(item: item) } },
            onRemove:   { Task { await viewModel.removeHost(item: item) } },
            onReInvite: { Task { await viewModel.reInviteHost(item: item) } }
        )
    }
}
