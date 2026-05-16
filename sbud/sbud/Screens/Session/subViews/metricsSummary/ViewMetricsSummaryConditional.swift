//
//  ViewMetricsSummaryConditional.swift
//  sbud
//
//  Created by ahmed on 16/05/2026.
//

import SwiftUI

struct ViewMetricsSummaryConditional: View {
    var metricCollector: MetricsCollector?
    let activityType: ActivityType

    var body: some View {
        switch activityType {
        case .running:
            if let runCollector = metricCollector as? MetricsCollectorRun {
                RunSummaryWrapper(runCollector: runCollector)
            }
        default:
            EmptyView()
        }
    }
}

private struct RunSummaryWrapper: View {
    @State var runCollector: MetricsCollectorRun

    var body: some View {
        ViewMetricsSummaryRun(collector: runCollector) 
    }
}
