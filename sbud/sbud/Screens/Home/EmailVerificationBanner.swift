//
//  EmailVerificationBanner.swift
//  sbud
//
//  Created by Riccardo Maria Cadario on 27/04/26.
//

import SwiftUI
import FirebaseAuth


struct EmailVerificationBanner: View {
    @State private var isReloading = false
    @State private var emailResent = false
    
    // Questa è la closure che riceve l'azione dalla ProfileSetupView
    var onVerified: () -> Void
    
    let iconNames = (1...14).map { "background-icon\($0)" }
    let numIconsShown = 8
    
    var body: some View {
        VStack(spacing: 12) {
            Text("You have to verify your email, control you inbox or spam.")
                .font(.subheadline)
                .fontWeight(.medium)
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
            
            HStack(spacing: 16) {
                Button {
                    Task {
                        isReloading = true
                        
                        // Ricarica l'utente da Firebase
                        try? await AuthenticationManagerEmailAndPassword.shared.reloadUser()
                        
                        // CONTROLLA SE È VERIFICATO E AVVISA LA VIEW PRINCIPALE
                        if Auth.auth().currentUser?.isEmailVerified == true {
                            await MainActor.run {
                                onVerified()
                            }
                        }
                        
                        isReloading = false
                    }
                } label: {
                    if isReloading {
                        ProgressView().tint(.backgroundColor)
                    } else {
                        Text("I verified")
                            .font(.footnote)
                            .fontWeight(.bold)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(Color.white)
                .foregroundColor(.backgroundColor)
                .cornerRadius(8)
                
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
        .background {
            GeometryReader { geometry in
                ZStack {
                    Color.backgroundColor
                    
                    ForEach(0..<numIconsShown, id: \.self) { _ in
                        FloatingIcon(
                            imgName: iconNames.randomElement() ?? "background-icon1",
                            size: CGFloat.random(in: 15...40),
                            positionX: CGFloat.random(in: 0...geometry.size.width),
                            positionY: CGFloat.random(in: 0...geometry.size.height)
                        )
                        .opacity(0.6)
                    }
                }
            }
        }
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

