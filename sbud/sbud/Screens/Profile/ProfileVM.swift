//
//  ProfileVM.swift
//  sbud
//
//  Created by Erdal on 23/12/2025.
//
import Foundation
import Combine
/*
@MainActor
class ProfileVM: ObservableObject {
    @Published var profile: UserProfile?
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let repo = UserRepository()
    private let local = LocalUserStorage()

    func fetchProfileData() async {
        isLoading = true
        errorMessage = nil

        if let cachedProfile = local.load() {
            self.profile = cachedProfile
        }

        do {
            if let remoteProfile = try await repo.fetchProfile() {
                self.profile = remoteProfile
                local.save(remoteProfile)
            }
        } catch {
            if profile == nil {
                errorMessage = "Failed to load profile: \(error.localizedDescription)"
            }
        }
        
        isLoading = false
    }
}*/
