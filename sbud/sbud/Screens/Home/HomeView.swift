//
//  HomeView.swift
//  sbud
//
//  Created by ahmed on 21/12/2025.
//

import SwiftUI

struct HomeView: View {
    let authManager = AuthenticationManager.shared
    @EnvironmentObject var coordinator: MainCoordinator
    var body: some View {
        HStack(spacing: 5){
            Button {
                Task {
                    try await authManager.signOut()
                    coordinator.logout()
                }
            } label: {
                Text("sign out")
            }
            Button {
                coordinator.goToProfile(userId: "Ab68s84r9IZMGtbKt16rnCUt5KS2")
            } label: {
                Text("Test Profile")
            }
        }
    }
}

#Preview {
    HomeView()
}
