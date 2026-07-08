//
//  StepOneView.swift
//  sbud
//
//  Created by Erdal on 23.03.2026.
//

import SwiftUI
import PhotosUI
import Photos

struct StepOneView: View {

    @EnvironmentObject private var vm: ProfileSetupVM
    @State private var showSettingsAlert = false
    @State private var authStatus = PHPhotoLibrary.authorizationStatus(for: .readWrite)

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            header
                .padding(.bottom, 20)

            ScrollView(showsIndicators: false) {
                VStack(alignment: .leading, spacing: 25) {
                    photoPicker
                        .frame(maxWidth: .infinity)

                    nameFields

                    Color.clear.frame(height: 120)
                }
                .frame(maxWidth: .infinity, alignment: .topLeading)
                .fixedSize(horizontal: false, vertical: true)
            }
        }
        .onTapGesture { hideKeyboard() }
        .onAppear { authStatus = PHPhotoLibrary.authorizationStatus(for: .readWrite) }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
            authStatus = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        }
    }

    // MARK: - Subviews

    private var header: some View {
        Text("TELL US ABOUT\nYOURSELF")
            .font(.system(size: 32, weight: .black))
            .foregroundColor(.white)
            .lineSpacing(-5)
    }

    private var photoPicker: some View {
        Group {
            if photoAccessDenied {
                Button {
                    showSettingsAlert = true
                } label: {
                    photoPickerLabel
                }
                .alert("Photo Library Access Required", isPresented: $showSettingsAlert) {
                    Button("Open Settings") {
                        if let url = URL(string: UIApplication.openSettingsURLString) {
                            UIApplication.shared.open(url)
                        }
                    }
                    Button("Cancel", role: .cancel) {}
                } message: {
                    Text("sBud needs access to your photos. Please enable it in Settings → Privacy → Photos.")
                }
            } else {
                PhotosPicker(
                    selection: $vm.selectedPhotoItem,
                    matching: .images,
                    photoLibrary: .shared()
                ) {
                    photoPickerLabel
                }
                .simultaneousGesture(TapGesture().onEnded {
                    if authStatus == .notDetermined {
                        PHPhotoLibrary.requestAuthorization(for: .readWrite) { newStatus in
                            DispatchQueue.main.async {
                                authStatus = newStatus
                            }
                        }
                    }
                })
                .onChange(of: vm.selectedPhotoItem) { _ in
                    Task { await vm.handlePhotoSelection() }
                    vm.clearError()
                }
            }
        }
    }

    private var photoAccessDenied: Bool {
        authStatus == .denied || authStatus == .restricted
    }
    private var photoPickerLabel: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 4)
                .fill(Color.white.opacity(0.03))

            VStack(spacing: 15) {
                if let image = vm.previewImage {
                    Image(uiImage: image)
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
                            Circle().stroke(
                                Color.gray,
                                style: StrokeStyle(lineWidth: 1, dash: [5])
                            )
                        )
                }

                VStack(spacing: 4) {
                    Text(vm.isUploadingPhoto ? "UPLOADING..." : "UPLOAD PROFILE IMAGE")
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

    private var nameFields: some View {
        VStack(alignment: .leading, spacing: 20) {
            customTextField(title: "FIRST NAME", placeholder: "", text: $vm.profile.name)
                .onChange(of: vm.profile.name) { _ in vm.clearError() }

            customTextField(title: "LAST NAME", placeholder: "", text: $vm.profile.surName)
                .onChange(of: vm.profile.surName) { _ in vm.clearError() }

            if let error = vm.errorMessage {
                Text(error)
                    .font(.caption)
                    .foregroundColor(Color("palelime"))
            }
        }
    }
}

