//
//  SignUpView.swift
//  sbud
//
//  Created by ahmed on 09/12/2025.
//

import SwiftUI
import Lottie

struct SignInView: View {
    @StateObject var viewModel = SignInViewModel()
    @EnvironmentObject var coordinator: MainCoordinator

    var body: some View {

            ZStack {

                AuthBackground()

                VStack {
                    Spacer()
                    Text("Sign in")
                        .foregroundColor(Color.mainColor)
                        .font(.system(size: 60, weight: .bold))
                        .accessibilityAddTraits(.isHeader)
                        .popUp()

                    Text("Bring athletes closer")
                        .foregroundColor(Color.mainColor)
                        .font(.title3)
                        .popUp()

                    VStack {
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
                    }
                    .padding(.horizontal)

                    Button {
                        Task {
                            try await viewModel.singInWithEmail()

                        }
                    } label: {
                        Text("Sign In")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.black)
                            .frame(width: 330, height: 44)
                            .background(Color.mainColor )
                            .cornerRadius(20)

                    }
                    .popUp()
                    .padding(.vertical)

                    HStack (spacing: 30) {
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
                        .disabled(viewModel.isSigningIn)
                        
                       
                        
                    }

                    Spacer()

                    Button {
                        viewModel.goToSignUp()
                    } label: {
                        Text("Sign up instead?")
                            .foregroundColor(Color.mainColor)
                    }
                    .adaptiveSecondaryButtonStyle()
                    .popUp(delay: 0.3)
                }
                if viewModel.isLoading {
                    LoadingView()
                }
            }
            .scrollDismissesKeyboard(.interactively)
            .toolbar {                                    // ← Single toolbar here
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer()
                    Button("✓") {
                        // UIKIT organizes the views
                        // first responder is the one that has focus now
                        // to dismiss, whoever the first responder is, resign
                        // UIApplication.shared: running instance of app
                        // #selector(UIResponder.resignFirstResponder) — the action to perform.
                        // to: nil — the target. nil means "don't send it to a specific object" — instead, walk the responder chain and let whoever can handle it respond
                        // from: nil — the sender. Who is triggering this action. nil means anonymous/unspecified
                        UIApplication.shared.sendAction(
                                #selector(UIResponder.resignFirstResponder),
                                to: nil, from: nil, for: nil
                            )
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

struct SignInView_Previews: PreviewProvider {
    static var previews: some View {
        SignInView()
            .environmentObject(MainCoordinator())
    }
}
