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

        // ── Location + metrics activities ─────────────────────────────────
        case .running:
            if let c = metricCollector as? MetricsCollectorRun {
                RunSummaryWrapper(collector: c)
            }
        case .cycling:
            if let c = metricCollector as? MetricsCollectorCycling {
                CyclingSummaryWrapper(collector: c)
            }
        case .skiing:
            if let c = metricCollector as? MetricsCollectorSkiing {
                SkiingSummaryWrapper(collector: c)
            }
        case .hiking:
            if let c = metricCollector as? MetricsCollectorHiking {
                HikingSummaryWrapper(collector: c)
            }

        // ── Timer-only activities ─────────────────────────────────────────
        case .gym:
            if let c = metricCollector as? MetricsCollectorGym {
                GymWrapper(collector: c)
            }
        case .yoga:
            if let c = metricCollector as? MetricsCollectorYoga {
                YogaWrapper(collector: c)
            }
        case .tennis:
            if let c = metricCollector as? MetricsCollectorTennis {
                TennisWrapper(collector: c)
            }
        case .swimming:  // add this if swimming should show a timer
            if let c = metricCollector as? MetricsCollectorSwimming {
                SwimmingWrapper(collector: c)
            }
        default:
            EmptyView()
        }
    }
}

// MARK: - Private wrappers
// @State wrappers are required so SwiftUI observes @Observable collectors.

private struct RunSummaryWrapper: View {
    @State var collector: MetricsCollectorRun
    var body: some View { ViewMetricsSummaryRun(collector: collector) }
}

private struct CyclingSummaryWrapper: View {
    @State var collector: MetricsCollectorCycling
    var body: some View { ViewMetricsSummaryCycling(collector: collector) }
}

private struct SkiingSummaryWrapper: View {
    @State var collector: MetricsCollectorSkiing
    var body: some View { ViewMetricsSummarySkiing(collector: collector) }
}

private struct HikingSummaryWrapper: View {
    @State var collector: MetricsCollectorHiking
    var body: some View { ViewMetricsSummaryHiking(collector: collector) }
}

private struct SimpleWrapper: View {
    let activityType: ActivityType
    let collector: (any MetricsCollectorTimeable)
    var body: some View {
        ViewMetricsSummarySimple(collector: collector, activityType: activityType)
    }
}
private struct GymWrapper: View {
    @State var collector: MetricsCollectorGym
    var body: some View { ViewMetricsSummarySimple(collector: collector, activityType: .gym) }
}

private struct YogaWrapper: View {
    @State var collector: MetricsCollectorYoga
    var body: some View { ViewMetricsSummarySimple(collector: collector, activityType: .yoga) }
}

private struct TennisWrapper: View {
    @State var collector: MetricsCollectorTennis
    var body: some View { ViewMetricsSummarySimple(collector: collector, activityType: .tennis) }
}

private struct SwimmingWrapper: View {
    @State var collector: MetricsCollectorSwimming
    var body: some View { ViewMetricsSummarySimple(collector: collector, activityType: .swimming) }
}
