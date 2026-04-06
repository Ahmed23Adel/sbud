//
//  StepTwoView.swift
//  sbud
//
//  Created by Erdal on 23.03.2026.
//

import SwiftUI
import PhotosUI

struct StepTwoView: View {
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
            
            CustomPickerField(
                title: "Gender",
                selection: Binding(
                    get: { vm.profile.gender ?? "" },
                    set: { vm.profile.gender = $0 }),
                options: ["", "Male", "Female", "Prefer not to say"]
            )
            .padding(.top, 10)
            .onChange(of: vm.profile.gender) { _ in
                vm.clearError()
            }
            
            CustomDateField(
                title: "Birth Date",
                date: $vm.profile.birthDate
            )
            .padding(.top, 10)
            .onChange(of: vm.profile.birthDate) { _ in
                vm.clearError()
            }

            phoneNumberSection
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

private extension StepTwoView {
    var phoneNumberSection: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("Phone Number")
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(.black)
            
            PhoneNumberView(
                text: $vm.phoneNumber,
                placeholder: "Phone Number"
            )
            .padding(.horizontal, 16)
            .frame(height: 58)
            .background(Color("textFieldColor"))
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .onChange(of: vm.phoneNumber) { _ in
                vm.clearError()
            }
        }
    }
}
