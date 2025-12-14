//
//  SignUpView.swift
//  sbud
//
//  Created by ahmed on 09/12/2025.
//

import SwiftUI

struct SignUpView: View {
    @StateObject var viewModel = SignUpViewModel()
    @EnvironmentObject var coordinator: MainCoordinator

    @State var isSigningIn = false
    var body: some View {
        ZStack { // START : ZStack
            Color.backgroundColor
                .ignoresSafeArea()
            VStack { // START : main
                Text("Sign up")
                    .foregroundColor(Color.mainColor)
                    .font(.system(size: 60, weight: .bold))
                    .accessibilityAddTraits(.isHeader)
                Text("Bring athletes closer")
                    .foregroundColor(Color.mainColor)
                    .font(.title3)

                Button {
                    isSigningIn = true
                    Task {
                        await viewModel.signUpWithGoogle()
                        isSigningIn = false
                    }
                } label: {
                    Image("google_ios_light_rd_na")
                        .resizable()
                        .frame(width: 50, height: 50)
                        .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
                        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 2)
                }
                .popUp(delay: 0.3)
                .disabled(isSigningIn)

                Button {
                    viewModel.goToSignIn()
                } label: {
                    Text("Sign in instead?")
                        .foregroundColor(Color.mainColor)
                }
                .buttonStyle(.glass)
                .popUp(delay: 0.3)

            } // END : main
        } // END : ZStack
        .onAppear {
            viewModel.setCoordinator(coordinator: coordinator)
        }
        .alert("Error", isPresented: $viewModel.showAlert) {
            Button("Ok", role: .cancel) {}
        } message: {
            Text(viewModel.alertMsg)
        }

    }
}

struct SignUpView_Previews: PreviewProvider {
    static var previews: some View {
        SignUpView()
            .environmentObject(MainCoordinator(authManager: AuthenticationManager.shared))
    }
}
