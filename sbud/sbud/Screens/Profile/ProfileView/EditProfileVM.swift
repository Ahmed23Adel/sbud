//
//  EditProfileVM.swift
//  sbud
//
//  Created by Erdal on 2.05.2026.
//

import Foundation
import SwiftUI
import PhotosUI
import FirebaseAuth
import Combine

@MainActor
final class EditProfileVM: ObservableObject {

    let original: UserProfile?

    @Published var email: String
    @Published var phone: String
    @Published var bio: String

    @Published var showPhotoPicker = false
    @Published var selectedPhotoItem: PhotosPickerItem?
    @Published var selectedImage: UIImage?
    private var newPhotoData: Data?

    @Published var emailError: String?
    @Published var phoneError: String?
    @Published var bioError: String?

    @Published var isSaving = false
    @Published var showError = false
    @Published var errorMessage: String?

    // MARK: - Dependencies
    private let profileManager = ProfileManager.shared
    private let userRepository = UserRepository()

    // MARK: - Change detection
    var hasChanges: Bool {
        email != (original?.email ?? "")
        || phone != (original?.phoneNumber ?? "")
        || bio != (original?.bio ?? "")
        || selectedImage != nil
    }

    init(profile: UserProfile?) {
        self.original = profile
        self.email = profile?.email ?? ""
        self.phone = profile?.phoneNumber ?? ""
        self.bio = profile?.bio ?? ""
    }

    // MARK: - Load selected photo from picker
    func loadSelectedPhoto() async {
        guard let item = selectedPhotoItem else { return }
        do {
            if let data = try await item.loadTransferable(type: Data.self),
               let uiImage = UIImage(data: data) {
                selectedImage = uiImage
                newPhotoData = data
            }
        } catch {
            errorMessage = "Could not load photo."
            showError = true
        }
    }

    @discardableResult
    func validate() -> Bool {
        emailError = nil
        phoneError = nil
        bioError = nil

        var valid = true

        let trimmedEmail = email.trimmingCharacters(in: .whitespaces)
        if trimmedEmail.isEmpty {
            emailError = "Email cannot be empty."
            valid = false
        } else if !trimmedEmail.contains("@") || !trimmedEmail.contains(".") {
            emailError = "Enter a valid email address."
            valid = false
        }

        let trimmedPhone = phone.trimmingCharacters(in: .whitespaces)
        if trimmedPhone.isEmpty {
            phoneError = "Phone number cannot be empty."
            valid = false
        } else {
            let digits = trimmedPhone.filter { $0.isNumber }
            if digits.count < 7 {
                phoneError = "Enter a valid phone number."
                valid = false
            }
        }

        let trimmedBio = bio.trimmingCharacters(in: .whitespaces)
        if trimmedBio.isEmpty {
            bioError = "Bio cannot be empty."
            valid = false
        }

        return valid
    }

    func save() async -> UserProfile? {
        guard validate() else { return nil }
        guard let uid = Auth.auth().currentUser?.uid,
              var profile = original else { return nil }

        isSaving = true
        defer { isSaving = false }

        var fields: [String: Any] = [:]

        let trimmedEmail = email.trimmingCharacters(in: .whitespaces)
        if trimmedEmail != profile.email {
            fields["email"] = trimmedEmail
            profile.email = trimmedEmail
        }

        let trimmedPhone = phone.trimmingCharacters(in: .whitespaces)
        if trimmedPhone != (profile.phoneNumber ?? "") {
            fields["phoneNumber"] = trimmedPhone.isEmpty ? NSNull() : trimmedPhone
            profile.phoneNumber = trimmedPhone.isEmpty ? nil : trimmedPhone
        }

        let trimmedBio = bio.trimmingCharacters(in: .whitespaces)
        if trimmedBio != profile.bio {
            fields["bio"] = trimmedBio
            profile.bio = trimmedBio
        }

        if let photoData = newPhotoData {
            do {
                let imageUrl = try await profileManager.uploadProfileImage(data: photoData)
                fields["profileImageUrl"] = imageUrl
                profile.profileImageUrl = imageUrl
            } catch {
                errorMessage = "Image upload failed: \(error.localizedDescription)"
                showError = true
                return nil
            }
        }

        guard !fields.isEmpty else { return profile }

        do {
            try await userRepository.updateUserProfileFields(uid: uid, fields: fields)
            profileManager.saveProfileToLocale(profile: profile)
            return profile
        } catch {
            errorMessage = error.localizedDescription
            showError = true
            return nil
        }
    }
}
