//
//  ProfileViewModel.swift
//  sbud
//
//  Created by Erdal on 23.03.2026.
//

import Foundation
import FirebaseAuth
import Combine
import PhoneNumberKit
import _PhotosUI_SwiftUI


@MainActor
final class ProfileSetupVM: ObservableObject {

    @Published var profile: UserProfile
    @Published var isSaving: Bool = false
    @Published var currentStep: Int = 0
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    @Published var phoneNumber: String = ""
    @Published var profileImageData: Data?
    @Published var selectedItem: PhotosPickerItem?
    @Published var selectedProfileImage: UIImage?
 
    @Published var isUploadingPhoto: Bool = false
    var uploadedProfileImageUrl: String?

    private let profileManager: ProfileManager
    private let locationManager: LocationManager
    private let phoneUtil = PhoneNumberUtility()
    

    init(
        profileManager: ProfileManager = .shared,
        locationManager: LocationManager = .shared
    ) {
        self.profileManager = profileManager
        self.locationManager = locationManager

        let uid = Auth.auth().currentUser?.uid ?? ""
        self.profile = UserProfile(id: uid)
    }

    func clearError() {
        errorMessage = nil
    }

    private func trimmed(_ value: String) -> String {
        value.trimmingCharacters(in: .whitespacesAndNewlines)
    }

    // MARK: - OnBoarding
    
    func goNext() {
        currentStep += 1
    }

    func goBack() {
        currentStep = max(0, currentStep - 1)
    }

    func validateCurrentStep() -> Bool {
        switch currentStep {
        case 0:
            return validateStepOne()
        case 1:
            return validateStepTwo()
        case 2:
            return validateStepThree()
        default:
            return true
        }
    }

    // MARK: - Step Validations

    func validateStepOne() -> Bool {
        guard profile.profileImageUrl != nil else {
            errorMessage = "Profile image is required."
            return false
        }
        
        if trimmed(profile.name).isEmpty {
            errorMessage = "First name is required."
            return false
        }

        if trimmed(profile.surName).isEmpty {
            errorMessage = "Last name is required."
            return false
        }

        errorMessage = nil
        return true
    }

    func validateStepTwo() -> Bool {
        
        if !validatePhone() {
            return false
        }

        if trimmed(profile.gender ?? "").isEmpty {
            errorMessage = "Please select your gender."
            return false
        }
        
        guard profile.birthDate != nil else {
            errorMessage = "Please select your birth date."
            return false
        }
        
        if let age = profile.age {
            if age < 18 {
                errorMessage = "Under 18 years old not allowed."
                return false
            }
        }
    
        errorMessage = nil
        return true
    }

    func validateStepThree() -> Bool {
        if trimmed(profile.bio).isEmpty {
            errorMessage = "Bio is required."
            return false
        }

        errorMessage = nil
        return true
    }

    func validateLocationStep() -> Bool {
        if profile.location.latitude == 0 || profile.location.longitude == 0 {
            errorMessage = "Location could not be determined."
            return false
        }

        errorMessage = nil
        return true
    }

    // MARK: - Phone Number Configurationsn

    func validatePhone() -> Bool {
        let trimmedPhone = trimmed(phoneNumber)

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

        profile.email = user.email ?? ""
        
        guard let normalized = normalizedPhoneNumber() else {
            return false
        }
        profile.phoneNumber = normalized

        return true
    }
    
    
    
    func save() async -> Bool {
        errorMessage = nil
        
        guard validateStepOne() else { return false }
        guard validateStepTwo() else { return false }
        guard validateStepThree() else { return false }
        guard validateLocationStep() else { return false }
        guard await prepareProfileForSave() else { return false }

        isSaving = true
        defer { isSaving = false }
        
//        guard await uploadProfileImageIfNeeded() else {
//                return false
//            }
        do {
            profile.isProfileCompleted = true
            try await profileManager.saveProfileToDatabase(profile: profile)
            profileManager.saveProfileToLocale(profile: profile)
            return true
        } catch {
            errorMessage = error.localizedDescription
            print("Database save error:", error.localizedDescription)
            profile.isProfileCompleted = false
            return false
        }
    }
}
