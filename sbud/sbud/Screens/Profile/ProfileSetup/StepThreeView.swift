//
//  StepThreeView.swift
//  sbud
//
//  Created by Erdal on 23.03.2026.
//

import SwiftUI
import PhotosUI

struct StepThreeView: View {
    @EnvironmentObject var vm: ProfileSetupVM
    
    var body: some View {
        
        VStack(alignment: .leading, spacing: 0) {
            Text("Complete Your Details")
                .font(.system(size: 25, weight: .bold))
                .foregroundColor(.black)
                .padding(.top, 10)
            
            Text("Add a few more details for your profile.")
                .font(.system(size: 16))
                .foregroundColor(.gray)
                .lineSpacing(4)
                .padding(.top, 8)
            
            CustomMultilineField(
                title: "Bio",
                placeholder: "Tell us about yourself",
                text: Binding(
                    get: { vm.profile.bio ?? "" },
                    set: { vm.profile.bio = $0 })
            )
            .padding(.top, 30)
            .onChange(of: vm.profile.bio) { _ in
                vm.clearError()
            }
            
            preferredActivitySection
                .padding(.top, 10)
            
            if let err = vm.errorMessage {
                Text(err)
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding(.top, 8)
            }
        }
    }
}

private extension StepThreeView {
    var preferredActivitySection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Preferred Activity")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.black)
            
            Picker("Activity Type", selection: $vm.profile.preferredActivity) {
                ForEach(ActivityType.allCases, id: \.self) { type in
                    Text(type.rawValue.capitalized).tag(type)
                }
            }
            .padding(.horizontal, 8)
            .frame(height: 58)
            .frame(maxWidth: .infinity)
            .background(Color("textFieldColor"))
            .clipShape(RoundedRectangle(cornerRadius: 14, style: .continuous))
            .onChange(of: vm.profile.preferredActivity) { _ in
                vm.clearError()
            }
        }
    }
}
