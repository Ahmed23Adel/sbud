//
//  ViewmODEOthersEvents.swift
//  sbud
//
//  Created by ahmed on 21/05/2026.
//

import Foundation
import FirebaseAnalytics

@Observable
class ViewModelOthersEvents{
    init() {
        Analytics.logEvent(AnalyticsEventScreenView, parameters: [AnalyticsParameterScreenName: "OthersEvents"])
    }
}
