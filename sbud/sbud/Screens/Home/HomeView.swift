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
    
    private var isPhoneUser: Bool {
        Auth.auth().currentUser?.providerData
            .contains(where: { $0.providerID == "phone" }) ?? false
    }
    
    private var shouldShowEmailBanner: Bool {
        guard let firebaseUser = Auth.auth().currentUser else { return false }
        return !firebaseUser.isEmailVerified && !isPhoneUser
    }
    
    var body: some View {
        VStack{
            if shouldShowEmailBanner {
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
