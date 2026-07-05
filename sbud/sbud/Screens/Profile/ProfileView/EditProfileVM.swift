//
//  EditProfileVM.swift
//  sbud
//
//  Created by Erdal on 2.05.2026.
//

import Foundation
import SwiftUI
import PhotosUI
import Combine

@MainActor
final class EditProfileVM: ObservableObject {

    let original: UserProfile?

    @Published var name: String
    @Published var surName: String
    @Published var bio: String
    @Published var preferredActivity: ActivityType
    @Published var birthDate: Date
    @Published var showPhotoPicker = false
    @Published var showCalendar = false
    @Published var tempBirthDate: Date
    @Published var selectedPhotoItem: PhotosPickerItem?
    @Published var selectedImage: UIImage?
    private var newPhotoData: Data?

    @Published var nameError: String?
    @Published var surNameError: String?
    @Published var bioError: String?
    @Published var isSaving = false
    @Published var showError = false
    @Published var errorMessage: String?

    private let profileManager: IProfileServiceManager
    private let userRepository: UserProfileUpdating
    private let currentUserProvider: CurrentUserProviding

    var hasChanges: Bool {
        name             != (original?.name ?? "")
        || surName       != (original?.surName ?? "")
        || bio           != (original?.bio ?? "")
        || preferredActivity != (original?.preferredActivity ?? .running)
        || !Calendar.current.isDate(birthDate, inSameDayAs: original?.birthDate ?? Date())
        || selectedImage != nil
    }

    init(
        profile: UserProfile?,
        profileManager: IProfileServiceManager = ProfileManager.shared,
        userRepository: UserProfileUpdating = UserRepository(),
        currentUserProvider: CurrentUserProviding = FirebaseCurrentUserProvider()
    ) {
        self.original            = profile
        self.name                = profile?.name ?? ""
        self.surName             = profile?.surName ?? ""
        self.bio                 = profile?.bio ?? ""
        self.preferredActivity   = profile?.preferredActivity ?? .running
        let defaultDate = Calendar.current.date(byAdding: .year, value: -18, to: Date()) ?? Date()
        self.birthDate           = profile?.birthDate ?? defaultDate
        self.tempBirthDate       = profile?.birthDate ?? defaultDate
        self.profileManager      = profileManager
        self.userRepository      = userRepository
        self.currentUserProvider = currentUserProvider
    }

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
        nameError = nil; surNameError = nil; bioError = nil
        var valid = true
        if name.trimmingCharacters(in: .whitespaces).isEmpty {
            nameError = "Name cannot be empty."; valid = false
        }
        if surName.trimmingCharacters(in: .whitespaces).isEmpty {
            surNameError = "Surname cannot be empty."; valid = false
        }
        let age = Calendar.current.dateComponents([.year], from: birthDate, to: Date()).year ?? 0
        if age < 18 { errorMessage = "You must be at least 18 years old."; showError = true; valid = false }
        if bio.trimmingCharacters(in: .whitespaces).count > 120 {
            bioError = "Bio cannot exceed 120 characters."; valid = false
        }
        return valid
    }

    func save() async -> UserProfile? {
        guard validate() else { return nil }
        guard let uid = currentUserProvider.currentUserId, var profile = original else { return nil }
        isSaving = true
        defer { isSaving = false }
        var fields: [String: Any] = [:]

        let trimmedName = name.trimmingCharacters(in: .whitespaces)
        if trimmedName != profile.name { fields["name"] = trimmedName; profile.name = trimmedName }

        let trimmedSurName = surName.trimmingCharacters(in: .whitespaces)
        if trimmedSurName != profile.surName { fields["surName"] = trimmedSurName; profile.surName = trimmedSurName }

        let trimmedBio = bio.trimmingCharacters(in: .whitespaces)
        if trimmedBio != profile.bio { fields["bio"] = trimmedBio; profile.bio = trimmedBio }

        if preferredActivity != profile.preferredActivity {
            fields["preferredActivity"] = preferredActivity.rawValue
            profile.preferredActivity = preferredActivity
        }
        if let oldBirth = profile.birthDate {
            if !Calendar.current.isDate(birthDate, inSameDayAs: oldBirth) {
                fields["birthDate"] = birthDate.timeIntervalSince1970; profile.birthDate = birthDate
            }
        } else {
            fields["birthDate"] = birthDate.timeIntervalSince1970; profile.birthDate = birthDate
        }
        if let photoData = newPhotoData {
            do {
                let url = try await profileManager.uploadProfileImage(data: photoData)
                fields["profileImageUrl"] = url; profile.profileImageUrl = url
            } catch {
                errorMessage = "Image upload failed: \(error.localizedDescription)"; showError = true; return nil
            }
        }
        guard !fields.isEmpty else { return profile }
        do {
            try await userRepository.updateUserProfileFields(uid: uid, fields: fields)
            profileManager.saveProfileToLocale(profile: profile)
            return profile
        } catch {
            errorMessage = error.localizedDescription; showError = true; return nil
        }
    }
}
