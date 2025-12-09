//
//  SignUpView.swift
//  sbud
//
//  Created by ahmed on 09/12/2025.
//

import SwiftUI

struct SignUpView: View {
    @StateObject var viewModel = SignUpViewModel()
    @State var isSigningIn = false
    var body: some View {
        ZStack{ //START : ZStack
            Color.backgroundColor
                .ignoresSafeArea()
            VStack{ //START : main //START : ZStack
                Text("Sign up")
                    .foregroundColor(Color.mainColor)
                    .font(.headline)
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
