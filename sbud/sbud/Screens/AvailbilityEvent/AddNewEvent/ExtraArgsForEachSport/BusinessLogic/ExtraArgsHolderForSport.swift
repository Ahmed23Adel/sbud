//
//  ExtraEventReturnables.swift
//  sbud
//
//  Created by ahmed on 14/03/2026.
//

import Foundation
import Combine
// PLZ plz plz plz make sure to run these classes inside @MainActor only

protocol ExtraArgsHolderForSport: Encodable {
    var activityType: String { get }
    func areFieldsValid() -> Bool
}

enum RunningType: String, Encodable, CaseIterable {
    case road      = "Road"
    case trail     = "Trail"
    case track     = "Track"
    case treadmill = "Treadmill"
}
// add var proposedRunningType = RunningType.road to ExtraArgsHolderRunning

// plz note that @Observable ties Encodable conformance to main actor
// which conflicts with Sendable
// so i had to implment encode and make it nonisolated
@Observable
class ExtraArgsHolderRunning: ExtraArgsHolderForSport {
    let activityType = ActivityType.running.rawValue
    var proposedDistance = 6.0
    var proposedPace = 8.30
    var runningType = RunningType.road

    enum CodingKeys: String, CodingKey {
        case activityType
        case proposedDistance = "distance"
        case proposedPace = "pace"
    }

    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(activityType, forKey: .activityType)
        try container.encode(proposedDistance, forKey: .proposedDistance)
        try container.encode(proposedPace, forKey: .proposedPace)
    }

    func areFieldsValid() -> Bool {
        proposedDistance > 0 && proposedPace > 0
    }
}

enum CyclingType: String, CaseIterable {
    case street = "Street"
    case track = "Track"
    case mountain = "Mountain"
    case downhill = "Downhill mountain"
}

@Observable
class ExtraArgsHolderCycling: ExtraArgsHolderForSport {
    let activityType = ActivityType.cycling.rawValue
    var cyclingType = CyclingType.street
    var proposedPowerInWatt = 200.0
    var proposedCadenceInRPM = 80.0

    enum CodingKeys: String, CodingKey {
        case activityType
        case proposedPowerInWatt = "powerInWatt"
        case proposedCadenceInRPM = "cadenceInRPM"
    }

    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(activityType, forKey: .activityType)
        try container.encode(proposedPowerInWatt, forKey: .proposedPowerInWatt)
        try container.encode(proposedCadenceInRPM, forKey: .proposedCadenceInRPM)
    }

    func areFieldsValid() -> Bool {
        proposedPowerInWatt > 0 && proposedCadenceInRPM > 0
    }
}

@Observable
class ExtraArgsHolderGym: ExtraArgsHolderForSport {
    let activityType = ActivityType.gym.rawValue
    var proposedDayType = GymDayType.push

    enum CodingKeys: String, CodingKey {
        case activityType
        case proposedDayType = "dayType"
    }

    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(activityType, forKey: .activityType)
        try container.encode(proposedDayType, forKey: .proposedDayType)
    }

    func areFieldsValid() -> Bool { true }
}

@Observable
class ExtraArgsHolderSkiing: ExtraArgsHolderForSport {
    let activityType = ActivityType.skiing.rawValue
    var proposedSpeedInKmH = 40.0
    var proposedVerticalDropInM = 500.0

    enum CodingKeys: String, CodingKey {
        case activityType
        case proposedSpeedInKmH = "speedInKmH"
        case proposedVerticalDropInM = "verticalDropInM"
    }

    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(activityType, forKey: .activityType)
        try container.encode(proposedSpeedInKmH, forKey: .proposedSpeedInKmH)
        try container.encode(proposedVerticalDropInM, forKey: .proposedVerticalDropInM)
    }

    func areFieldsValid() -> Bool {
        proposedSpeedInKmH > 0 && proposedVerticalDropInM > 0
    }
}

enum SwimmingStroke: String, Encodable, CaseIterable {
    case freestyle   = "Freestyle"
    case breaststroke = "Breaststroke"
    case backstroke  = "Backstroke"
    case butterfly   = "Butterfly"
    case medley      = "Medley"
}
@Observable
class ExtraArgsHolderSwimming: ExtraArgsHolderForSport {
    let activityType = ActivityType.swimming.rawValue
    var proposedDistanceInM = 1000.0
    var proposedPacePer100M = 2.0
    var proposedStroke = SwimmingStroke.freestyle

    enum CodingKeys: String, CodingKey {
        case activityType
        case proposedDistanceInM = "distanceInM"
        case proposedPacePer100M = "pacePer100M"
    }

    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(activityType, forKey: .activityType)
        try container.encode(proposedDistanceInM, forKey: .proposedDistanceInM)
        try container.encode(proposedPacePer100M, forKey: .proposedPacePer100M)
    }

    func areFieldsValid() -> Bool {
        proposedDistanceInM > 0 && proposedPacePer100M > 0
    }
}

@Observable
class ExtraArgsHolderHiking: ExtraArgsHolderForSport {
    let activityType = ActivityType.hiking.rawValue
    var proposedDistanceInKm = 10.0
    var proposedElevationGainInM = 400.0

    enum CodingKeys: String, CodingKey {
        case activityType
        case proposedDistanceInKm = "distanceInKm"
        case proposedElevationGainInM = "elevationGainInM"
    }

    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(activityType, forKey: .activityType)
        try container.encode(proposedDistanceInKm, forKey: .proposedDistanceInKm)
        try container.encode(proposedElevationGainInM, forKey: .proposedElevationGainInM)
    }

    func areFieldsValid() -> Bool {
        proposedDistanceInKm > 0 && proposedElevationGainInM >= 0
    }
}

enum YogaStyle: String, Encodable, CaseIterable {
    case vinyasa    = "Vinyasa"
    case hatha      = "Hatha"
    case ashtanga   = "Ashtanga"
    case yin        = "Yin"
    case restorative = "Restorative"
    case power      = "Power"
}
@Observable
class ExtraArgsHolderYoga: ExtraArgsHolderForSport {
    let activityType = ActivityType.yoga.rawValue
    var proposedDurationInMin = 60.0
    var proposedIntensityLevel = 5.0
    var proposedStyle = YogaStyle.vinyasa

    enum CodingKeys: String, CodingKey {
        case activityType
        case proposedDurationInMin = "durationInMin"
        case proposedIntensityLevel = "intensityLevel"
    }

    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(activityType, forKey: .activityType)
        try container.encode(proposedDurationInMin, forKey: .proposedDurationInMin)
        try container.encode(proposedIntensityLevel, forKey: .proposedIntensityLevel)
    }

    func areFieldsValid() -> Bool {
        proposedDurationInMin > 0 &&
        proposedIntensityLevel >= 1 && proposedIntensityLevel <= 10
    }
}

enum TennisFormat: String, Encodable, CaseIterable {
    case singles = "Singles"
    case doubles = "Doubles"
}
@Observable
class ExtraArgsHolderTennis: ExtraArgsHolderForSport {
    let activityType = ActivityType.tennis.rawValue
    var proposedSets = 3.0
    var proposedDurationInMin = 90.0
    var proposedFormat = TennisFormat.singles

    enum CodingKeys: String, CodingKey {
        case activityType
        case proposedSets = "sets"
        case proposedDurationInMin = "durationInMin"
    }

    func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(activityType, forKey: .activityType)
        try container.encode(proposedSets, forKey: .proposedSets)
        try container.encode(proposedDurationInMin, forKey: .proposedDurationInMin)
    }

    func areFieldsValid() -> Bool {
        proposedSets >= 1 && proposedSets <= 3 &&
        proposedDurationInMin > 0
    }
}

@Observable
class ExtraArgsHolder {
    var selectedActivity: ActivityType = .running {
        didSet {
            updateExtraArgs()
        }
    }
    var extraArgs: any ExtraArgsHolderForSport = ExtraArgsHolderRunning()

    func updateExtraArgs() {
        switch selectedActivity {
        case .running:
            extraArgs = ExtraArgsHolderRunning()
        case .cycling:
            extraArgs = ExtraArgsHolderCycling()
        case .gym:
            extraArgs = ExtraArgsHolderGym()
        case .skiing:
            extraArgs = ExtraArgsHolderSkiing()
        case .swimming:
            extraArgs = ExtraArgsHolderSwimming()
        case .hiking:
            extraArgs = ExtraArgsHolderHiking()
        case .yoga:
            extraArgs = ExtraArgsHolderYoga()
        case .tennis:
            extraArgs = ExtraArgsHolderTennis()
        }
    }

    func areFieldsValid() -> Bool {
        extraArgs.areFieldsValid()
    }
}

