//
//  EventContactsViewModel.swift
//  sbud
//
//  Created by Riccardo Maria Cadario on 27/04/26.
//
import Combine
import FirebaseAuth
import FirebaseFirestore

@MainActor
class EventContactsViewModel: ObservableObject {
    @Published var contactedUsers: [UserProfile] = []
    @Published var isLoadingContacts = false
    let eventId: String

    init(eventId: String) {
        self.eventId = eventId
        fetchContactsForEvent()
    }

    func fetchContactsForEvent() {
        guard let currentUid = Auth.auth().currentUser?.uid else { return }
        isLoadingContacts = true
        
        // Il listener aggiorna in tempo reale se ti scrivono mentre guardi la pagina
        Firestore.firestore().collection("messages").document(currentUid).collection("recent-messages")
            .whereField("eventId", isEqualTo: eventId)
            .addSnapshotListener { snapshot, error in
                guard let docs = snapshot?.documents else {
                    Task { @MainActor in self.isLoadingContacts = false }
                    return
                }
                
                let messages = docs.compactMap { try? $0.data(as: Message.self) }
                
                // Usiamo un Task per chiamare la funzione asincrona in modo sicuro
                Task {
                    await self.fetchUserProfiles(from: messages)
                }
            }
    }
    
    private func fetchUserProfiles(from messages: [Message]) async {
        var profiles: [UserProfile] = []
        let db = Firestore.firestore()
        
        for message in messages {
            let partnerId = message.chatPartnerId
            do {
                // Fetch asincrono pulito e sicuro per Swift 6
                let doc = try await db.collection("users").document(partnerId).getDocument()
                if let profile = try? doc.data(as: UserProfile.self) {
                    profiles.append(profile)
                } else {
                    profiles.append(UserProfile(id: partnerId))
                }
            } catch {
                profiles.append(UserProfile(id: partnerId))
            }
        }
        
        self.contactedUsers = profiles
        self.isLoadingContacts = false
    }
}
