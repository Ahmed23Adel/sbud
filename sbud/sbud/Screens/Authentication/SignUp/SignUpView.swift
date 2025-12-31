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
    
    
    
    
    var body: some View {
       
            ZStack { //START : ZStack
                Color.backgroundColor
                    .ignoresSafeArea()
                
                VStack { //START : main
                    Spacer()
                    
                    Text("Sign up")
                        .foregroundColor(Color.mainColor)
                        .font(.system(size: 60, weight: .bold))
                        .accessibilityAddTraits(.isHeader)
                    
                    Text("Bring athletes closer")
                        .foregroundColor(Color.mainColor)
                        .font(.title3)
                        .padding(.bottom, 15) //title space
                    
                    
                    VStack(spacing: 8) {
                        TextField("Enter your e-mail: ", text: $viewModel.email)
                            .autocapitalization(.none)
                            .modifier(TextModifierSignUp())
                        //email is valid?
                        if !viewModel.email.isEmpty && !viewModel.isValidEmail(viewModel.email) {
                            Text("Insert a valid email (es. name@mail.com)")
                                .font(.caption)
                                .foregroundColor(.red)
                                .padding(.leading, 5)
                        }
                        
                        //password logic
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
                        .overlay(alignment: .trailing) {
                            
                            Button {
                                viewModel.showPassword.toggle()
                            } label: {
                                Image(systemName: viewModel.showPassword ? "eye" : "eye.slash")
                                    .foregroundColor(.gray)
                                    .padding(.trailing, 25)
                            }
                        }
                        //password is valid
                        if !viewModel.password.isEmpty && viewModel.password.count <= 6 {
                            Text("Password must have more than 6 characters")
                                .font(.caption)
                                .foregroundColor(.red)
                                .padding(.leading, 5)
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
                            .background(Color.mainColor )
                            .cornerRadius(10)
                        
                    }
                    .padding(.vertical)
                    .disabled(!viewModel.isFormValid || viewModel.isSigningUp)
                    
                    
                    Button {
                        viewModel.isSigningIn = true
                        Task {
                            await viewModel.signUpWithGoogle()
                            viewModel.isSigningIn = false
                        }
                    } label: {
                        Image("google_ios_light_rd_na")
                            .resizable()
                            .frame(width: 50, height: 50)
                            .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
                            .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 2)
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
                    
                } //END : main
                
            } //END : ZStack
        
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


struct SignUpView_Previews: PreviewProvider{
    static var previews: some View {
        SignUpView()
            .environmentObject(MainCoordinator())
    }
}
