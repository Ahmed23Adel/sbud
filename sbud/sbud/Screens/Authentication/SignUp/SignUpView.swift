//
//  SignUpView.swift
//  sbud
//
//  Created by ahmed on 09/12/2025.
//

import SwiftUI
import Lottie

struct SignUpView: View {
    @StateObject var viewModel = SignUpViewModel()
    @EnvironmentObject var coordinator: MainCoordinator

    var body: some View {
            ZStack {
                AuthBackground()
                VStack {
                    Spacer()

                    Text("Sign up")
                        .foregroundColor(Color.mainColor)
                        .font(.system(size: 60, weight: .bold))
                        .accessibilityAddTraits(.isHeader)
                        .popUp()

                    Text("Bring athletes closer")
                        .foregroundColor(Color.mainColor)
                        .font(.title3)
                        .padding(.bottom, 15)
                        .popUp()

                    VStack(spacing: 8) {
                        TextField("Email: ", text: $viewModel.email)
                            .autocapitalization(.none)
                            .modifier(TextModifierSignUp())
                            .popUp()

                        HStack {
                            if viewModel.showPassword {
                                TextField("Password", text: $viewModel.password)
                                    .autocapitalization(.none)
                            } else {
                                SecureField("Password", text: $viewModel.password)
                                    .autocapitalization(.none)
                            }
                        }
                        .modifier(TextModifierSignUp())
                        .popUp()
                        .overlay(alignment: .trailing) {
                            Button {
                                viewModel.showPassword.toggle()
                            } label: {
                                Image(systemName: viewModel.showPassword ? "eye" : "eye.slash")
                                    .foregroundColor(.gray)
                                    .padding(.trailing, 25)
                            }
                        }

                        HStack {
                            if viewModel.showConfirmPassword {
                                TextField("Confirm Password", text: $viewModel.confirmPassword)
                                    .autocapitalization(.none)
                            } else {
                                SecureField("Confirm Password", text: $viewModel.confirmPassword)
                                    .autocapitalization(.none)
                            }
                        }
                        .modifier(TextModifierSignUp())
                        .popUp()
                        .overlay(alignment: .trailing) {
                            Button {
                                viewModel.showConfirmPassword.toggle()
                            } label: {
                                Image(systemName: viewModel.showConfirmPassword ? "eye" : "eye.slash")
                                    .foregroundColor(.gray)
                                    .padding(.trailing, 25)
                            }
                        }
                    }
                    .padding(.horizontal)

                    Button {
                        Task {
                            try await viewModel.signUpWithEmail()
                        }
                    } label: {
                        Text("Sign Up")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.black)
                            .frame(width: 330, height: 44)
                            .background(Color.mainColor)
                            .cornerRadius(20)
                            .shadow(radius: 10)
                    }
                    .padding(.vertical)
                    .popUp()

                    Button {
                        viewModel.isSigningIn = true
                        Task {
                            await viewModel.signUpWithGoogle()
                            viewModel.isSigningIn = false
                        }
                    } label: {
                        LottieView(animation: .named("GoogleLogoEffect"))
                            .playing()
                            .frame(width: 80, height: 80)
                    }
                    .popUp(delay: 0.3)
                    .disabled(viewModel.isSigningIn)

                    Spacer()

                    Button {
                        viewModel.goToSignIn()
                    } label: {
                        Text("Sign in instead?")
                            .foregroundColor(Color.mainColor)
                    }
                    .padding(.vertical, 35)
                    .adaptiveSecondaryButtonStyle()
                    .popUp(delay: 0.3)

                }
                if viewModel.isLoading {
                    MidnightLoadingView()
                }
            }
            .scrollDismissesKeyboard(.interactively)
            .toolbar {                                    // ← Single toolbar here
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button {
                        UIApplication.shared.sendAction(
                            #selector(UIResponder.resignFirstResponder),
                            to: nil, from: nil, for: nil
                        )
                    } label: {
                        Image(systemName: "keyboard.chevron.compact.down")
                            .foregroundStyle(Color.mainColor)
                    }
                }
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
//
//struct SignUpView_Previews: PreviewProvider {
//    static var previews: some View {
//        SignUpView()
//            .environmentObject(MainCoordinator())
//    }
//}
