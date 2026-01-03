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
        Button {
            Task {
                try await authManager.signOut()
                coordinator.goToSignUp()
            }
        } label: {
            Text("sign out")
        }
    }
}

#Preview {
    HomeView()
}
