//
//  HomeView.swift
//  sbud
//
//  Created by ahmed on 21/12/2025.
//

import SwiftUI
import FirebaseAuth

struct HomeView: View {
    
    @ObservedObject var authManager = AuthenticationManager.shared
    @EnvironmentObject var coordinator: MainCoordinator
    
    var body: some View {
        VStack{
            if let user = authManager.currentUser, let firebaseUser = Auth.auth().currentUser,
                !firebaseUser.isEmailVerified {
                EmailVerificationBanner()
                    .padding(.top)
                    .transition(.move(edge: .top).combined(with: .opacity))
            }
            
            Spacer()
            
            
            Button {
                Task {
                    try await authManager.signOut()
                    coordinator.goToSignUp()
                }
            } label: {
                Text("sign out")
            }
            Spacer()
        }
        .animation(.easeInOut, value: Auth.auth().currentUser?.isEmailVerified)
    }
}

#Preview {
    HomeView()
}
