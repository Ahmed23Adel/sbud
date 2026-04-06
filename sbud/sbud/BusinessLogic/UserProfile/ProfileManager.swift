//
//  ProfileManager.swift
//  sbud
//
//  Created by Erdal on 5.01.2026.
//
import Foundation
import FirebaseAuth
import FirebaseStorage

class ProfileManager: IProfileServiceManager {
    
    static let shared = ProfileManager()
    
    private let localStorage = LocalUserStorage()
    private let authManager = AuthenticationManager.shared
    private let userRepository = UserRepository()
    
    private init() {}

    var isProfileSetupComplete: Bool {
        guard let profile = localStorage.load() else { return false }
        return profile.isProfileCompleted
    }
    
    func getLocalProfile() -> UserProfile? {
        localStorage.load()
    }
    
    func syncProfileAfterLogin() async throws {
        guard let uid = Auth.auth().currentUser?.uid else {
            throw NSError(
                domain: "Auth",
                code: 401,
                userInfo: [NSLocalizedDescriptionKey: "Authenticated user not found."]
            )
        }
        let token = try await Auth.auth().currentUser?.getIDToken()
        print("TOKEN:", token ?? "")
        
        if let remoteProfile = try await userRepository.fetchProfile(uid) {
            localStorage.save(remoteProfile)
        } else {
            let newProfile = UserProfile(id: uid)
            localStorage.save(newProfile)
        }
    }
    
    func saveProfileToDatabase(profile: UserProfile) async throws {
        if let errorMessage = try await userRepository.save(profile) {
            throw NSError(
                domain: "UserRepositoryError",
                code: 500,
                userInfo: [NSLocalizedDescriptionKey: errorMessage]
            )
        }
    }

    func updateProfileStep(uid: String, fields: [String: Any], localProfile: UserProfile) async throws {
        try await userRepository.updateUserProfileFields(uid: uid, fields: fields)
        print(localProfile)
        localStorage.save(localProfile)
    }

    func saveProfileToLocale(profile: UserProfile) {    localStorage.save(profile)  }
    func deleteProfileFromLocale() { localStorage.clear() }
    func deleteProfileFromDatabase(uid: String) async throws {
    }
    
    func uploadProfileImage(data: Data) async throws -> String {
        guard let currentUser = Auth.auth().currentUser else {
            throw URLError(.userAuthenticationRequired)
        }

        let token = try await currentUser.getIDToken()

        guard let url = URL(string: "https://sbud-backend.onrender.com/api/v1/images/upload") else {
            throw URLError(.badURL)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        let boundary = UUID().uuidString
        request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")

        var body = Data()
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"file\"; filename=\"photo.jpg\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: image/jpeg\r\n\r\n".data(using: .utf8)!)
        body.append(data)
        body.append("\r\n--\(boundary)--\r\n".data(using: .utf8)!)
        request.httpBody = body

        print("UPLOAD START")
        print("UPLOAD URL:", url.absoluteString)
        print("IMAGE SIZE:", data.count)
        print("BODY SIZE:", body.count)

        let (responseData, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw URLError(.badServerResponse)
        }

        let responseText = String(data: responseData, encoding: .utf8) ?? "nil"
        print("UPLOAD STATUS:", httpResponse.statusCode)
        print("UPLOAD RESPONSE:", responseText)

        guard (200...299).contains(httpResponse.statusCode) else {
            throw NSError(
                domain: "ProfileImageUpload",
                code: httpResponse.statusCode,
                userInfo: [NSLocalizedDescriptionKey: responseText]
            )
        }

        return try JSONDecoder().decode(ImageUploadResponse.self, from: responseData).url
    }
}




