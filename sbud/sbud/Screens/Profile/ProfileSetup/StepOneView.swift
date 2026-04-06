//
//  StepOneView.swift
//  sbud
//
//  Created by Erdal on 23.03.2026.
//

import SwiftUI
import PhotosUI

struct StepOneView: View {
    @EnvironmentObject var vm: ProfileSetupVM

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            Text("Tell Us About Yourself")
                .font(.system(size: 25, weight: .bold))
                .foregroundColor(.black)
                .padding(.top, 10)

            Text("Please enter your details to create your profile.")
                .font(.system(size: 16))
                .foregroundColor(.gray)
                .lineSpacing(4)
                .padding(.top, 8)
            
            profilePhotoPicker
                .padding(.top, 50)

            CustomInputField(
                title: "First Name",
                placeholder: "Enter first name",
                text: $vm.profile.name
            )
            .padding(.top, 30)
            .onChange(of: vm.profile.name) { _ in
                vm.clearError()
            }

            CustomInputField(
                title: "Last Name",
                placeholder: "Enter last name",
                text: $vm.profile.surName
            )
            .padding(.top, 10)
            .onChange(of: vm.profile.surName) { _ in
                vm.clearError()
            }

            if let errorMessage = vm.errorMessage {
                Text(errorMessage)
                    .font(.caption)
                    .foregroundColor(.red)
                    .padding(.top, 8)
            }
        }
    }
}

private extension StepOneView {
    var profilePhotoPicker: some View {
        HStack {
            Spacer()

            PhotosPicker(
                selection: $vm.selectedItem,
                matching: .images,
                photoLibrary: .shared()
            ) {
                Group {
                        if let uiImage = vm.selectedProfileImage {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                        } else {
                                Circle()
                                .fill(Color("textFieldColor"))
                                .overlay(
                                Image(systemName: "camera.fill")
                                    .font(.system(size: 28))
                                    .foregroundColor(.gray)
                            )
                    }
                }
                .frame(width: 120, height: 120)
                .clipShape(Circle())
            }
            .onChange(of: vm.selectedItem) {
                Task {
                    await vm.handleSelectedPhoto()
                }
            }

            Spacer()
        }
    }
}
