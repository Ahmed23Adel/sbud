//
//  StepThreeView.swift
//  sbud
//
//  Created by Erdal on 23.03.2026.
//

import SwiftUI

struct StepThreeView: View {
    @EnvironmentObject var vm: ProfileSetupVM

    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            VStack(alignment: .leading, spacing: 10) {
                Text("COMPLETE YOUR\nDETAILS")
                    .font(.system(size: 32, weight: .black))
                    .foregroundColor(.white)
                    .lineSpacing(2)
                
                Text("Your biography is the tactical briefing for the community. Tell us more about yourself, your disciplines, and what boost your performance.")
                    .font(.system(size: 13))
                    .foregroundColor(.gray)
                    .lineSpacing(4)
            }
            
            VStack(alignment: .leading, spacing: 12) {
                Text("ATHLETIC BIO")
                    .font(.system(size: 10, weight: .bold))
                    .foregroundColor(.gray)
                    .kerning(1.2)
            ScrollView(showsIndicators: false) {
                ZStack(alignment: .topLeading) {

                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white.opacity(0.05))
                        .frame(height: 250)

                    TextEditor(text: $vm.profile.bio)
                        .scrollContentBackground(.hidden)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 12)
                        .foregroundColor(.white)
                        .accentColor(Color("palelime"))
                        .frame(height: 250)
                }
                .onChange(of: vm.profile.bio) { _ in vm.clearError() }
                if let err = vm.errorMessage {
                    Text(err)
                        .font(.caption)
                        .foregroundColor(Color("palelime"))
                        .padding(.top, 4)
                }
            }
            .padding(.top,10)
        }

            Spacer()
        }
        .onTapGesture {
            hideKeyboard()
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }
}

extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
