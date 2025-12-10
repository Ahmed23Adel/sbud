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
    
    @State var isSigningIn = false
    var body: some View {
        ZStack{ //START : ZStack
            Color.backgroundColor
                .ignoresSafeArea()
            VStack{ //START : main //START : ZStack
                Text("Sign in")
                    .foregroundColor(Color.mainColor)
                    .font(.system(size: 60, weight: .bold))
                    .accessibilityAddTraits(.isHeader)
                
                Text("Bring athletes closer")
                    .foregroundColor(Color.mainColor)
                    .font(.title3)
                
                Button{
                    isSigningIn = true
                    Task{
                        await viewModel.signUpWithGoogle()
                        isSigningIn = false
                    }
                } label: {
                    Image("google_ios_light_rd_na")
                        .resizable()
                        .frame(width: 50, height: 50)
                        .popUp(delay: 0.3)
                        .shadow(color: .black.opacity(0.2), radius: 8, x: 0, y: 4)
                        .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 2)
                }
                .disabled(isSigningIn)
                
                Button{
                    viewModel.goToSignUp()
                } label: {
                    Text("Sign up instead?")
                        .foregroundColor(Color.mainColor)
                        .font(.caption)
                        .underline()
                        .popUp(delay: 0.3)
                        .padding()
                }
                
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
