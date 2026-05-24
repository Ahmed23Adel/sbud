//
//  ViewSessionSummary.swift
//  sbud
//
//  Created by ahmed on 24/05/2026.
//

import SwiftUI

struct ViewSessionSummaryConditional: View {
    let event: EventFullDetails
    init(event: EventFullDetails){
        self.event = event
    }
    var body: some View {
        switch event.activityType {
        case .running:
            ViewSessionSummaryRunning(event: event)
//        case .cycling:
//            <#code#>
//        case .gym:
//            <#code#>
//        case .skiing:
//            <#code#>
//        case .swimming:
//            <#code#>
//        case .hiking:
//            <#code#>
//        case .yoga:
//            <#code#>
//        case .tennis:
//            <#code#>
        default:
            EmptyView()
        }
    }
}
//
//#Preview {
//    ViewSessionSummary()
//}
