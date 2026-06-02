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
    }
}
