//
//  User.swift
//  sbud
//
//  Created by Riccardo Maria Cadario on 23/02/26.
//
import FirebaseFirestore
import Firebase
import FirebaseAuth

struct User: Identifiable, Codable {
    @DocumentID var uid: String?
    var username: String
    let email: String?
    var phoneNumber: String?
    var profileImageUrl: String?
    var fullname: String?
    var bio: String?
    
    var isFollowed: Bool? = false
    
    var isCurrentUser: Bool { return Auth.auth().currentUser?.uid == id }
    var id: String { return uid ?? NSUUID().uuidString }
    
    
    init(uid: String?, username: String, email: String, profileImageUrl: String? = nil) {
        self.uid = uid
        self.username = username
        self.email = email
        self.profileImageUrl = profileImageUrl
    }
}

extension User: Hashable {
    var identifier: String { return id }
    
    public func hash(into hasher: inout Hasher) {
        return hasher.combine(identifier)
    }
    
    static func == (lhs: User, rhs: User) -> Bool {
        return lhs.id == rhs.id
    }
}
