//
//  PerformanceTargetDetailedRunning.swift
//  sbud
//
//  Created by ahmed on 25/04/2026.
//

import SwiftUI

struct PerformanceTargetDetailedConditional: View {
    var activityDetails: ExtraArgsHolder
    var body: some View {
        HStack {
            switch activityDetails.selectedActivity {
            case .running:
                PerformanceTargetDetailedRunning(t: activityDetails.extraArgs as! ExtraArgsHolderRunning)
            case .cycling:
                PerformanceTargetDetailedCycling(t: activityDetails.extraArgs as! ExtraArgsHolderCycling)
            case .gym:
                PerformanceTargetDetailedGym(t: activityDetails.extraArgs as! ExtraArgsHolderGym)
            case .skiing:
                PerformanceTargetDetailedSkiing(t: activityDetails.extraArgs as! ExtraArgsHolderSkiing)
            case .swimming:
                PerformanceTargetDetailedSwimming(t: activityDetails.extraArgs as! ExtraArgsHolderSwimming)
            case .hiking:
                PerformanceTargetDetailedHiking(t: activityDetails.extraArgs as! ExtraArgsHolderHiking)
            case .yoga:
                PerformanceTargetDetailedYoga(t: activityDetails.extraArgs as! ExtraArgsHolderYoga)
            case .tennis:
                PerformanceTargetDetailedTennis(t: activityDetails.extraArgs as! ExtraArgsHolderTennis)
            }
        }
    }
}
#Preview {
    PerformanceTargetDetailedConditional(activityDetails: ExtraArgsHolder())
}
