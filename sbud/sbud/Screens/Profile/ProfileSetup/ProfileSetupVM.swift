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
    //phone verification
    @Published var isPhoneVerified: Bool = false
    @Published var verificationID: String? = nil
    @Published var otpCode: String = ""
    @Published var isSendingSMS: Bool = false
    @Published var isVerifyingOTP: Bool = false

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
        
        if requiresEmailVerification {
            errorMessage = "Verify your email address by clicking the link we sent you to continue."
            return false
        }
        
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
    
    //Validazione telefono:
    func sendSMS() async {
        guard let e164 = PhoneService.e164(phoneNumber) else {
            self.errorMessage = "Numero di telefono non valido."
            return
        }
        
        DispatchQueue.main.async { self.isSendingSMS = true }
        
        do {
            // Assicurati che Firebase sia configurato per l'Auth telefonica (APNs/reCAPTCHA)
            let id = try await PhoneAuthProvider.provider().verifyPhoneNumber(e164, uiDelegate: nil)
            DispatchQueue.main.async {
                self.verificationID = id
                self.isSendingSMS = false
                self.clearError()
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = error.localizedDescription
                self.isSendingSMS = false
            }
        }
    }

    // 2. Verifica il codice OTP
    func verifyOTP() async {
        guard let verificationID = verificationID, !otpCode.isEmpty else { return }
        
        DispatchQueue.main.async { self.isVerifyingOTP = true }
        
        let credential = PhoneAuthProvider.provider().credential(
            withVerificationID: verificationID,
            verificationCode: otpCode
        )
        
        do {
            // Collega il numero di telefono all'account utente esistente
            if let user = Auth.auth().currentUser {
                try await user.link(with: credential)
            }
            
            DispatchQueue.main.async {
                self.isPhoneVerified = true
                self.isVerifyingOTP = false
                self.clearError()
            }
        } catch {
            DispatchQueue.main.async {
                self.errorMessage = "Incorrect or expired code."
                self.isVerifyingOTP = false
            }
        }
    }

    func validateStepTwo() -> Bool {
        guard isPhoneVerified else {
            errorMessage = "Verify your phone number with the SMS code to continue."
            PopUpGenerator.shared.show(msg: "Verify phone number first", type: .warning)
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
        if requiresEmailVerification {
            errorMessage = "Please verify your email address before saving your profile."
            return false
        }

        guard isPhoneVerified else {
            errorMessage = "Verify your phone number before saving your profile."
            return false
        }

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
        photo.selectedItem = item          // hand off to the service
        await photo.handleSelection()
    }
}

extension ProfileSetupVM {
    
    // Controlla se l'utente ha fatto l'accesso con email e se l'email NON è ancora verificata
    private var requiresEmailVerification: Bool {
        
        let isEmailAuth = AuthenticationManager.shared.signInMethod == AuthType.email.rawValue
        
        // Firebase aggiorna quando chiami reload()
        let isVerified = Auth.auth().currentUser?.isEmailVerified ?? false
        
        return isEmailAuth && !isVerified
    }
}

// MARK: - String helper (private to this module)

private extension String {
    var trimmed: String { trimmingCharacters(in: .whitespacesAndNewlines) }
}
