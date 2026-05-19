//
//  AvailabilityFiltersResults.swift
//  sbud
//
//  Created by ahmed on 29/12/2025.
//

import Foundation
import Combine

class AvailabilityFiltersResults: ObservableObject {
    @Published var selectedActivityIndex = 0
    @Published var startDateTime = Date()
    @Published var endDateTime = Calendar.current.date(byAdding: .hour, value: 5, to: Date()) ?? Date()

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
            payload["minDistanceInKm"]  = runningFilter.minDistanceInKm
            payload["maxDistanceInKm"]  = runningFilter.maxDistanceInKm
            payload["minPace"]          = runningFilter.minPace
            payload["maxPace"]          = runningFilter.maxPace
            payload["minDurationInMin"] = runningFilter.minDurationInMin
            payload["maxDurationInMin"] = runningFilter.maxDurationInMin
            payload["runningType"]      = runningFilter.runningType?.rawValue

        case .cycling:
            payload["minDistanceInKm"]  = cyclingFilter.minDistanceInKm
            payload["maxDistanceInKm"]  = cyclingFilter.maxDistanceInKm
            payload["minSpeedInKmH"]    = cyclingFilter.minSpeedInKmH
            payload["maxSpeedInKmH"]    = cyclingFilter.maxSpeedInKmH
            payload["minDurationInMin"] = cyclingFilter.minDurationInMin
            payload["maxDurationInMin"] = cyclingFilter.maxDurationInMin
            payload["cyclingType"]      = cyclingFilter.cyclingType?.rawValue

        case .gym:
            payload["minDurationInMin"] = gymFilter.minDurationInMin
            payload["maxDurationInMin"] = gymFilter.maxDurationInMin
            payload["gymDayType"]       = gymFilter.gymDayType?.rawValue

        case .skiing:
            payload["minAvgSpeedInKmH"]      = skiingFilter.minAvgSpeedInKmH
            payload["maxAvgSpeedInKmH"]      = skiingFilter.maxAvgSpeedInKmH
            payload["minAvgVerticalDropInM"] = skiingFilter.minAvgVerticalDropInM
            payload["maxAvgVerticalDropInM"] = skiingFilter.maxAvgVerticalDropInM
            payload["minNumberOfRuns"]       = skiingFilter.minNumberOfRuns
            payload["maxNumberOfRuns"]       = skiingFilter.maxNumberOfRuns
            payload["minDurationInMin"]      = skiingFilter.minDurationInMin
            payload["maxDurationInMin"]      = skiingFilter.maxDurationInMin

        case .swimming:
            payload["minDistanceInM"]   = swimmingFilter.minDistanceInM
            payload["maxDistanceInM"]   = swimmingFilter.maxDistanceInM
            payload["minPace"]          = swimmingFilter.minPace
            payload["maxPace"]          = swimmingFilter.maxPace
            payload["minDurationInMin"] = swimmingFilter.minDurationInMin
            payload["maxDurationInMin"] = swimmingFilter.maxDurationInMin
            payload["stroke"]           = swimmingFilter.stroke?.rawValue

        case .hiking:
            payload["minDistanceInKm"]      = hikingFilter.minDistanceInKm
            payload["maxDistanceInKm"]      = hikingFilter.maxDistanceInKm
            payload["minElevationGainInM"]  = hikingFilter.minElevationGainInM
            payload["maxElevationGainInM"]  = hikingFilter.maxElevationGainInM
            payload["minElevationLossInM"]  = hikingFilter.minElevationLossInM
            payload["maxElevationLossInM"]  = hikingFilter.maxElevationLossInM
            payload["minAltitudeInM"]       = hikingFilter.minAltitudeInM
            payload["maxAltitudeInM"]       = hikingFilter.maxAltitudeInM
            payload["minDurationInMin"]     = hikingFilter.minDurationInMin
            payload["maxDurationInMin"]     = hikingFilter.maxDurationInMin

        case .yoga:
            payload["minDurationInMin"]  = yogaFilter.minDurationInMin
            payload["maxDurationInMin"]  = yogaFilter.maxDurationInMin
            payload["minIntensity"]      = yogaFilter.minIntensity
            payload["maxIntensity"]      = yogaFilter.maxIntensity
            payload["style"]             = yogaFilter.style?.rawValue

        case .tennis:
            payload["minSets"]          = tennisFilter.minSets
            payload["maxSets"]          = tennisFilter.maxSets
            payload["minDurationInMin"] = tennisFilter.minDurationInMin
            payload["maxDurationInMin"] = tennisFilter.maxDurationInMin
            payload["format"]           = tennisFilter.format?.rawValue
        }

        return payload
    }

    func buildExtraQueryParams() -> [String: String] {
        var p: [String: String] = [:]

        if let g = gender { p["gender"] = g.rawValue }

        switch selectedActivity {
        case .running:
            if let v = runningFilter.minDistanceInKm  { p["minProposedDistance"]    = String(v) }
            if let v = runningFilter.maxDistanceInKm  { p["maxProposedDistance"]    = String(v) }
            if let v = runningFilter.minPace          { p["minProposedPace"]        = String(v) }
            if let v = runningFilter.maxPace          { p["maxProposedPace"]        = String(v) }
            if let v = runningFilter.minDurationInMin { p["minProposedDurationInMin"] = String(v) }
            if let v = runningFilter.maxDurationInMin { p["maxProposedDurationInMin"] = String(v) }
            if let v = runningFilter.runningType      { p["proposedRunningType"]    = v.rawValue }

        case .cycling:
            if let v = cyclingFilter.minDistanceInKm  { p["minProposedDistanceInKm"] = String(v) }
            if let v = cyclingFilter.maxDistanceInKm  { p["maxProposedDistanceInKm"] = String(v) }
            if let v = cyclingFilter.minSpeedInKmH    { p["minProposedSpeedInKmH"]   = String(v) }
            if let v = cyclingFilter.maxSpeedInKmH    { p["maxProposedSpeedInKmH"]   = String(v) }
            if let v = cyclingFilter.minDurationInMin { p["minProposedDurationInMin"] = String(v) }
            if let v = cyclingFilter.maxDurationInMin { p["maxProposedDurationInMin"] = String(v) }
            if let v = cyclingFilter.cyclingType      { p["proposedCyclingType"]      = v.rawValue }

        case .gym:
            if let v = gymFilter.minDurationInMin { p["minProposedDurationInMin"] = String(v) }
            if let v = gymFilter.maxDurationInMin { p["maxProposedDurationInMin"] = String(v) }
            if let v = gymFilter.gymDayType       { p["proposedDayType"]          = v.rawValue }

        case .skiing:
            if let v = skiingFilter.minAvgSpeedInKmH      { p["minProposedAvgSpeedInKmH"]      = String(v) }
            if let v = skiingFilter.maxAvgSpeedInKmH      { p["maxProposedAvgSpeedInKmH"]      = String(v) }
            if let v = skiingFilter.minAvgVerticalDropInM { p["minProposedAvgVerticalDropInM"] = String(v) }
            if let v = skiingFilter.maxAvgVerticalDropInM { p["maxProposedAvgVerticalDropInM"] = String(v) }
            if let v = skiingFilter.minNumberOfRuns       { p["minProposedNumberOfRuns"]       = String(v) }
            if let v = skiingFilter.maxNumberOfRuns       { p["maxProposedNumberOfRuns"]       = String(v) }
            if let v = skiingFilter.minDurationInMin      { p["minProposedDurationInMin"]      = String(v) }
            if let v = skiingFilter.maxDurationInMin      { p["maxProposedDurationInMin"]      = String(v) }

        case .swimming:
            if let v = swimmingFilter.minDistanceInM   { p["minProposedDistanceInM"]  = String(v) }
            if let v = swimmingFilter.maxDistanceInM   { p["maxProposedDistanceInM"]  = String(v) }
            if let v = swimmingFilter.minPace          { p["minProposedPacePer100M"]  = String(v) }
            if let v = swimmingFilter.maxPace          { p["maxProposedPacePer100M"]  = String(v) }
            if let v = swimmingFilter.minDurationInMin { p["minProposedDurationInMin"] = String(v) }
            if let v = swimmingFilter.maxDurationInMin { p["maxProposedDurationInMin"] = String(v) }
            if let v = swimmingFilter.stroke           { p["proposedStroke"]           = v.rawValue }

        case .hiking:
            if let v = hikingFilter.minDistanceInKm      { p["minProposedDistanceInKm"]      = String(v) }
            if let v = hikingFilter.maxDistanceInKm      { p["maxProposedDistanceInKm"]      = String(v) }
            if let v = hikingFilter.minElevationGainInM  { p["minProposedElevationGainInM"]  = String(v) }
            if let v = hikingFilter.maxElevationGainInM  { p["maxProposedElevationGainInM"]  = String(v) }
            if let v = hikingFilter.minElevationLossInM  { p["minProposedElevationLossInM"]  = String(v) }
            if let v = hikingFilter.maxElevationLossInM  { p["maxProposedElevationLossInM"]  = String(v) }
            if let v = hikingFilter.minAltitudeInM       { p["minProposedMaxAltitudeInM"]    = String(v) }
            if let v = hikingFilter.maxAltitudeInM       { p["maxProposedMaxAltitudeInM"]    = String(v) }
            if let v = hikingFilter.minDurationInMin     { p["minProposedDurationInMin"]     = String(v) }
            if let v = hikingFilter.maxDurationInMin     { p["maxProposedDurationInMin"]     = String(v) }

        case .yoga:
            if let v = yogaFilter.minDurationInMin  { p["minProposedDurationInMin"]  = String(v) }
            if let v = yogaFilter.maxDurationInMin  { p["maxProposedDurationInMin"]  = String(v) }
            if let v = yogaFilter.minIntensity      { p["minProposedIntensityLevel"] = String(v) }
            if let v = yogaFilter.maxIntensity      { p["maxProposedIntensityLevel"] = String(v) }
            if let v = yogaFilter.style             { p["proposedStyle"]             = v.rawValue }

        case .tennis:
            if let v = tennisFilter.minSets          { p["minProposedSets"]          = String(v) }
            if let v = tennisFilter.maxSets          { p["maxProposedSets"]          = String(v) }
            if let v = tennisFilter.minDurationInMin { p["minProposedDurationInMin"] = String(v) }
            if let v = tennisFilter.maxDurationInMin { p["maxProposedDurationInMin"] = String(v) }
            if let v = tennisFilter.format           { p["proposedFormat"]           = v.rawValue }
        }

        return p
    }
}
