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
    
    @State private var isSigningUp = false
    @State var isSigningIn = false
    
    // Stato per la visibilità della password
    @State private var showPassword = false
    
    var isFormValid: Bool {
        return isValidEmail(viewModel.email) && viewModel.password.count > 6
    }
    
    var body: some View {
        NavigationStack {
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
                        if !viewModel.email.isEmpty && !isValidEmail(viewModel.email) {
                            Text("Inserisci un'email valida (es. nome@mail.com)")
                                .font(.caption)
                                .foregroundColor(.red)
                                .padding(.leading, 5)
                        }
                        
                        //password logic
                        HStack {
                            if showPassword {
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
                                showPassword.toggle()
                            } label: {
                                Image(systemName: showPassword ? "eye" : "eye.slash")
                                    .foregroundColor(.gray)
                                    .padding(.trailing, 25)
                            }
                        }
                        //password is valid
                        if !viewModel.password.isEmpty && viewModel.password.count <= 6 {
                            Text("La password deve avere almeno 7 caratteri")
                                .font(.caption)
                                .foregroundColor(.red)
                                .padding(.leading, 5)
                        }
                    }
                    .padding(.horizontal)
                    
                    
                    Button {
                        Task {
                            try await viewModel.createUser()
                            
                        }
                    } label: {
                        Text("Complete Sign Up")
                            .font(.subheadline)
                            .fontWeight(.semibold)
                            .foregroundColor(.black)
                            .frame(width: 330, height: 44)
                            .background(Color.mainColor )
                            .cornerRadius(10)
                        
                    }
                    .padding(.vertical)
                    .disabled(!isFormValid || isSigningUp)
                    
                    
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
    func isValidEmail(_ email: String) -> Bool {
        let emailRegex = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPredicate = NSPredicate(format:"SELF MATCHES %@", emailRegex)
        return emailPredicate.evaluate(with: email)
    }
}


struct SignUpView_Previews: PreviewProvider{
    static var previews: some View {
        SignUpView()
            .environmentObject(MainCoordinator())
    }
}
