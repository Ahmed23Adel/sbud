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
        case .cycling:
            if let cyclingCollector = metricCollector as? MetricsCollectorCycling {
                CyclingSummaryWrapper(cyclingCollector: cyclingCollector)
            }
        case .gym:
            EmptyView()
        case .skiing:
            if let skiingCollector = metricCollector as? MetricsCollectorSkiing {
                SkiingSummaryWrapper(skiingCollector: skiingCollector)
            }
        case .hiking:
            if let hikingCollector = metricCollector as? MetricsCollectorHiking {
                HikingSummaryWrapper(hikingCollector: hikingCollector)
            }
        case .yoga:
            EmptyView()
        case .tennis:
            EmptyView()
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

private struct CyclingSummaryWrapper: View {
    @State var cyclingCollector: MetricsCollectorCycling

    var body: some View {
        ViewMetricsSummaryCycling(collector: cyclingCollector)
    }
}


private struct SkiingSummaryWrapper: View {
    @State var skiingCollector: MetricsCollectorSkiing
    var body: some View {
        ViewMetricsSummarySkiing(collector: skiingCollector)
    }
}

private struct HikingSummaryWrapper: View {
    @State var hikingCollector: MetricsCollectorHiking
    var body: some View {
        ViewMetricsSummaryHiking(collector: hikingCollector)
    }
}
