//
//  ExtraArgsFilterHolders.swift
//  sbud
//
//  Created by ahmed on 04/05/2026.
//

import Foundation
import Combine

class ExtraArgsFilterHolderRunning: ObservableObject {
    @Published var minDistance:   Double? = nil
    @Published var maxDistance:   Double? = nil
    @Published var minPace:       Double? = nil
    @Published var maxPace:       Double? = nil
    @Published var runningType:   RunningType? = nil
}

class ExtraArgsFilterHolderCycling: ObservableObject {
    @Published var minPower:   Double? = nil
    @Published var maxPower:   Double? = nil
    @Published var minCadence: Double? = nil
    @Published var maxCadence: Double? = nil
    @Published var cyclingType: CyclingType? = nil
}

class ExtraArgsFilterHolderGym: ObservableObject {
    @Published var gymDayType: GymDayType? = nil
}

class ExtraArgsFilterHolderSkiing: ObservableObject {
    @Published var minSpeed:   Double? = nil
    @Published var maxSpeed:   Double? = nil
    @Published var minDrop:    Double? = nil
    @Published var maxDrop:    Double? = nil
}

class ExtraArgsFilterHolderSwimming: ObservableObject {
    @Published var minDistance: Double? = nil
    @Published var maxDistance: Double? = nil
    @Published var minPace:     Double? = nil
    @Published var maxPace:     Double? = nil
    @Published var stroke:      SwimmingStroke? = nil
}

class ExtraArgsFilterHolderHiking: ObservableObject {
    @Published var minDistance:  Double? = nil
    @Published var maxDistance:  Double? = nil
    @Published var minElevation: Double? = nil
    @Published var maxElevation: Double? = nil
}

class ExtraArgsFilterHolderYoga: ObservableObject {
    @Published var minDuration:  Double? = nil
    @Published var maxDuration:  Double? = nil
    @Published var minIntensity: Double? = nil
    @Published var maxIntensity: Double? = nil
    @Published var style:        YogaStyle? = nil
}

class ExtraArgsFilterHolderTennis: ObservableObject {
    @Published var minSets:     Double? = nil
    @Published var maxSets:     Double? = nil
    @Published var minDuration: Double? = nil
    @Published var maxDuration: Double? = nil
    @Published var format:      TennisFormat? = nil
}
