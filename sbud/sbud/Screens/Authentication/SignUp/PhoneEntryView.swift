//
//  PhoneEntryView.swift
//  sbud
//
//  Created by Riccardo Maria Cadario on 26/03/26.
//
import SwiftUI

struct PhoneLoginView: View {
    @StateObject var viewModel = PhoneLoginViewModel()
    @EnvironmentObject var coordinator: MainCoordinator
    
    var body: some View {
        ZStack {
            AuthBackground() // Il tuo background custom
            
            
            
            VStack(spacing: 20) {
                
                //back bottom
                HStack {
                    Button {
                        coordinator.goToSignIn()
                    } label: {
                        Image(systemName: "chevron.left")
                            .foregroundColor(.mainColor)
                            .font(.title2)
                    }
                    Spacer()
                }
                .padding(.horizontal)
                
                Text("Login via Phone")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.mainColor)
                
                TextField("Phone Number (es. +39 333...)", text: $viewModel.phoneNumber)
                    .keyboardType(.phonePad)
                    .modifier(TextModifierSignUp()) // Il tuo modifier custom
                    .padding(.horizontal)
                
                Button {
                    Task { await viewModel.sendVerificationCode() }
                } label: {
                    Text("Send SMS")
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
        .onAppear { viewModel.setCoordinator(coordinator: coordinator) }
        .alert("Error", isPresented: $viewModel.showAlert) {
            Button("Ok", role: .cancel) {}
        } message: {
            Text(viewModel.alertMsg)
        }
    }
}
#Preview {
    PhoneLoginView()
}
