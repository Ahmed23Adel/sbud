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
            

            VStack(alignment: .leading, spacing: 15) {
                Text("TELL US ABOUT\nYOURSELF")
                    .font(.system(size: 32, weight: .black))
                    .foregroundColor(.white)
                    .lineSpacing(-5)
            }
            .padding(.bottom, 20)

            ScrollView(showsIndicators: false) {

                VStack(alignment: .leading, spacing: 25) {
                    
                    profilePhotoPicker
                        .frame(maxWidth: .infinity)

                    VStack(alignment: .leading, spacing: 20) {
                        customTextField(title: "FIRST NAME", placeholder: "", text: $vm.profile.name)
                            .onChange(of: vm.profile.name) { _ in vm.clearError() }
                        
                        customTextField(title: "LAST NAME", placeholder: "", text: $vm.profile.surName)
                            .onChange(of: vm.profile.surName) { _ in vm.clearError() }
                        
                        if let errorMessage1 = vm.errorMessage {
                            Text(errorMessage1)
                                .font(.caption)
                                .foregroundColor(Color("palelime"))
                                .padding(.top,-2)
                        }
                    }
                    

                    Color.clear.frame(height: 120)
                }
                .frame(maxWidth: .infinity, alignment: .topLeading)

                .fixedSize(horizontal: false, vertical: true)
            }
        }
        .onTapGesture {
            hideKeyboard()
        }
    }
}

// MARK: - Subviews Extension
private extension StepOneView {
    var profilePhotoPicker: some View {
        PhotosPicker(
            selection: $vm.selectedItem,
            matching: .images,
            photoLibrary: .shared()
        ) {
            ZStack {
                RoundedRectangle(cornerRadius: 4)
                    .fill(Color.white.opacity(0.03))
                
                VStack(spacing: 15) {
                    if let uiImage = vm.selectedProfileImage {
                        Image(uiImage: uiImage)
                            .resizable()
                            .scaledToFill()
                            .frame(width: 100, height: 100)
                            .clipShape(Circle())
                    } else {
                        Image(systemName: "camera")
                            .font(.system(size: 30))
                            .foregroundColor(.gray)
                            .padding(25)
                            .overlay(
                                Circle()
                                    .stroke(Color.gray, style: StrokeStyle(lineWidth: 1, dash: [5]))
                            )
                    }
                    
                    VStack(spacing: 4) {
                        Text(vm.isLoading ? "UPLOADING..." : "UPLOAD PROFILE IMAGE")
                            .font(.system(size: 13, weight: .bold))
                            .foregroundColor(.white)
                        
                        Text("REQUIRED FOR PROFILE CREATE")
                            .font(.system(size: 10))
                            .foregroundColor(.gray.opacity(0.7))
                            .kerning(1.2)
                    }
                }
            }
            .frame(height: 220)
            .frame(maxWidth: .infinity)
            .border(Color.white.opacity(0.1), width: 1)
        }
        .onChange(of: vm.selectedItem) { _ in
            Task { await vm.handleSelectedPhoto() }
        }
        .onChange(of: vm.selectedItem) { _ in vm.clearError() }
    }
}
