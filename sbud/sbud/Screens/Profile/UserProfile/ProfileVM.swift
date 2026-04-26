//
//  ProfileVM.swift
//  sbud
//
//  Created by Erdal on 25.04.2026.
//

import Foundation
import FirebaseAuth
import Combine


import Foundation
import FirebaseAuth

@MainActor
final class ProfileVM: ObservableObject {
    @Published var profile: UserProfile?
    @Published var isLoading = false
    @Published var isFollowing = false
    @Published var errorMessage: String?

    private let profileManager = ProfileManager.shared
    let userId: String

    var isOwnProfile: Bool {
        userId == Auth.auth().currentUser?.uid
    }

    init(userId: String) {
        self.userId = userId
    }

    func load() async {
        isLoading = true
        defer { isLoading = false }
        do {
            profile = try await profileManager.getProfile(userId: userId)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func toggleFollow() async {
        isFollowing.toggle()
    }

    var displayName: String {
        guard let p = profile else { return "" }
        let last = p.surName.first.map { "\($0)." } ?? ""
        return "\(p.name.uppercased())_\(last.uppercased())"
    }
}
