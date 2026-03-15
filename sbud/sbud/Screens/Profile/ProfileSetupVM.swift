//
//  ProfileSetupVM.swift
//  sbud
//
//  Created by Erdal on 23/12/2025.
//

import Foundation
import FirebaseAuth
import FirebaseFirestore
import Combine
import CoreLocation
import UIKit


@MainActor
final class ProfileSetupVM: ObservableObject {

    
    @Published var profile: UserProfile
    private let profileManager: ProfileManager
    private let locationManager: LocationManager
    @Published var isSaving = false
    @Published var currentStep: Int = 0
    @Published var isLoading = false
    @Published var errorMessage: String?


        let genderOptions = ["Male", "Female", "Other", "Prefer not to say"]
 
    init(
        profileManager: ProfileManager = .shared,
        locationManager: LocationManager = .shared) {
            self.profileManager = profileManager
            self.locationManager = locationManager
        
            let uid = Auth.auth().currentUser?.uid ?? ""
            self.profile = UserProfile(id: uid)
            self.currentStep = self.profile.onboardingStep
        }

        func requestCurrentLocation() {
            locationManager.requestPermission()
            locationManager.startUpdating()
        }

        func fillLocationFromDevice() {
            guard let coordinate = locationManager.userLocation else {
                errorMessage = "Location couldnot get."
                return
            }
            profile.location.latitude = coordinate.latitude
            profile.location.longitude = coordinate.longitude
        }
    
    /*func uploadProfilePhoto(_ imageData: Data) async throws -> String {
        let uid = profile.id
        let ref = Storage.storage().reference().child("profile_photos/\(uid).jpg")

        let metadata = StorageMetadata()
        metadata.contentType = "image/jpeg"

        _ = try await ref.putDataAsync(imageData, metadata: metadata)
        let downloadURL = try await ref.downloadURL()

        return downloadURL.absoluteString
    }
    */
            

        func save() async -> Bool {
            isSaving = true
            errorMessage = nil

            do {
                try await profileManager.saveProfileToDatabase(profile: self.profile)
                profileManager.saveProfileToLocale(profile: self.profile)
                isSaving = false
                print("Profile submitted.")
                return true
            } catch {
                isSaving = false
                errorMessage = error.localizedDescription
                print("Hata: \(error.localizedDescription)")
                return false
            }
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
                ].compactMap { $0 }
                
                self.profile.location.fullAddress = parts.joined(separator: ", ")
            }
        }
    }
  
    func goNext() {
        currentStep += 1
    }
    
    func goBack() {
        currentStep = max(0, currentStep - 1)
    }
    
    func saveStep1() async -> Bool {
        let tempName = profile.name.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !tempName.isEmpty else {
            errorMessage = "Full name is required."
            return false
        }

        let tempsurName = profile.surName.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !tempsurName.isEmpty else {
            errorMessage = "Surname is required."
            return false
        }

        profile.name = tempName
        profile.surName = tempsurName
        profile.onboardingStep = 2
        profile.isProfileCompleted = false
        profile.email = Auth.auth().currentUser?.email ?? ""

        return await persist(fields: [
            "name": profile.name,
            "surName": profile.surName,
            "email": profile.email,
            "onboardingStep": profile.onboardingStep,
            "isProfileCompleted": profile.isProfileCompleted
        ])
    }
    
    func saveStep2() async -> Bool {
        profile.onboardingStep = 3
        profile.isProfileCompleted = false

        return await persist(fields: [
            "bio": profile.bio as Any,
            "age": profile.age,
            "birthDate": profile.birthDate,
            "gender": profile.gender as Any,
            "onboardingStep": profile.onboardingStep,
            "isProfileCompleted": profile.isProfileCompleted
        ])
    }
    
    func saveStep3() async -> Bool {
        profile.onboardingStep = 4
        profile.isProfileCompleted = true
        profile.createdAt = Date()

        return await persist(fields: [
            "country": profile.country,
            "city": profile.city,
            "location": [
                "latitude": profile.location.latitude,
                "longitude": profile.location.longitude,
                "fullAddress": profile.location.fullAddress as Any
            ],
            "onboardingStep": profile.onboardingStep,
            "isProfileCompleted": profile.isProfileCompleted,
            "createdAt": profile.createdAt
        ])
    }

    
    func loadFromLocalIfNeeded() {
            if let local = profileManager.getLocalProfile() {
                profile = local
                currentStep = local.onboardingStep
            }
        }
    
    private func persist(fields: [String: Any]) async -> Bool {
        guard !profile.id.isEmpty else {
            errorMessage = "User id could not be found."
            return false
        }
        
        isLoading = true
        errorMessage = nil
        
        do {
            try await profileManager.updateProfileStep(
                uid: profile.id,
                fields: fields,
                localProfile: profile
            )
            isLoading = false
            return true
        } catch {
            isLoading = false
            errorMessage = error.localizedDescription
            return false
        }
    }
}
