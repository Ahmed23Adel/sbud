//
//  SignUpView.swift
//  sbud
//
//  Created by ahmed on 09/12/2025.
//

import SwiftUI

struct SignInView: View {
    @StateObject var viewModel = SignInViewModel()
    @State var isSigningIn = false
    var body: some View {
        ZStack{ //START : ZStack
            Color.backgroundColor
                .ignoresSafeArea()
            VStack{ //START : main //START : ZStack
                Text("Sign In")
                    .foregroundColor(Color.mainColor)
                    .font(.title)
                    .bold()
                
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
                .disabled(isSigningIn)
                
                Button{
                    
                } label: {
                    Text("Sign up instead?")
                        .foregroundColor(Color.mainColor)
                        .font(.headline)
                        .underline()
                }
                
            } //END : main //START : ZStack
        } //END : ZStack
        .alert("Error", isPresented: $viewModel.showAlert){
            Button("Ok", role: .cancel) {}
        } message: {
            Text(viewModel.alertMsg)
        }
    }
}

#Preview {
    SignUpView()
}
