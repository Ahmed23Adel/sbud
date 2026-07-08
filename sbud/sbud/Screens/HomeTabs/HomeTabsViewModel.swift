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

    private var userListener: ListenerRegistration?

    deinit {
        userListener?.remove()
    }

    func listenForUnreadMessages() {
        guard userListener == nil else { return }
        guard let uid = Auth.auth().currentUser?.uid else { return }

        userListener = Firestore.firestore().collection("users").document(uid)
            .addSnapshotListener { [weak self] snapshot, error in
                if let error = error {
                    print("❌ Error listening to notification counts: \(error.localizedDescription)")
                    return
                }
                let data = snapshot?.data() ?? [:]
                let unreadMessages = data["unreadMessagesCount"] as? Int ?? 0
                let pendingRequests = data["pendingRequestsCount"] as? Int ?? 0
                DispatchQueue.main.async {
                    self?.totalNotificationsCount = unreadMessages + pendingRequests
                }
            }
    }
}
