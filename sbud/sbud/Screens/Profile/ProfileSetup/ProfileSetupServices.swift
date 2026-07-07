//
//  ProfileSetupServices.swift
//  sbud
//
//  Created by ahmed on 14/05/2026.
//

import Foundation
import UIKit
import _PhotosUI_SwiftUI
import PhoneNumberKit
import CoreLocation
import FirebaseAuth
import Combine
// MARK: - Photo Service

/// Loads, compresses and uploads a profile photo.
/// Owns no UI state — callers observe the published properties they need.
@MainActor
final class PhotoService: ObservableObject {

    @Published var selectedItem: PhotosPickerItem?
    @Published var selectedImage: UIImage?
    @Published var isUploading = false
    @Published var uploadedURL: String?
    @Published var error: String?

    private let profileManager: ProfileManager

    init(profileManager: ProfileManager = .shared) {
        self.profileManager = profileManager
    }

    func handleSelection() async {
        guard let item = selectedItem else { return }
        isUploading = true
        error = nil
        defer { isUploading = false }

        do {
            guard let data = try await item.loadTransferable(type: Data.self) else {
                error = "Selected image could not be loaded."
                return
            }
            // Önizlemeyi hemen göster — compress/upload beklemeden
            selectedImage = UIImage(data: data)

            // Resize + compress background thread'de — MainActor'ı bloklamaz
            let compressed: Data? = await Task.detached(priority: .userInitiated) {
                guard let image = UIImage(data: data) else { return nil }
                let resized = image.resizedToFit(maxDimension: 400)
                return resized.jpegData(compressionQuality: 0.5)
            }.value
            guard let compressed else {
                error = "Image compression failed."
                return
            }
            let url = try await profileManager.uploadProfileImage(data: compressed)
            uploadedURL = url
        } catch {
            self.error = "Photo upload failed: \(error.localizedDescription)"
        }
    }
}

// MARK: - Location Service (wrapper around shared LocationManager)

/// Fetches the device's current coordinate + reverse-geocoded address.
@MainActor
final class LocationService: ObservableObject {

    @Published var latitude: Double = 0
    @Published var longitude: Double = 0
    @Published var city: String = ""
    @Published var country: String = ""
    @Published var fullAddress: String = ""
    @Published var isLoading = false
    @Published var error: String?

    private let locationManager: LocationManager

    init(locationManager: LocationManager = .shared) {
        self.locationManager = locationManager
    }

    var isAcquired: Bool { latitude != 0 }

    func load() async {
        isLoading = true
        error = nil
        locationManager.requestPermission()
        locationManager.startUpdating()

        // Give CoreLocation a moment to deliver the first fix.
        try? await Task.sleep(nanoseconds: 1_000_000_000)

        guard let coordinate = locationManager.userLocation else {
            error = "Location could not be retrieved."
            isLoading = false
            return
        }

        latitude  = coordinate.latitude
        longitude = coordinate.longitude
        isLoading = false

        await reverseGeocode(coordinate: coordinate)
    }

    private func reverseGeocode(coordinate: CLLocationCoordinate2D) async {
        let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
        let placemarks = try? await CLGeocoder().reverseGeocodeLocation(location)
        guard let p = placemarks?.first else { return }

        city    = p.locality ?? ""
        country = p.country  ?? ""
        fullAddress = [p.name, p.locality, p.administrativeArea, p.country]
            .compactMap { $0 }
            .filter { !$0.isEmpty }
            .joined(separator: ", ")
    }
}

// MARK: - Phone Service

/// Validates and normalises a phone number string using PhoneNumberKit.
struct PhoneService {

    private static let kit = PhoneNumberUtility()

    static func validate(_ raw: String) -> Bool {
        (try? kit.parse(raw.trimmingCharacters(in: .whitespacesAndNewlines))) != nil
    }

    static func e164(_ raw: String) -> String? {
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        guard let parsed = try? kit.parse(trimmed) else { return nil }
        return kit.format(parsed, toType: .e164)
    }
}
