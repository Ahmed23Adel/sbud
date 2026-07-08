//
//  HomeTabsViewModel.swift
//  sbud
//
//  Created by ahmed on 21/12/2025.
//

import Foundation
import Combine
import FirebaseAnalytics
import FirebaseFirestore
import FirebaseAuth

class HomeTabsViewModel: ObservableObject {
    @Published var selectedTab = 0

    init() {
        Analytics.logEvent(AnalyticsEventScreenView, parameters: [AnalyticsParameterScreenName: "Home"])
        // When a UI test needs to deep-link into the event detail screen,
        // start on the Availability tab (1) so AvailabilityAppCoordinator.onAppear fires.
        if ProcessInfo.processInfo.environment["UI_TESTING_EVENT_ID"] != nil {
            selectedTab = 1
        }
    }

    @Published var totalNotificationsCount = 0
    
    private var unreadMessages = 0
    private var pendingRequests = 0
    
    private var messagesListener: ListenerRegistration?
    private var eventsListener: ListenerRegistration?
    private var participantsListeners: [String: ListenerRegistration] = [:]
    
    private var pendingCountsByEvent: [String: Int] = [:]
    
    deinit {
        messagesListener?.remove()
        eventsListener?.remove()
        participantsListeners.values.forEach { $0.remove() }
    }
    
    private func updateTotal() {
        DispatchQueue.main.async {
            self.totalNotificationsCount = self.unreadMessages + self.pendingRequests
            print("🔔 BADGE TABS AGGIORNATO: Totale = \(self.totalNotificationsCount) (Messaggi: \(self.unreadMessages), Richieste: \(self.pendingRequests))")
        }
    }
    
    func listenForUnreadMessages() {
        guard messagesListener == nil && eventsListener == nil else { return }
        guard let uid = Auth.auth().currentUser?.uid else { return }
        
        let db = Firestore.firestore()
        
        // --- 1. ASCOLTATORE MESSAGGI (messages minuscolo è corretto nelle tue rules) ---
        messagesListener = db.collection("messages").document(uid).collection("recent-messages")
            .addSnapshotListener { [weak self] snapshot, error in
                if let err = error {
                    print("❌ ERRORE Firebase Messaggi: \(err.localizedDescription)")
                    return
                }
                
                let messages = snapshot?.documents.compactMap { try? $0.data(as: Message.self) } ?? []
                self?.unreadMessages = messages.filter { $0.isRead == false }.count
                self?.updateTotal()
            }
        
        // --- 2. ASCOLTATORE EVENTI E RICHIESTE ---
        // ATTENZIONE: "Events" con la E MAIUSCOLA come nel tuo database e nelle tue Rules!
        eventsListener = db.collection("Events").whereField("creatorId", isEqualTo: uid)
            .addSnapshotListener { [weak self] snapshot, error in
                guard let self = self else { return }
                
                if let err = error {
                    print("❌ ERRORE Firebase Events: \(err.localizedDescription)")
                    return
                }
                
                guard let docs = snapshot?.documents else { return }
                let currentEventIds = Set(docs.map { $0.documentID })
                
                print("✅ TROVATI \(currentEventIds.count) EVENTI CREATI DA TE")
                
                // Rimuovi listener vecchi
                for (eventId, listener) in self.participantsListeners {
                    if !currentEventIds.contains(eventId) {
                        listener.remove()
                        self.participantsListeners.removeValue(forKey: eventId)
                        self.pendingCountsByEvent.removeValue(forKey: eventId)
                    }
                }
                
                // Crea nuovi listener per i tuoi eventi
                for eventId in currentEventIds {
                    if self.participantsListeners[eventId] == nil {
                        
                        // "Events" maiuscolo, "participants" minuscolo
                        let reqQuery = db.collection("Events").document(eventId).collection("participants").whereField("status", isEqualTo: "pending")
                        
                        let listener = reqQuery.addSnapshotListener { [weak self] reqSnap, reqErr in
                            if let reqErr = reqErr {
                                print("❌ ERRORE Partecipanti Evento \(eventId): \(reqErr.localizedDescription)")
                                return
                            }
                            
                            let count = reqSnap?.documents.count ?? 0
                            print("✅ TROVATE \(count) RICHIESTE per l'evento: \(eventId)")
                            
                            self?.pendingCountsByEvent[eventId] = count
                            self?.pendingRequests = self?.pendingCountsByEvent.values.reduce(0, +) ?? 0
                            self?.updateTotal()
                        }
                        self.participantsListeners[eventId] = listener
                    }
                }
            }
    }
}
