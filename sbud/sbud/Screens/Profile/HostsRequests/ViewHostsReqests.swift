//
//  ViewHostsRequests.swift
//  sbud
//
//  Created by ahmed on 03/05/2026.
//

import SwiftUI

struct ViewHostsRequests: View {
    @State private var vm = ViewModelHostsRequests()

    var body: some View {
        ZStack {
            Color(red: 0.05, green: 0.05, blue: 0.05).ignoresSafeArea()

            VStack(spacing: 0) {
                Divider().background(Color(white: 0.12))

                if vm.isLoading {
                    MidnightLoadingView(text: "Loading hosts")
                        .ignoresSafeArea()
                } else if vm.invitations.isEmpty {
                    Spacer()
                    VStack(spacing: 12) {
                        Image(systemName: "star.slash")
                            .font(.system(size: 36))
                            .foregroundColor(Color(white: 0.25))
                        Text("No pending host invitations.")
                            .font(.system(size: 13, design: .monospaced))
                            .foregroundColor(.gray)
                    }
                    Spacer()
                } else {
                    ScrollView(showsIndicators: false) {
                        LazyVStack(spacing: 0) {
                            ForEach(vm.invitations) { item in
                                HostInvitationCell(item: item, vm: vm)
                                Divider().background(Color(white: 0.1))
                            }
                        }
                    }
                }
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(Color(red: 0.05, green: 0.05, blue: 0.05), for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.dark, for: .navigationBar)
        .toolbar {
            ToolbarItem(placement: .principal) {
                PageSectionTitle(title: "HOST INVITATIONS")
            }
        }
        .task { await vm.load() }
        .alert("Error", isPresented: Binding(
            get: { vm.errorMessage != nil },
            set: { if !$0 { vm.errorMessage = nil } }
        )) {
            Button("OK", role: .cancel) { vm.errorMessage = nil }
        } message: {
            Text(vm.errorMessage ?? "")
        }
    }
}


#Preview {
    NavigationStack {
        ViewHostsRequests()
    }
}
