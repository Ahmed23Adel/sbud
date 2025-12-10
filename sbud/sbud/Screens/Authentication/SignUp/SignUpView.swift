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
        ZStack{ //START : ZStack
            Color.backgroundColor
                .ignoresSafeArea()
            VStack{ //START : main //START : ZStack
                Text("Sign up")
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
                    Image("ios_light_rd_na")
                        .resizable()
                        .frame(width: 50, height: 50)
                }
                .popUp(delay: 0.3)
                .disabled(isSigningIn)
                
                Button{
                    viewModel.goToSignIn()
                } label: {
                    Text("Sign in instead?")
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


struct SignUpView_Previews: PreviewProvider{
    static var previews: some View {
        SignUpView()
            .environmentObject(MainCoordinator())
    }
}
