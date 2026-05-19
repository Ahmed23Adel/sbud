//
//  ExtraArgsFilterHolders.swift
//  sbud
//
//  Created by ahmed on 04/05/2026.
//

import Foundation
import Combine

class ExtraArgsFilterHolderRunning: ObservableObject {
    @Published var minDistanceInKm: Double? = nil
    @Published var maxDistanceInKm: Double? = nil
    @Published var minPace:         Double? = nil
    @Published var maxPace:         Double? = nil
    @Published var minDurationInMin: Double? = nil
    @Published var maxDurationInMin: Double? = nil
    @Published var runningType:     RunningType? = nil
}

class ExtraArgsFilterHolderCycling: ObservableObject {
    @Published var minDistanceInKm:  Double? = nil
    @Published var maxDistanceInKm:  Double? = nil
    @Published var minSpeedInKmH:    Double? = nil
    @Published var maxSpeedInKmH:    Double? = nil
    @Published var minDurationInMin: Double? = nil
    @Published var maxDurationInMin: Double? = nil
    @Published var cyclingType:      CyclingType? = nil
}

class ExtraArgsFilterHolderGym: ObservableObject {
    @Published var minDurationInMin: Double? = nil
    @Published var maxDurationInMin: Double? = nil
    @Published var gymDayType:       GymDayType? = nil
}

class ExtraArgsFilterHolderSkiing: ObservableObject {
    @Published var minAvgSpeedInKmH:      Double? = nil
    @Published var maxAvgSpeedInKmH:      Double? = nil
    @Published var minAvgVerticalDropInM: Double? = nil
    @Published var maxAvgVerticalDropInM: Double? = nil
    @Published var minNumberOfRuns:       Int?    = nil
    @Published var maxNumberOfRuns:       Int?    = nil
    @Published var minDurationInMin:      Double? = nil
    @Published var maxDurationInMin:      Double? = nil
}

class ExtraArgsFilterHolderSwimming: ObservableObject {
    @Published var minDistanceInM:   Double? = nil
    @Published var maxDistanceInM:   Double? = nil
    @Published var minPace:          Double? = nil
    @Published var maxPace:          Double? = nil
    @Published var minDurationInMin: Double? = nil
    @Published var maxDurationInMin: Double? = nil
    @Published var stroke:           SwimmingStroke? = nil
}

class ExtraArgsFilterHolderHiking: ObservableObject {
    @Published var minDistanceInKm:      Double? = nil
    @Published var maxDistanceInKm:      Double? = nil
    @Published var minElevationGainInM:  Double? = nil
    @Published var maxElevationGainInM:  Double? = nil
    @Published var minElevationLossInM:  Double? = nil
    @Published var maxElevationLossInM:  Double? = nil
    @Published var minAltitudeInM:       Double? = nil
    @Published var maxAltitudeInM:       Double? = nil
    @Published var minDurationInMin:     Double? = nil
    @Published var maxDurationInMin:     Double? = nil
}

class ExtraArgsFilterHolderYoga: ObservableObject {
    @Published var minDurationInMin:  Double? = nil
    @Published var maxDurationInMin:  Double? = nil
    @Published var minIntensity:      Double? = nil
    @Published var maxIntensity:      Double? = nil
    @Published var style:             YogaStyle? = nil
}

class ExtraArgsFilterHolderTennis: ObservableObject {
    @Published var minSets:          Double? = nil
    @Published var maxSets:          Double? = nil
    @Published var minDurationInMin: Double? = nil
    @Published var maxDurationInMin: Double? = nil
    @Published var format:           TennisFormat? = nil
}
