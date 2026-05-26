//
//  AvailabilityFiltersResults.swift
//  sbud
//
//  Created by ahmed on 29/12/2025.
//

import Foundation
import Combine
import Foundation
import Combine

class AvailabilityFiltersResults: ObservableObject, Equatable {
    @Published var selectedActivityIndex = 0
    @Published var startDateTime = Date()
    @Published var endDateTime = Calendar.current.date(byAdding: .hour, value: 5, to: Date()) ?? Date()

    // nil = Any (no filter), shown via OptionalTextOptionSelector tap-to-deselect
    @Published var gender: GenderFilter? = nil

    let runningFilter   = ExtraArgsFilterHolderRunning()
    let cyclingFilter   = ExtraArgsFilterHolderCycling()
    let gymFilter       = ExtraArgsFilterHolderGym()
    let skiingFilter    = ExtraArgsFilterHolderSkiing()
    let swimmingFilter  = ExtraArgsFilterHolderSwimming()
    let hikingFilter    = ExtraArgsFilterHolderHiking()
    let yogaFilter      = ExtraArgsFilterHolderYoga()
    let tennisFilter    = ExtraArgsFilterHolderTennis()

    var selectedActivity: ActivityType {
        AvailabilityConfig.activityType(for: selectedActivityIndex)
    }

    func buildSearchPayload() -> [String: Any] {
        var payload: [String: Any] = [
            "activity":  selectedActivity.rawValue,
            "startTime": startDateTime.timeIntervalSince1970,
            "endTime":   endDateTime.timeIntervalSince1970,
        ]
        if let g = gender { payload["gender"] = g.rawValue }

        switch selectedActivity {
        case .running:
            payload["minDistance"] = runningFilter.minDistance
            payload["maxDistance"] = runningFilter.maxDistance
            payload["minPace"]     = runningFilter.minPace
            payload["maxPace"]     = runningFilter.maxPace
            payload["runningType"] = runningFilter.runningType?.rawValue
        case .cycling:
            payload["minPower"]    = cyclingFilter.minPower
            payload["maxPower"]    = cyclingFilter.maxPower
            payload["minCadence"]  = cyclingFilter.minCadence
            payload["maxCadence"]  = cyclingFilter.maxCadence
            payload["cyclingType"] = cyclingFilter.cyclingType?.rawValue
        case .gym:
            payload["gymDayType"]  = gymFilter.gymDayType?.rawValue
        case .skiing:
            payload["minSpeed"]    = skiingFilter.minSpeed
            payload["maxSpeed"]    = skiingFilter.maxSpeed
            payload["minDrop"]     = skiingFilter.minDrop
            payload["maxDrop"]     = skiingFilter.maxDrop
        case .swimming:
            payload["minDistance"] = swimmingFilter.minDistance
            payload["maxDistance"] = swimmingFilter.maxDistance
            payload["minPace"]     = swimmingFilter.minPace
            payload["maxPace"]     = swimmingFilter.maxPace
            payload["stroke"]      = swimmingFilter.stroke?.rawValue
        case .hiking:
            payload["minDistance"] = hikingFilter.minDistance
            payload["maxDistance"] = hikingFilter.maxDistance
            payload["minElevation"] = hikingFilter.minElevation
            payload["maxElevation"] = hikingFilter.maxElevation
        case .yoga:
            payload["minDuration"] = yogaFilter.minDuration
            payload["maxDuration"] = yogaFilter.maxDuration
            payload["minIntensity"] = yogaFilter.minIntensity
            payload["maxIntensity"] = yogaFilter.maxIntensity
            payload["style"]       = yogaFilter.style?.rawValue
        case .tennis:
            payload["minSets"]     = tennisFilter.minSets
            payload["maxSets"]     = tennisFilter.maxSets
            payload["minDuration"] = tennisFilter.minDuration
            payload["maxDuration"] = tennisFilter.maxDuration
            payload["format"]      = tennisFilter.format?.rawValue
        }
        return payload
    }
    
    func buildExtraQueryParams() -> [String: String] {
        var p: [String: String] = [:]

        if let g = gender { p["gender"] = g.rawValue }

        switch selectedActivity {
        case .running:
            if let v = runningFilter.minDistance  { p["minProposedDistance"]  = String(v) }
            if let v = runningFilter.maxDistance  { p["maxProposedDistance"]  = String(v) }
            if let v = runningFilter.minPace      { p["minProposedPace"]      = String(v) }
            if let v = runningFilter.maxPace      { p["maxProposedPace"]      = String(v) }
            if let v = runningFilter.runningType  { p["proposedRunningType"]  = v.rawValue }

        case .cycling:
            if let v = cyclingFilter.minPower     { p["minProposedPowerInWatt"]   = String(v) }
            if let v = cyclingFilter.maxPower     { p["maxProposedPowerInWatt"]   = String(v) }
            if let v = cyclingFilter.minCadence   { p["minProposedCadenceInRPM"]  = String(v) }
            if let v = cyclingFilter.maxCadence   { p["maxProposedCadenceInRPM"]  = String(v) }
            if let v = cyclingFilter.cyclingType  { p["proposedCyclingType"]      = v.rawValue }

        case .gym:
            if let v = gymFilter.gymDayType       { p["proposedDayType"]          = v.rawValue }

        case .skiing:
            if let v = skiingFilter.minSpeed      { p["minProposedSpeedInKmH"]       = String(v) }
            if let v = skiingFilter.maxSpeed      { p["maxProposedSpeedInKmH"]       = String(v) }
            if let v = skiingFilter.minDrop       { p["minProposedVerticalDropInM"]  = String(v) }
            if let v = skiingFilter.maxDrop       { p["maxProposedVerticalDropInM"]  = String(v) }

        case .swimming:
            if let v = swimmingFilter.minDistance { p["minProposedDistanceInM"]  = String(v) }
            if let v = swimmingFilter.maxDistance { p["maxProposedDistanceInM"]  = String(v) }
            if let v = swimmingFilter.minPace     { p["minProposedPacePer100M"]  = String(v) }
            if let v = swimmingFilter.maxPace     { p["maxProposedPacePer100M"]  = String(v) }
            if let v = swimmingFilter.stroke      { p["proposedStroke"]          = v.rawValue }

        case .hiking:
            if let v = hikingFilter.minDistance   { p["minProposedDistanceInKm"]     = String(v) }
            if let v = hikingFilter.maxDistance   { p["maxProposedDistanceInKm"]     = String(v) }
            if let v = hikingFilter.minElevation  { p["minProposedElevationGainInM"] = String(v) }
            if let v = hikingFilter.maxElevation  { p["maxProposedElevationGainInM"] = String(v) }

        case .yoga:
            if let v = yogaFilter.minDuration     { p["minProposedDurationInMin"]  = String(v) }
            if let v = yogaFilter.maxDuration     { p["maxProposedDurationInMin"]  = String(v) }
            if let v = yogaFilter.minIntensity    { p["minProposedIntensityLevel"] = String(v) }
            if let v = yogaFilter.maxIntensity    { p["maxProposedIntensityLevel"] = String(v) }
            if let v = yogaFilter.style           { p["proposedStyle"]             = v.rawValue }

        case .tennis:
            if let v = tennisFilter.minSets       { p["minProposedSets"]         = String(v) }
            if let v = tennisFilter.maxSets       { p["maxProposedSets"]         = String(v) }
            if let v = tennisFilter.minDuration   { p["minProposedDurationInMin"] = String(v) }
            if let v = tennisFilter.maxDuration   { p["maxProposedDurationInMin"] = String(v) }
            if let v = tennisFilter.format        { p["proposedFormat"]           = v.rawValue }
        }

        return p
    }
    
    static func == (
        lhs: AvailabilityFiltersResults,
        rhs: AvailabilityFiltersResults
    ) -> Bool {
        lhs.selectedActivityIndex == rhs.selectedActivityIndex &&
        lhs.startDateTime == rhs.startDateTime &&
        lhs.endDateTime == rhs.endDateTime &&
        lhs.gender == rhs.gender
    }
}
