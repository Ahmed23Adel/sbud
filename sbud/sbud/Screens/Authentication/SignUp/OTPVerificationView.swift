//
//  OTPVerificationView.swift
//  sbud
//
//  Created by Riccardo Maria Cadario on 14/04/26.
//

import SwiftUI
import FirebaseAuth


struct OTPVerificationView: View {
    @ObservedObject var viewModel: OTPViewModel
    
    @EnvironmentObject var coordinator: MainCoordinator

    var body: some View {
        ZStack {
            AuthBackground()

            VStack(spacing: 20) {
                // ✅ Bottone indietro
                HStack {
                    Button {
                        coordinator.goToPhoneLogin()
                    } label: {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.mainColor)
                            .font(.title2)
                    }
                    Spacer()
                }
                .padding(.horizontal)

                Text("Verify Code")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.mainColor)

                Text("Insert the 6 digits numbers send to \(viewModel.phoneNumber)")
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)

                TextField("OTP Code", text: $viewModel.otpCode)
                    .keyboardType(.numberPad)
                    .modifier(TextModifierSignUp())
                    .padding(.horizontal)

                Button {
                    Task { await viewModel.verifyCodeAndSignIn() }
                } label: {
                    Text("Verify & Access")
                        .font(.headline)
                        .foregroundColor(.black)
                        .frame(width: 330, height: 44)
                        .background(Color.mainColor)
                        .cornerRadius(20)
                }

                Spacer()
            }
            .padding(.top, 50)

            if viewModel.isLoading { LoadingView() }
        }
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
