//
//  ViewHosts.swift
//  sbud
//
//  Created by ahmed on 01/05/2026.
//

import SwiftUI
import SwiftUI
import Kingfisher

struct ViewHosts: View {
    @State var viewModel: ViewModelHosts

    init(eventId: String, userId: String) {
        _viewModel = State(initialValue: ViewModelHosts(eventId: eventId, userId: userId))
    }

    var body: some View {
        ZStack {
            Color.blackBackground
                .ignoresSafeArea()

            if viewModel.isLoading {
                ProgressView()
                    .tint(Color.mainColor)
            } else {
                ScrollView(showsIndicators: false) {
                    VStack(alignment: .leading, spacing: 28) {
                        let hosts    = viewModel.friendHostItems.filter { $0.state == .host }
                        let pending  = viewModel.friendHostItems.filter { $0.state == .pending }
                        let declined = viewModel.friendHostItems.filter { $0.state == .rejected }
                        let none     = viewModel.friendHostItems.filter { $0.state == .notInvited }

                        if !hosts.isEmpty || !pending.isEmpty || !declined.isEmpty {
                            VStack(alignment: .leading, spacing: 10) {
                                SectionHeader(title: "INVITED", accent: Color.mainColor)
                                ForEach(hosts)    { FriendHostRow(item: $0, accent: Color.mainColor) }
                                ForEach(pending)  { FriendHostRow(item: $0, accent: Color.mainColor) }
                                ForEach(declined) { FriendHostRow(item: $0, accent: Color.mainColor) }
                            }
                        }

                        if !none.isEmpty {
                            VStack(alignment: .leading, spacing: 10) {
                                SectionHeader(title: "FRIENDS", accent: Color.mainColor)
                                ForEach(none) { FriendHostRow(item: $0, accent: Color.mainColor) }
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
}

