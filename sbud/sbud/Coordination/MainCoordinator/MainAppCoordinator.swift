//
//  MainAppCoordinator.swift
//  sbud
//
//  Created by ahmed on 10/12/2025.
//

import SwiftUI

struct MainAppCoordinator: View {
    @StateObject private var coordinator = MainCoordinator()
    
    var body: some View {
        ZStack {
            // Main content
            Group {
                switch coordinator.currentRoute {
                case .homePage:
                    HomeTabsView()
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)))
                case .signUp:
                    SignUpView()
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)))
                case .signIn:
                    SignInView()
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)))
                case .phoneLogin:
                    PhoneLoginView()
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)))
                case .otpVerification(let verificationID, let phoneNumber):
                    OTPVerificationView(viewModel: OTPViewModel(verificationID: verificationID, phoneNumber: phoneNumber))
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)))
                case .completeProfile(let phoneNumber):
                    // Sostituisci "CompleteProfileView" con il nome reale della tua vista
                    HomeTabsView()
                        .transition(.asymmetric(
                            insertion: .move(edge: .trailing).combined(with: .opacity),
                            removal: .move(edge: .leading).combined(with: .opacity)))
                
                }
            }
            .ignoresSafeArea()
            .animation(.easeInOut(duration: 0.3), value: coordinator.currentRoute)
            .environmentObject(coordinator)
            
            VStack{
                Spacer()
                PopUpStackView()
                    .padding()
            }
            
        }
    }
}

#Preview {
    MainAppCoordinator()
}
