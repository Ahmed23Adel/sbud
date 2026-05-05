//
//  ActivityMetrics.swift
//  sbud
//
//  Created by Erdal on 1.05.2026.
//

import Foundation

// MARK: - Container

struct ActivityMetrics: Codable, Equatable {
    var running:  RunningData?
    var cycling:  CyclingData?
    var gym:      GymData?
    var skiing:   SkiingData?
    var swimming: SwimmingData?
    var hiking:   HikingData?
    var yoga:     YogaData?
    var tennis:   TennisData?
}

// MARK: - Running

struct RunningData: Codable, Equatable {
    var preferredDistance: Double = 0.0
    var preferredPace: Double = 0.0
    var preferredType: RunningType = .road
}

// MARK: - Cycling

struct CyclingData: Codable, Equatable {
    var preferredType: CyclingType = .street
    var preferredPower: Double = 0.0
    var preferredCadence: Double = 0.0
}

// MARK: - Gym

struct GymData: Codable, Equatable {

    var preferredDayType: GymDayType = .push
}

// MARK: - Skiing

struct SkiingData: Codable, Equatable {
    var preferredSpeed: Double = 0.0
    var preferredVerticalDrop: Double = 0.0
}

// MARK: - Swimming

struct SwimmingData: Codable, Equatable {

    var preferredDistance: Double = 0.0
    var preferredPace: Double = 0.0
    var preferredStroke: SwimmingStroke = .freestyle
}

// MARK: - Hiking

struct HikingData: Codable, Equatable {
    
    var preferredDistance: Double = 0.0
    var preferredElevation: Double = 0.0

}

// MARK: - Yoga

struct YogaData: Codable, Equatable {
    
    var preferredDuration: Double = 0.0
    var preferredIntensity: Double = 0.0
    var preferredStyle: YogaStyle = .vinyasa
}

// MARK: - Tennis

struct TennisData: Codable, Equatable {

    var preferredSets: Double = 0.0
    var preferredDuration: Double = 0.0
    var preferredFormat: TennisFormat = .singles

}
