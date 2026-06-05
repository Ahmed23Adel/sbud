//
//  HomeTabsViewModel.swift
//  sbud
//
//  Created by ahmed on 21/12/2025.
//

import Foundation
import Combine
import FirebaseAnalytics

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
}
