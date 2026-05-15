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

        guard !trimmedPhone.isEmpty else {
            errorMessage = "Phone number is required."
            return false
        }

        do {
            _ = try phoneUtil.parse(trimmedPhone)
            errorMessage = nil
            return true
        } catch {
            errorMessage = "Invalid phone number."
            return false
        }
    }

    func normalizedPhoneNumber() -> String? {
        let trimmedPhone = trimmed(phoneNumber)

        guard !trimmedPhone.isEmpty else {
            errorMessage = "Phone number is required."
            return nil
        }

        do {
            let parsed = try phoneUtil.parse(trimmedPhone)
            errorMessage = nil
            return phoneUtil.format(parsed, toType: .e164)
        } catch {
            errorMessage = "Invalid phone number."
            return nil
        }
    }

    // MARK: - Location

    func requestCurrentLocation() {
        locationManager.requestPermission()
        locationManager.startUpdating()
    }

    func fillLocationFromDevice() {
        guard let coordinate = locationManager.userLocation else {
            errorMessage = "Location could not be retrieved."
            return
        }

        profile.location.latitude = coordinate.latitude
        profile.location.longitude = coordinate.longitude
    }

    func fillAddressDetails() {
        guard let coordinate = locationManager.userLocation else { return }

        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)

        CLGeocoder().reverseGeocodeLocation(location) { [weak self] placemarks, error in
            guard let self, error == nil, let placemark = placemarks?.first else { return }

            Task { @MainActor in
                self.profile.city = placemark.locality ?? ""
                self.profile.country = placemark.country ?? ""

                let parts = [
                    placemark.name,
                    placemark.locality,
                    placemark.administrativeArea,
                    placemark.country
                ]
                .compactMap { $0 }
                .filter { !$0.isEmpty }

                self.profile.location.fullAddress = parts.joined(separator: ", ")
            }
        }
    }

    // MARK: - Location

    func loadCurrentLocation() async {
        isLoading = true
        errorMessage = nil
        defer { isLoading = false }

        locationManager.requestPermission()

        // Wait up to 8 seconds for a valid coordinate
        let coordinate = await waitForLocation(timeout: 8.0)

        guard let coordinate else {
            errorMessage = "Location could not be retrieved. Please try again."
            return
        }

        profile.location.latitude = coordinate.latitude
        profile.location.longitude = coordinate.longitude
        fillAddressDetails()
    }

    private func waitForLocation(timeout: TimeInterval) async -> CLLocationCoordinate2D? {
        locationManager.startUpdating()

        let deadline = Date().addingTimeInterval(timeout)
        while Date() < deadline {
            if let coordinate = locationManager.userLocation {
                locationManager.stopUpdating()
                return coordinate
            }
            try? await Task.sleep(nanoseconds: 300_000_000) // poll every 0.3s
        }
        locationManager.stopUpdating()
        return nil
    }

    func handleSelectedPhoto() async {
        await MainActor.run {
            isLoading = true
            errorMessage = nil
        }

        guard let selectedItem else {
            await MainActor.run {
                isLoading = false
            }
            print("selectedItem nil")
            return
        }

        do {
            guard let data = try await selectedItem.loadTransferable(type: Data.self) else {
                await MainActor.run {
                    errorMessage = "Selected image could not be loaded."
                    isLoading = false
                }
                print("image data nil")
                return
            }

            print("original image data size:", data.count)

            guard let image = UIImage(data: data) else {
                await MainActor.run {
                    errorMessage = "Selected file is not a valid image."
                    isLoading = false
                }
                print("UIImage conversion failed")
                return
            }

            guard let compressedData = image.jpegData(compressionQuality: 0.7) else {
                await MainActor.run {
                    errorMessage = "Image compression failed."
                    isLoading = false
                }
                print("jpeg compression failed")
                return
            }

            print("compressed image data size:", compressedData.count)

            let uploadedImageURL = try await profileManager.uploadProfileImage(data: compressedData)
            print()

            await MainActor.run {
                selectedProfileImage = image
                profileImageData = compressedData
                profile.profileImageUrl = uploadedImageURL
                isLoading = false
            }

            print("upload success:", uploadedImageURL)

        } catch {
            await MainActor.run {
                errorMessage = "Photo upload failed: \(error.localizedDescription)"
                isLoading = false
            }
            print("handleSelectedPhoto upload error:", error.localizedDescription)
        }
    }
    
    // MARK: - Profile Setup
    
    private func prepareProfileForSave() async -> Bool {
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
        photo.selectedItem = item          // hand off to the service
        await photo.handleSelection()
    }
}

// MARK: - String helper (private to this module)

private extension String {
    var trimmed: String { trimmingCharacters(in: .whitespacesAndNewlines) }
}
