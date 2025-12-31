//
//  SignUpView.swift
//  sbud
//
//  Created by ahmed on 09/12/2025.
//

import SwiftUI

struct SignInView: View {
    @StateObject var viewModel = SignInViewModel()
    @EnvironmentObject var coordinator: MainCoordinator
    
    var body: some View {
        
            ZStack{ //START : ZStack
                
                AuthBackground()
                
                VStack{ //START : main //START : ZStack
                    Spacer()
                    Text("Sign in")
                        .foregroundColor(Color.mainColor)
                        .font(.system(size: 60, weight: .bold))
                        .accessibilityAddTraits(.isHeader)
                    
                    Text("Bring athletes closer")
                        .foregroundColor(Color.mainColor)
                        .font(.title3)
                    
                    VStack{
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
                            Text("Password must have more than six characters")
                                .font(.caption)
                                .foregroundColor(.red)
                                .padding(.leading, 5)
                        }
                    }
                    .padding(.horizontal)
                    
                    
                    Button {
                        Task {
                            try await viewModel.singIn()
                            
                        }
                    } label: {
                        Text("Sign In")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.black)
                            .frame(width: 330, height: 44)
                            .background(Color.mainColor )
                            .cornerRadius(10)
                        
                    }
                    .padding(.vertical)
                    .disabled(!viewModel.isFormValid || viewModel.isSigningIn)
                    
                    HStack{
                        
                        Button{
                            viewModel.isSigningIn = true
                            Task{
                                await viewModel.signUpWithGoogle()
                                viewModel.isSigningIn = false
                            }
                        } label: {
                            Image("google_ios_light_rd_na")
                                .resizable()
                                .frame(width: 50, height: 50)
                                .popUp(delay: 0.3)
                                .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
                                .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 2)
                        }
                        .disabled(viewModel.isSigningIn)
                    }
                    
                    
                    
                    Spacer()
                    
                    Button{
                        viewModel.goToSignUp()
                    } label: {
                        Text("Sign up instead?")
                            .foregroundColor(Color.mainColor)
                    }
                    .adaptiveSecondaryButtonStyle()
                    .popUp(delay: 0.3)
                    
                } //END : main //START : ZStack
            } //END : ZStack
            .onAppear{
                viewModel.setCoordinator(coordinator: coordinator)
            }
            .alert("Error", isPresented: $viewModel.showAlert){
                Button("Ok", role: .cancel) {}
            } message: {
                Text(viewModel.alertMsg)
            }
        
    }
    
}

struct SignInView_Previews: PreviewProvider{
    static var previews: some View {
        SignInView()
            .environmentObject(MainCoordinator())
    }
}
