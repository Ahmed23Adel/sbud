//
//  EmailVerificationBanner.swift
//  sbud
//
//  Created by Riccardo Maria Cadario on 25/03/26.
//

import SwiftUI

struct EmailVerificationBanner: View {
    @State private var isReloading = false
    @State private var emailResent = false
    
    var body: some View {
        VStack(spacing: 12) {
            Text("You have to verify your email, control you inbox or spam.")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
            
            HStack(spacing: 16) {
                // Bottone per aggiornare lo stato
                Button {
                    Task {
                        isReloading = true
                        try? await AuthenticationManagerEmailAndPassword.shared.reloadUser()
                        isReloading = false
                    }
                } label: {
                    if isReloading {
                        ProgressView()
                            .tint(.blue)
                    } else {
                        Text("I verified")
                            .font(.footnote)
                            .fontWeight(.bold)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.white)
                .foregroundColor(.blue)
                .cornerRadius(8)
                
                // Bottone per reinviare l'email
                Button {
                    AuthenticationManagerEmailAndPassword.shared.sendVerificationEmail()
                    emailResent = true
                } label: {
                    Text(emailResent ? "Inviata!" : "Invia di nuovo")
                        .font(.footnote)
                        .fontWeight(.bold)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.clear)
                .foregroundColor(.white)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(Color.white, lineWidth: 1)
                )
                .disabled(emailResent)
            }
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(Color.blue.opacity(0.9)) // Scegli il colore che si adatta alla tua app
        .cornerRadius(12)
        .padding(.horizontal)
        .shadow(radius: 5)
    }
}

#Preview {
    EmailVerificationBanner()
}
