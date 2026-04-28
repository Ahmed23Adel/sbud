//
//  ExtraEventReturnables.swift
//  sbud
//
//  Created by ahmed on 14/03/2026.
//

import Foundation
import Combine
// PLZ plz plz plz make sure to run these classes inside @MainActor only


protocol ExtraArgsHolderForSport: Encodable, Decodable {
    var activityType: String { get }
    func areFieldsValid() -> Bool
}

// MARK: - Running

enum RunningType: String, Codable, CaseIterable {
    case road      = "Road"
    case trail     = "Trail"
    case track     = "Track"
    case treadmill = "Treadmill"
}

@Observable
class ExtraArgsHolderRunning: ExtraArgsHolderForSport, Decodable {
    let activityType = ActivityType.running.rawValue
    var proposedDistance     = 6.0
    var proposedPace         = 8.30
    var proposedRunningType  = RunningType.road

    enum CodingKeys: String, CodingKey {
        case activityType, proposedDistance, proposedPace, proposedRunningType
    }

    init() {}

    required init(from decoder: any Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        proposedDistance    = try c.decodeIfPresent(Double.self,      forKey: .proposedDistance)    ?? 6.0
        proposedPace        = try c.decodeIfPresent(Double.self,      forKey: .proposedPace)        ?? 8.30
        proposedRunningType = try c.decodeIfPresent(RunningType.self, forKey: .proposedRunningType) ?? .road
    }

    nonisolated func encode(to encoder: any Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(activityType, forKey: .activityType)
        try c.encode(proposedDistance,     forKey: .proposedDistance)
        try c.encode(proposedPace,         forKey: .proposedPace)
        try c.encode(proposedRunningType,  forKey: .proposedRunningType)
    }

    func areFieldsValid() -> Bool { proposedDistance > 0 && proposedPace > 0 }
}

// MARK: - Cycling

enum CyclingType: String, Codable, CaseIterable {
    case street   = "Street"
    case track    = "Track"
    case mountain = "Mountain"
    case downhill = "Downhill mountain"
}

@Observable
class ExtraArgsHolderCycling: ExtraArgsHolderForSport, Decodable {
    let activityType  = ActivityType.cycling.rawValue
    var proposedCyclingType   = CyclingType.street
    var proposedPowerInWatt   = 200.0
    var proposedCadenceInRPM  = 80.0

    enum CodingKeys: String, CodingKey {
        case activityType, proposedCyclingType, proposedPowerInWatt, proposedCadenceInRPM
    }

    init() {}

    required init(from decoder: any Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        proposedCyclingType  = try c.decodeIfPresent(CyclingType.self, forKey: .proposedCyclingType)  ?? .street
        proposedPowerInWatt  = try c.decodeIfPresent(Double.self,      forKey: .proposedPowerInWatt)  ?? 200.0
        proposedCadenceInRPM = try c.decodeIfPresent(Double.self,      forKey: .proposedCadenceInRPM) ?? 80.0
    }

    nonisolated func encode(to encoder: any Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(activityType, forKey: .activityType)
        try c.encode(proposedCyclingType,  forKey: .proposedCyclingType)
        try c.encode(proposedPowerInWatt,  forKey: .proposedPowerInWatt)
        try c.encode(proposedCadenceInRPM, forKey: .proposedCadenceInRPM)
    }

    func areFieldsValid() -> Bool { proposedPowerInWatt > 0 && proposedCadenceInRPM > 0 }
}

// MARK: - Gym

@Observable
class ExtraArgsHolderGym: ExtraArgsHolderForSport, Decodable {
    let activityType = ActivityType.gym.rawValue
    var proposedDayType      = GymDayType.push

    enum CodingKeys: String, CodingKey {
        case activityType, proposedDayType
    }

    init() {}

    required init(from decoder: any Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        proposedDayType = try c.decodeIfPresent(GymDayType.self, forKey: .proposedDayType) ?? .push
    }

    nonisolated func encode(to encoder: any Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(activityType, forKey: .activityType)
        try c.encode(proposedDayType,      forKey: .proposedDayType)
    }

    func areFieldsValid() -> Bool { true }
}

// MARK: - Skiing

@Observable
class ExtraArgsHolderSkiing: ExtraArgsHolderForSport, Decodable {
    let activityType     = ActivityType.skiing.rawValue
    var proposedSpeedInKmH       = 40.0
    var proposedVerticalDropInM  = 500.0

    enum CodingKeys: String, CodingKey {
        case activityType, proposedSpeedInKmH, proposedVerticalDropInM
    }

    init() {}

    required init(from decoder: any Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        proposedSpeedInKmH      = try c.decodeIfPresent(Double.self, forKey: .proposedSpeedInKmH)      ?? 40.0
        proposedVerticalDropInM = try c.decodeIfPresent(Double.self, forKey: .proposedVerticalDropInM) ?? 500.0
    }

    nonisolated func encode(to encoder: any Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(activityType,   forKey: .activityType)
        try c.encode(proposedSpeedInKmH,     forKey: .proposedSpeedInKmH)
        try c.encode(proposedVerticalDropInM, forKey: .proposedVerticalDropInM)
    }

    func areFieldsValid() -> Bool { proposedSpeedInKmH > 0 && proposedVerticalDropInM > 0 }
}

// MARK: - Swimming

enum SwimmingStroke: String, Codable, CaseIterable {
    case freestyle    = "Freestyle"
    case breaststroke = "Breaststroke"
    case backstroke   = "Backstroke"
    case butterfly    = "Butterfly"
    case medley       = "Medley"
}

@Observable
class ExtraArgsHolderSwimming: ExtraArgsHolderForSport, Decodable {
    let activityType = ActivityType.swimming.rawValue
    var proposedDistanceInM  = 1000.0
    var proposedPacePer100M  = 2.0
    var proposedStroke       = SwimmingStroke.freestyle

    enum CodingKeys: String, CodingKey {
        case activityType, proposedDistanceInM, proposedPacePer100M, proposedStroke
    }

    init() {}

    required init(from decoder: any Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        proposedDistanceInM = try c.decodeIfPresent(Double.self,         forKey: .proposedDistanceInM) ?? 1000.0
        proposedPacePer100M = try c.decodeIfPresent(Double.self,         forKey: .proposedPacePer100M) ?? 2.0
        proposedStroke      = try c.decodeIfPresent(SwimmingStroke.self, forKey: .proposedStroke)      ?? .freestyle
    }

    nonisolated func encode(to encoder: any Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(activityType, forKey: .activityType)
        try c.encode(proposedDistanceInM,  forKey: .proposedDistanceInM)
        try c.encode(proposedPacePer100M,  forKey: .proposedPacePer100M)
        try c.encode(proposedStroke,       forKey: .proposedStroke)
    }

    func areFieldsValid() -> Bool { proposedDistanceInM > 0 && proposedPacePer100M > 0 }
}

// MARK: - Hiking

@Observable
class ExtraArgsHolderHiking: ExtraArgsHolderForSport, Decodable {
    let activityType     = ActivityType.hiking.rawValue
    var proposedDistanceInKm     = 10.0
    var proposedElevationGainInM = 400.0

    enum CodingKeys: String, CodingKey {
        case activityType, proposedDistanceInKm, proposedElevationGainInM
    }

    init() {}

    required init(from decoder: any Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        proposedDistanceInKm     = try c.decodeIfPresent(Double.self, forKey: .proposedDistanceInKm)     ?? 10.0
        proposedElevationGainInM = try c.decodeIfPresent(Double.self, forKey: .proposedElevationGainInM) ?? 400.0
    }

    nonisolated func encode(to encoder: any Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(activityType,   forKey: .activityType)
        try c.encode(proposedDistanceInKm,   forKey: .proposedDistanceInKm)
        try c.encode(proposedElevationGainInM, forKey: .proposedElevationGainInM)
    }

    func areFieldsValid() -> Bool { proposedDistanceInKm > 0 && proposedElevationGainInM >= 0 }
}

// MARK: - Yoga

enum YogaStyle: String, Codable, CaseIterable {
    case vinyasa     = "Vinyasa"
    case hatha       = "Hatha"
    case ashtanga    = "Ashtanga"
    case yin         = "Yin"
    case restorative = "Restorative"
    case power       = "Power"
}

@Observable
class ExtraArgsHolderYoga: ExtraArgsHolderForSport, Decodable {
    let activityType   = ActivityType.yoga.rawValue
    var proposedDurationInMin  = 60.0
    var proposedIntensityLevel = 5.0
    var proposedStyle          = YogaStyle.vinyasa

    enum CodingKeys: String, CodingKey {
        case activityType, proposedDurationInMin, proposedIntensityLevel, proposedStyle
    }

    init() {}

    required init(from decoder: any Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        proposedDurationInMin  = try c.decodeIfPresent(Double.self,    forKey: .proposedDurationInMin)  ?? 60.0
        proposedIntensityLevel = try c.decodeIfPresent(Double.self,    forKey: .proposedIntensityLevel) ?? 5.0
        proposedStyle          = try c.decodeIfPresent(YogaStyle.self, forKey: .proposedStyle)          ?? .vinyasa
    }

    nonisolated func encode(to encoder: any Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(activityType,  forKey: .activityType)
        try c.encode(proposedDurationInMin,  forKey: .proposedDurationInMin)
        try c.encode(proposedIntensityLevel, forKey: .proposedIntensityLevel)
        try c.encode(proposedStyle,          forKey: .proposedStyle)
    }

    func areFieldsValid() -> Bool {
        proposedDurationInMin > 0 && proposedIntensityLevel >= 1 && proposedIntensityLevel <= 10
    }
}

// MARK: - Tennis

enum TennisFormat: String, Codable, CaseIterable {
    case singles = "Singles"
    case doubles = "Doubles"
}

@Observable
class ExtraArgsHolderTennis: ExtraArgsHolderForSport, Decodable {
    let activityType  = ActivityType.tennis.rawValue
    var proposedSets          = 3.0
    var proposedDurationInMin = 90.0
    var proposedFormat        = TennisFormat.singles

    enum CodingKeys: String, CodingKey {
        case activityType, proposedSets, proposedDurationInMin, proposedFormat
    }

    init() {}

    required init(from decoder: any Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        proposedSets          = try c.decodeIfPresent(Double.self,       forKey: .proposedSets)          ?? 3.0
        proposedDurationInMin = try c.decodeIfPresent(Double.self,       forKey: .proposedDurationInMin) ?? 90.0
        proposedFormat        = try c.decodeIfPresent(TennisFormat.self, forKey: .proposedFormat)        ?? .singles
    }

    nonisolated func encode(to encoder: any Encoder) throws {
        var c = encoder.container(keyedBy: CodingKeys.self)
        try c.encode(activityType, forKey: .activityType)
        try c.encode(proposedSets,          forKey: .proposedSets)
        try c.encode(proposedDurationInMin, forKey: .proposedDurationInMin)
        try c.encode(proposedFormat,        forKey: .proposedFormat)
    }

    func areFieldsValid() -> Bool { proposedSets >= 1 && proposedSets <= 3 && proposedDurationInMin > 0 }
}

// MARK: - ExtraArgsHolder
@Observable
class ExtraArgsHolder: Decodable {
    var selectedActivity: ActivityType = .running {
        didSet { updateExtraArgs() }
    }
    var extraArgs: any ExtraArgsHolderForSport = ExtraArgsHolderRunning()

    private enum CodingKeys: String, CodingKey {
        case activityType
    }

    init() {}

    required init(from decoder: any Decoder) throws {
        let c = try decoder.container(keyedBy: CodingKeys.self)
        let rawType = try c.decode(String.self, forKey: .activityType)

        guard let activity = ActivityType(rawValue: rawType) else {
            throw DecodingError.dataCorruptedError(
                forKey: .activityType,
                in: c,
                debugDescription: "Unknown activityType: \(rawType)"
            )
        }

        selectedActivity = activity
        switch activity {
        case .running:  extraArgs = try ExtraArgsHolderRunning(from: decoder)
        case .cycling:  extraArgs = try ExtraArgsHolderCycling(from: decoder)
        case .gym:      extraArgs = try ExtraArgsHolderGym(from: decoder)
        case .skiing:   extraArgs = try ExtraArgsHolderSkiing(from: decoder)
        case .swimming: extraArgs = try ExtraArgsHolderSwimming(from: decoder)
        case .hiking:   extraArgs = try ExtraArgsHolderHiking(from: decoder)
        case .yoga:     extraArgs = try ExtraArgsHolderYoga(from: decoder)
        case .tennis:   extraArgs = try ExtraArgsHolderTennis(from: decoder)
        }
    }

    func updateExtraArgs() {
        switch selectedActivity {
        case .running:  extraArgs = ExtraArgsHolderRunning()
        case .cycling:  extraArgs = ExtraArgsHolderCycling()
        case .gym:      extraArgs = ExtraArgsHolderGym()
        case .skiing:   extraArgs = ExtraArgsHolderSkiing()
        case .swimming: extraArgs = ExtraArgsHolderSwimming()
        case .hiking:   extraArgs = ExtraArgsHolderHiking()
        case .yoga:     extraArgs = ExtraArgsHolderYoga()
        case .tennis:   extraArgs = ExtraArgsHolderTennis()
        }
    }

    func areFieldsValid() -> Bool { extraArgs.areFieldsValid() }
}
