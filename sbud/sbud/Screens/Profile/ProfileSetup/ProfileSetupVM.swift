//
//  ProfileViewModel.swift
//  sbud
//
//  Created by Erdal on 23.03.2026.
//


import Foundation
import FirebaseAuth
import Combine
import Foundation
import FirebaseAuth
import Combine
import PhoneNumberKit
import _PhotosUI_SwiftUI
@MainActor
final class ProfileSetupVM: ObservableObject {

    // MARK: - Shared form state

    @Published var profile: UserProfile
    @Published var phoneNumber: String = ""
    @Published var errorMessage: String?
    @Published var isSaving = false
    @Published var previewImage: UIImage?
    @Published var isUploadingPhoto: Bool = false

    // MARK: - Child services (injected for testability)

    // Pull selectedItem up — PhotosPicker binds to this directly
    @Published var selectedPhotoItem: PhotosPickerItem?

    // photo and location stay @Published for observation
    @Published var photo: PhotoService
    @Published var location: LocationService

    // MARK: - Dependencies

    private let profileManager: ProfileManager

    // MARK: - Init

    init(
        profileManager: ProfileManager = .shared,
        photoService: PhotoService? = nil,
        locationService: LocationService? = nil
    ) {
        self.profileManager = profileManager
        self.photo    = photoService    ?? PhotoService()
        self.location = locationService ?? LocationService()

        let uid = Auth.auth().currentUser?.uid ?? ""
        self.profile = UserProfile(id: uid)
    }
    
    // MARK: - Error helpers

    func clearError() { errorMessage = nil }

    // MARK: - Step validators
    // Each returns true/false and sets errorMessage on failure.
    // These are the validation closures passed to the coordinator.

    func validateStepOne() -> Bool {
        guard photo.uploadedURL != nil else {
            errorMessage = "Profile image is required."
            return false
        }
        guard !profile.name.trimmed.isEmpty else {
            errorMessage = "First name is required."
            return false
        }
        guard !profile.surName.trimmed.isEmpty else {
            errorMessage = "Last name is required."
            return false
        }
        errorMessage = nil
        return true
    }

    func validateStepTwo() -> Bool {
        guard PhoneService.validate(phoneNumber) else {
            errorMessage = phoneNumber.trimmed.isEmpty
                ? "Phone number is required."
                : "Invalid phone number."
            return false
        }
        guard let gender = profile.gender, !gender.trimmed.isEmpty else {
            errorMessage = "Please select your gender."
            return false
        }
        guard let birthDate = profile.birthDate else {
            errorMessage = "Please select your birth date."
            return false
        }
        if let age = profile.age, age < 18 {
            errorMessage = "Under 18 years old not allowed."
            return false
        }
        errorMessage = nil
        return true
    }

    func validateStepThree() -> Bool {
        guard !profile.bio.trimmed.isEmpty else {
            errorMessage = "Bio is required."
            return false
        }
        errorMessage = nil
        return true
    }

    func validateStepFour() -> Bool {
        guard location.isAcquired else {
            errorMessage = "Location could not be determined."
            return false
        }
        errorMessage = nil
        return true
    }

    // MARK: - Persist

    func save() async -> Bool {
        guard validateStepOne(),
              validateStepTwo(),
              validateStepThree(),
              validateStepFour()
        else { return false }

        guard let user = Auth.auth().currentUser else {
            errorMessage = "User not authenticated."
            return false
        }
        guard let e164 = PhoneService.e164(phoneNumber) else {
            errorMessage = "Invalid phone number."
            return false
        }

        // Hydrate fields from services before writing to Firestore.
        profile.email       = user.email ?? ""
        profile.phoneNumber = e164
        profile.profileImageUrl = photo.uploadedURL
        profile.location.latitude    = location.latitude
        profile.location.longitude   = location.longitude
        profile.city                 = location.city
        profile.country              = location.country
        profile.location.fullAddress = location.fullAddress

        isSaving = true
        defer { isSaving = false }

        do {
            profile.isProfileCompleted = true
            try await profileManager.saveProfileToDatabase(profile: profile)
            profileManager.saveProfileToLocale(profile: profile)
            return true
        } catch {
            errorMessage = error.localizedDescription
            profile.isProfileCompleted = false
            return false
        }
    }
    
    func handlePhotoSelection() async {
        guard let item = selectedPhotoItem else { return }
        isUploadingPhoto = true
        // Hemen önizleme — loadTransferable tamamlanır tamamlanmaz göster
        if let data = try? await item.loadTransferable(type: Data.self),
           let image = UIImage(data: data) {
            previewImage = image
        }
        photo.selectedItem = item
        await photo.handleSelection()
        isUploadingPhoto = false
    }
}

// MARK: - String helper (private to this module)

private extension String {
    var trimmed: String { trimmingCharacters(in: .whitespacesAndNewlines) }
}
