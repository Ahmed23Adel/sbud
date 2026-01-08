//
//  ProfileView.swift
//  sbud
//
//  Created by Erdal on 23/12/2025.
//

import SwiftUI
/*
struct ProfileView: View {
    @StateObject private var vm = ProfileVM()
    let authManager = AuthenticationManager.shared
    @EnvironmentObject var coordinator: MainCoordinator

    var body: some View {
        ScrollView {
            if let profile = vm.profile {
                VStack(alignment: .leading, spacing: 16) {
                    Text("PROFILE")
                        .font(.largeTitle.bold())

                    Group {
                        Text("Name: \(profile.fullName)")
                        Text("Country: \(profile.country)")
                        Text("City: \(profile.city)")
                        Text("Age: \(profile.age)")
                    }
                    .font(.body)

                    Divider()

                    Text("Activity: \(profile.preferredActivity.rawValue.capitalized)")
                        .font(.headline)

                    renderMetrics(for: profile)
                    
                    Button{
                        Task{
                            try await authManager.signOut()
                            coordinator.logout()
                        }
                    } label: {
                        Text("sign out")
                    }

                    Spacer()
                }
                .padding()
            } else if vm.isLoading {
                ProgressView("Loading Profile...")
            } else {
                Text("No profile data found.")
            }
        }
        .task {
            await vm.fetchProfileData()
        }
    }
        

    @ViewBuilder
    private func renderMetrics(for profile: UserProfile) -> some View {
        switch profile.preferredActivity {
        case .running:
            Text("Average Pace: \(profile.metrics.averagePace ?? "-")")
        case .cycling:
            Text("Average Speed: \(profile.metrics.averageSpeed ?? 0) km/h")
        case .football:
            Text("Goals per Match: \(profile.metrics.goalsPerMatch ?? 0)")
        }
    }
}
*/
