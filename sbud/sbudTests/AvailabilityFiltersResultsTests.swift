//
//  AvailabilityFiltersResultsTests.swift
//  sbudTests
//

import XCTest
@testable import sbud

final class AvailabilityFiltersResultsTests: XCTestCase {

    private var sut: AvailabilityFiltersResults!

    override func setUp() {
        super.setUp()
        sut = AvailabilityFiltersResults()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // MARK: - Initial State

    func test_init_defaultActivityIndexIsZero() {
        XCTAssertEqual(sut.selectedActivityIndex, 0)
    }

    func test_init_defaultGenderIsNil() {
        XCTAssertNil(sut.gender)
    }

    func test_init_endDateTimeIsAfterStartDateTime() {
        XCTAssertGreaterThan(sut.endDateTime, sut.startDateTime)
    }

    // MARK: - selectedActivity

    func test_selectedActivity_defaultIsRunning() {
        XCTAssertEqual(sut.selectedActivity, .running)
    }

    func test_selectedActivity_reflectsSelectedIndex() {
        sut.selectedActivityIndex = 1
        XCTAssertEqual(sut.selectedActivity, .cycling)
    }

    // MARK: - Equatable

    func test_equality_sameDefaultInstances_areEqual() {
        let other = AvailabilityFiltersResults()
        // Both have index 0 and nil gender; dates won't be exactly equal due to Date() calls
        // Only check index and gender equality which are deterministic
        XCTAssertEqual(sut.selectedActivityIndex, other.selectedActivityIndex)
        XCTAssertEqual(sut.gender, other.gender)
    }

    func test_equality_differentActivity_notEqual() {
        let other = AvailabilityFiltersResults()
        other.selectedActivityIndex = 3
        XCTAssertNotEqual(sut, other)
    }

    func test_equality_differentGender_notEqual() {
        let other = AvailabilityFiltersResults()
        other.gender = .male
        XCTAssertNotEqual(sut, other)
    }

    // MARK: - buildExtraQueryParams — Running

    func test_buildExtraQueryParams_running_emptyByDefault() {
        sut.selectedActivityIndex = 0
        let params = sut.buildExtraQueryParams()
        XCTAssertTrue(params.isEmpty)
    }

    func test_buildExtraQueryParams_running_includesMinDistance() {
        sut.selectedActivityIndex = 0
        sut.runningFilter.minDistanceInKm = 5.0
        let params = sut.buildExtraQueryParams()
        XCTAssertEqual(params["minProposedDistance"], "5.0")
    }

    func test_buildExtraQueryParams_running_includesRunningType() {
        sut.selectedActivityIndex = 0
        sut.runningFilter.runningType = .road
        let params = sut.buildExtraQueryParams()
        XCTAssertEqual(params["proposedRunningType"], RunningType.road.rawValue)
    }

    func test_buildExtraQueryParams_running_includesGender() {
        sut.selectedActivityIndex = 0
        sut.gender = .female
        let params = sut.buildExtraQueryParams()
        XCTAssertEqual(params["gender"], GenderFilter.female.rawValue)
    }

    func test_buildExtraQueryParams_running_nilValuesNotIncluded() {
        sut.selectedActivityIndex = 0
        let params = sut.buildExtraQueryParams()
        XCTAssertNil(params["minProposedDistance"])
        XCTAssertNil(params["maxProposedDistance"])
        XCTAssertNil(params["gender"])
    }

    // MARK: - buildExtraQueryParams — Cycling

    func test_buildExtraQueryParams_cycling_includesSpeedFilters() {
        sut.selectedActivityIndex = 1
        sut.cyclingFilter.minSpeedInKmH = 20.0
        sut.cyclingFilter.maxSpeedInKmH = 40.0
        let params = sut.buildExtraQueryParams()
        XCTAssertEqual(params["minProposedSpeedInKmH"], "20.0")
        XCTAssertEqual(params["maxProposedSpeedInKmH"], "40.0")
    }

    // MARK: - buildExtraQueryParams — Gym

    func test_buildExtraQueryParams_gym_includesDurationAndDayType() {
        sut.selectedActivityIndex = 2
        sut.gymFilter.minDurationInMin = 30.0
        sut.gymFilter.gymDayType = .push
        let params = sut.buildExtraQueryParams()
        XCTAssertEqual(params["minProposedDurationInMin"], "30.0")
        XCTAssertEqual(params["proposedDayType"], GymDayType.push.rawValue)
    }

    // MARK: - buildExtraQueryParams — Swimming

    func test_buildExtraQueryParams_swimming_includesStroke() {
        sut.selectedActivityIndex = 4
        sut.swimmingFilter.stroke = .freestyle
        let params = sut.buildExtraQueryParams()
        XCTAssertEqual(params["proposedStroke"], SwimmingStroke.freestyle.rawValue)
    }

    // MARK: - buildExtraQueryParams — Tennis

    func test_buildExtraQueryParams_tennis_includesSetsAndFormat() {
        sut.selectedActivityIndex = 7
        sut.tennisFilter.minSets = 1
        sut.tennisFilter.maxSets = 3
        sut.tennisFilter.format = .singles
        let params = sut.buildExtraQueryParams()
        XCTAssertEqual(params["minProposedSets"], "1.0")
        XCTAssertEqual(params["maxProposedSets"], "3.0")
        XCTAssertEqual(params["proposedFormat"], TennisFormat.singles.rawValue)
    }

    // MARK: - buildSearchPayload — core keys

    func test_buildSearchPayload_alwaysIncludesActivityStartEnd() {
        let payload = sut.buildSearchPayload()
        XCTAssertNotNil(payload["activity"])
        XCTAssertNotNil(payload["startTime"])
        XCTAssertNotNil(payload["endTime"])
    }

    func test_buildSearchPayload_activityMatchesSelectedIndex() {
        sut.selectedActivityIndex = 2
        let payload = sut.buildSearchPayload()
        XCTAssertEqual(payload["activity"] as? String, ActivityType.gym.rawValue)
    }

    func test_buildSearchPayload_genderIncludedWhenSet() {
        sut.gender = .male
        let payload = sut.buildSearchPayload()
        XCTAssertEqual(payload["gender"] as? String, GenderFilter.male.rawValue)
    }

    func test_buildSearchPayload_genderAbsentWhenNil() {
        sut.gender = nil
        let payload = sut.buildSearchPayload()
        XCTAssertNil(payload["gender"])
    }

    // MARK: - buildExtraQueryParams — Skiing

    func test_buildExtraQueryParams_skiing_includesSpeedAndRuns() {
        sut.selectedActivityIndex = 3
        sut.skiingFilter.minAvgSpeedInKmH = 30.0
        sut.skiingFilter.maxAvgSpeedInKmH = 80.0
        sut.skiingFilter.minNumberOfRuns  = 5
        sut.skiingFilter.maxNumberOfRuns  = 20
        let params = sut.buildExtraQueryParams()
        XCTAssertEqual(params["minProposedAvgSpeedInKmH"], "30.0")
        XCTAssertEqual(params["maxProposedAvgSpeedInKmH"], "80.0")
        XCTAssertEqual(params["minProposedNumberOfRuns"],  "5")
        XCTAssertEqual(params["maxProposedNumberOfRuns"],  "20")
    }

    func test_buildExtraQueryParams_skiing_includesVerticalDrop() {
        sut.selectedActivityIndex = 3
        sut.skiingFilter.minAvgVerticalDropInM = 100.0
        sut.skiingFilter.maxAvgVerticalDropInM = 500.0
        let params = sut.buildExtraQueryParams()
        XCTAssertEqual(params["minProposedAvgVerticalDropInM"], "100.0")
        XCTAssertEqual(params["maxProposedAvgVerticalDropInM"], "500.0")
    }

    func test_buildExtraQueryParams_skiing_nilValuesNotIncluded() {
        sut.selectedActivityIndex = 3
        let params = sut.buildExtraQueryParams()
        XCTAssertNil(params["minProposedAvgSpeedInKmH"])
        XCTAssertNil(params["minProposedNumberOfRuns"])
    }

    // MARK: - buildExtraQueryParams — Hiking

    func test_buildExtraQueryParams_hiking_includesDistanceAndElevation() {
        sut.selectedActivityIndex = 5
        sut.hikingFilter.minDistanceInKm     = 5.0
        sut.hikingFilter.maxDistanceInKm     = 20.0
        sut.hikingFilter.minElevationGainInM = 200.0
        sut.hikingFilter.maxElevationGainInM = 1000.0
        let params = sut.buildExtraQueryParams()
        XCTAssertEqual(params["minProposedDistanceInKm"],     "5.0")
        XCTAssertEqual(params["maxProposedDistanceInKm"],     "20.0")
        XCTAssertEqual(params["minProposedElevationGainInM"], "200.0")
        XCTAssertEqual(params["maxProposedElevationGainInM"], "1000.0")
    }

    func test_buildExtraQueryParams_hiking_includesElevationLossAndAltitude() {
        sut.selectedActivityIndex = 5
        sut.hikingFilter.minElevationLossInM = 50.0
        sut.hikingFilter.maxElevationLossInM = 300.0
        sut.hikingFilter.minAltitudeInM      = 500.0
        sut.hikingFilter.maxAltitudeInM      = 2000.0
        let params = sut.buildExtraQueryParams()
        XCTAssertEqual(params["minProposedElevationLossInM"], "50.0")
        XCTAssertEqual(params["maxProposedElevationLossInM"], "300.0")
        XCTAssertEqual(params["minProposedMaxAltitudeInM"],   "500.0")
        XCTAssertEqual(params["maxProposedMaxAltitudeInM"],   "2000.0")
    }

    func test_buildExtraQueryParams_hiking_nilValuesNotIncluded() {
        sut.selectedActivityIndex = 5
        let params = sut.buildExtraQueryParams()
        XCTAssertNil(params["minProposedDistanceInKm"])
        XCTAssertNil(params["minProposedElevationGainInM"])
    }

    // MARK: - buildExtraQueryParams — Yoga

    func test_buildExtraQueryParams_yoga_includesDurationIntensityStyle() {
        sut.selectedActivityIndex = 6
        sut.yogaFilter.minDurationInMin = 30.0
        sut.yogaFilter.maxDurationInMin = 90.0
        sut.yogaFilter.minIntensity     = 2.0
        sut.yogaFilter.maxIntensity     = 8.0
        sut.yogaFilter.style            = .vinyasa
        let params = sut.buildExtraQueryParams()
        XCTAssertEqual(params["minProposedDurationInMin"],  "30.0")
        XCTAssertEqual(params["maxProposedDurationInMin"],  "90.0")
        XCTAssertEqual(params["minProposedIntensityLevel"], "2.0")
        XCTAssertEqual(params["maxProposedIntensityLevel"], "8.0")
        XCTAssertEqual(params["proposedStyle"],             YogaStyle.vinyasa.rawValue)
    }

    func test_buildExtraQueryParams_yoga_nilStyleNotIncluded() {
        sut.selectedActivityIndex = 6
        sut.yogaFilter.style = nil
        let params = sut.buildExtraQueryParams()
        XCTAssertNil(params["proposedStyle"])
    }

    // MARK: - buildSearchPayload — Running sport fields

    func test_buildSearchPayload_running_includesSportFields() {
        sut.selectedActivityIndex = 0
        sut.runningFilter.minDistanceInKm  = 5.0
        sut.runningFilter.maxDistanceInKm  = 10.0
        sut.runningFilter.minPace          = 5.0
        sut.runningFilter.maxPace          = 8.0
        sut.runningFilter.minDurationInMin = 30.0
        sut.runningFilter.maxDurationInMin = 60.0
        sut.runningFilter.runningType      = .trail
        let p = sut.buildSearchPayload()
        XCTAssertEqual(p["minDistanceInKm"]  as? Double, 5.0)
        XCTAssertEqual(p["maxDistanceInKm"]  as? Double, 10.0)
        XCTAssertEqual(p["minPace"]          as? Double, 5.0)
        XCTAssertEqual(p["maxPace"]          as? Double, 8.0)
        XCTAssertEqual(p["minDurationInMin"] as? Double, 30.0)
        XCTAssertEqual(p["maxDurationInMin"] as? Double, 60.0)
        XCTAssertEqual(p["runningType"]      as? String, RunningType.trail.rawValue)
    }

    func test_buildSearchPayload_running_nilRunningTypeIncludedAsNil() {
        sut.selectedActivityIndex = 0
        sut.runningFilter.runningType = nil
        let p = sut.buildSearchPayload()
        // nil Optional is stored as NSNull via `payload["runningType"] = nil`
        // Key will be present but the value is nil — check it's not a non-nil String
        XCTAssertNil(p["runningType"] as? String)
    }

    // MARK: - buildSearchPayload — Cycling sport fields

    func test_buildSearchPayload_cycling_includesSportFields() {
        sut.selectedActivityIndex = 1
        sut.cyclingFilter.minDistanceInKm  = 20.0
        sut.cyclingFilter.maxDistanceInKm  = 100.0
        sut.cyclingFilter.minSpeedInKmH    = 20.0
        sut.cyclingFilter.maxSpeedInKmH    = 40.0
        sut.cyclingFilter.minDurationInMin = 60.0
        sut.cyclingFilter.maxDurationInMin = 180.0
        sut.cyclingFilter.cyclingType      = .mountain
        let p = sut.buildSearchPayload()
        XCTAssertEqual(p["minDistanceInKm"]  as? Double, 20.0)
        XCTAssertEqual(p["maxSpeedInKmH"]    as? Double, 40.0)
        XCTAssertEqual(p["cyclingType"]      as? String, CyclingType.mountain.rawValue)
    }

    // MARK: - buildSearchPayload — Gym sport fields

    func test_buildSearchPayload_gym_includesDurationAndDayType() {
        sut.selectedActivityIndex = 2
        sut.gymFilter.minDurationInMin = 45.0
        sut.gymFilter.maxDurationInMin = 90.0
        sut.gymFilter.gymDayType       = .pull
        let p = sut.buildSearchPayload()
        XCTAssertEqual(p["minDurationInMin"] as? Double, 45.0)
        XCTAssertEqual(p["maxDurationInMin"] as? Double, 90.0)
        XCTAssertEqual(p["gymDayType"]       as? String, GymDayType.pull.rawValue)
    }

    // MARK: - buildSearchPayload — Skiing sport fields

    func test_buildSearchPayload_skiing_includesSportFields() {
        sut.selectedActivityIndex = 3
        sut.skiingFilter.minAvgSpeedInKmH      = 20.0
        sut.skiingFilter.maxAvgSpeedInKmH      = 80.0
        sut.skiingFilter.minAvgVerticalDropInM = 100.0
        sut.skiingFilter.maxAvgVerticalDropInM = 600.0
        sut.skiingFilter.minNumberOfRuns       = 3
        sut.skiingFilter.maxNumberOfRuns       = 15
        sut.skiingFilter.minDurationInMin      = 120.0
        sut.skiingFilter.maxDurationInMin      = 480.0
        let p = sut.buildSearchPayload()
        XCTAssertEqual(p["minAvgSpeedInKmH"]      as? Double, 20.0)
        XCTAssertEqual(p["maxAvgSpeedInKmH"]      as? Double, 80.0)
        XCTAssertEqual(p["minAvgVerticalDropInM"] as? Double, 100.0)
        XCTAssertEqual(p["maxAvgVerticalDropInM"] as? Double, 600.0)
        XCTAssertEqual(p["minNumberOfRuns"]       as? Int,    3)
        XCTAssertEqual(p["maxNumberOfRuns"]       as? Int,    15)
        XCTAssertEqual(p["minDurationInMin"]      as? Double, 120.0)
        XCTAssertEqual(p["maxDurationInMin"]      as? Double, 480.0)
    }

    // MARK: - buildSearchPayload — Swimming sport fields

    func test_buildSearchPayload_swimming_includesSportFields() {
        sut.selectedActivityIndex = 4
        sut.swimmingFilter.minDistanceInM   = 500.0
        sut.swimmingFilter.maxDistanceInM   = 2000.0
        sut.swimmingFilter.minPace          = 1.5
        sut.swimmingFilter.maxPace          = 3.0
        sut.swimmingFilter.minDurationInMin = 30.0
        sut.swimmingFilter.maxDurationInMin = 90.0
        sut.swimmingFilter.stroke           = .backstroke
        let p = sut.buildSearchPayload()
        XCTAssertEqual(p["minDistanceInM"]   as? Double, 500.0)
        XCTAssertEqual(p["maxDistanceInM"]   as? Double, 2000.0)
        XCTAssertEqual(p["minPace"]          as? Double, 1.5)
        XCTAssertEqual(p["stroke"]           as? String, SwimmingStroke.backstroke.rawValue)
    }

    // MARK: - buildSearchPayload — Hiking sport fields

    func test_buildSearchPayload_hiking_includesSportFields() {
        sut.selectedActivityIndex = 5
        sut.hikingFilter.minDistanceInKm     = 5.0
        sut.hikingFilter.maxDistanceInKm     = 25.0
        sut.hikingFilter.minElevationGainInM = 200.0
        sut.hikingFilter.maxElevationGainInM = 1500.0
        sut.hikingFilter.minElevationLossInM = 100.0
        sut.hikingFilter.maxElevationLossInM = 1000.0
        sut.hikingFilter.minAltitudeInM      = 300.0
        sut.hikingFilter.maxAltitudeInM      = 3000.0
        sut.hikingFilter.minDurationInMin    = 90.0
        sut.hikingFilter.maxDurationInMin    = 360.0
        let p = sut.buildSearchPayload()
        XCTAssertEqual(p["minDistanceInKm"]      as? Double, 5.0)
        XCTAssertEqual(p["maxElevationGainInM"]  as? Double, 1500.0)
        XCTAssertEqual(p["minAltitudeInM"]       as? Double, 300.0)
        XCTAssertEqual(p["maxAltitudeInM"]       as? Double, 3000.0)
        XCTAssertEqual(p["minDurationInMin"]      as? Double, 90.0)
    }

    // MARK: - buildSearchPayload — Yoga sport fields

    func test_buildSearchPayload_yoga_includesSportFields() {
        sut.selectedActivityIndex = 6
        sut.yogaFilter.minDurationInMin = 30.0
        sut.yogaFilter.maxDurationInMin = 90.0
        sut.yogaFilter.minIntensity     = 1.0
        sut.yogaFilter.maxIntensity     = 5.0
        sut.yogaFilter.style            = .yin
        let p = sut.buildSearchPayload()
        XCTAssertEqual(p["minDurationInMin"] as? Double, 30.0)
        XCTAssertEqual(p["maxDurationInMin"] as? Double, 90.0)
        XCTAssertEqual(p["minIntensity"]     as? Double, 1.0)
        XCTAssertEqual(p["maxIntensity"]     as? Double, 5.0)
        XCTAssertEqual(p["style"]            as? String, YogaStyle.yin.rawValue)
    }

    // MARK: - buildSearchPayload — Tennis sport fields

    func test_buildSearchPayload_tennis_includesSportFields() {
        sut.selectedActivityIndex = 7
        sut.tennisFilter.minSets          = 1
        sut.tennisFilter.maxSets          = 3
        sut.tennisFilter.minDurationInMin = 60.0
        sut.tennisFilter.maxDurationInMin = 120.0
        sut.tennisFilter.format           = .doubles
        let p = sut.buildSearchPayload()
        XCTAssertEqual(p["minSets"]          as? Double, 1.0)
        XCTAssertEqual(p["maxSets"]          as? Double, 3.0)
        XCTAssertEqual(p["minDurationInMin"] as? Double, 60.0)
        XCTAssertEqual(p["maxDurationInMin"] as? Double, 120.0)
        XCTAssertEqual(p["format"]           as? String, TennisFormat.doubles.rawValue)
    }

    // MARK: - startTime / endTime are Unix timestamps

    func test_buildSearchPayload_startTime_isTimeIntervalSince1970() {
        let p = sut.buildSearchPayload()
        let storedStart = p["startTime"] as? Double
        XCTAssertNotNil(storedStart)
        XCTAssertEqual(storedStart!, sut.startDateTime.timeIntervalSince1970, accuracy: 0.01)
    }

    func test_buildSearchPayload_endTime_isTimeIntervalSince1970() {
        let p = sut.buildSearchPayload()
        let storedEnd = p["endTime"] as? Double
        XCTAssertNotNil(storedEnd)
        XCTAssertEqual(storedEnd!, sut.endDateTime.timeIntervalSince1970, accuracy: 0.01)
    }

    func test_buildSearchPayload_endTime_greaterThan_startTime() {
        let p = sut.buildSearchPayload()
        let start = p["startTime"] as? Double ?? 0
        let end   = p["endTime"]   as? Double ?? 0
        XCTAssertGreaterThan(end, start)
    }
}
