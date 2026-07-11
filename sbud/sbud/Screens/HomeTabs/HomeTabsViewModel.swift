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
    @Published var totalNotificationsCount = 0

    private let friendManager: FriendManager

    private var unreadMessagesCount = 0
    private var eventJoinRequestsCount = 0
    private var pendingFriendsRequestCount = 0
    private var pendingHostsRequestCount = 0

    private var userDocListener: ListenerRegistration?
    private var friendsRequestsListener: RealtimeListenerHandle?
    private var hostsRequestsListener: RealtimeListenerHandle?

    init(friendManager: FriendManager = .shared) {
        self.friendManager = friendManager
        Analytics.logEvent(AnalyticsEventScreenView, parameters: [AnalyticsParameterScreenName: "Home"])
        if ProcessInfo.processInfo.environment["UI_TESTING_EVENT_ID"] != nil {
            selectedTab = 1
        }
    }

    deinit {
        userDocListener?.remove()
        friendsRequestsListener?.remove()
        hostsRequestsListener?.remove()
    }

    func listenForUnreadMessages() {
        guard let uid = Auth.auth().currentUser?.uid else { return }

        if userDocListener == nil {
            userDocListener = Firestore.firestore().collection("users").document(uid)
                .addSnapshotListener { [weak self] snapshot, error in
                    guard let self else { return }
                    if let error {
                        print("❌ Error listening to notification counts: \(error.localizedDescription)")
                        return
                    }
                    let data = snapshot?.data() ?? [:]

                    self.unreadMessagesCount     = max(0, data["unreadMessagesCount"] as? Int ?? 0)
                    self.eventJoinRequestsCount  = max(0, data["pendingRequestsCount"] as? Int ?? 0)
                    DispatchQueue.main.async { self.recomputeTotal() }
                }
        }

        if friendsRequestsListener == nil {
            friendsRequestsListener = friendManager.listenPendingFriendsRequestsCount(userId: uid) { [weak self] count in
                guard let self else { return }
                self.pendingFriendsRequestCount = count
                DispatchQueue.main.async { self.recomputeTotal() }
            }
        }

        if hostsRequestsListener == nil {
            hostsRequestsListener = friendManager.listenPendingHostsRequestsCount(userId: uid) { [weak self] count in
                guard let self else { return }
                self.pendingHostsRequestCount = count
                DispatchQueue.main.async { self.recomputeTotal() }
            }
        }
    }

    private func recomputeTotal() {
        totalNotificationsCount = max(0,
            unreadMessagesCount
            + eventJoinRequestsCount
            + pendingFriendsRequestCount
            + pendingHostsRequestCount
        )
    }
}
