//
//  StepThreeView.swift
//  sbud
//
//  Created by Erdal on 23.03.2026.
//

import SwiftUI
import SwiftUI
 
struct StepThreeView: View {
 
    @EnvironmentObject private var vm: ProfileSetupVM
 
    var body: some View {
        VStack(alignment: .leading, spacing: 20) {
            header
            bioEditor
            Spacer()
        }
        .onTapGesture { hideKeyboard() }
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }
 
    // MARK: - Subviews
 
    private var header: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("COMPLETE YOUR\nDETAILS")
                .font(.system(size: 32, weight: .black))
                .foregroundColor(.white)
                .lineSpacing(2)
 
            Text("Your biography is the tactical briefing for the community. Tell us more about yourself, your disciplines, and what boosts your performance.")
                .font(.system(size: 13))
                .foregroundColor(.gray)
                .lineSpacing(4)
        }
    }
 
    private var bioEditor: some View {
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
 
                if let error = vm.errorMessage {
                    Text(error)
                        .font(.caption)
                        .foregroundColor(Color("palelime"))
                        .padding(.top, 4)
                }
            }
            .padding(.top, 10)
        }
    }
}
