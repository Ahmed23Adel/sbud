//
//  AddNewEventTests.swift
//  sbudTests
//
//  Created by ahmed on 16/04/2026.
//

import XCTest
import Foundation
import FirebaseFirestore
@testable import sbud

// MARK: - NewEventBuilder Tests

final class NewEventBuilderTests: XCTestCase {

    var sut: NewEventBuilder!

    override func setUp() {
        super.setUp()
        sut = NewEventBuilder()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // MARK: Default State

    func test_defaultState_titleIsEmpty() {
        XCTAssertTrue(sut.title.isEmpty)
    }

    func test_defaultState_descriptionIsEmpty() {
        XCTAssertTrue(sut.description.isEmpty)
    }

    func test_defaultState_activityTypeIsRunning() {
        XCTAssertEqual(sut.activityType, .running)
    }

    func test_defaultState_isEventPublicIsTrue() {
        XCTAssertTrue(sut.isEventPublic)
    }

    func test_defaultState_joiningConditionIsRequestFromHost() {
        XCTAssertEqual(sut.joiningCondition, .requestFromHost)
    }

    func test_defaultState_eventCapacityIs150() {
        XCTAssertEqual(sut.eventCapacity, 150)
    }

    func test_defaultState_coverImgURLIsNotEmpty() {
        XCTAssertFalse(sut.coverImgURL.isEmpty)
    }

    // MARK: areFieldsValid

    func test_areFieldsValid_returnsFalse_whenTitleIsEmpty() {
        sut.title = ""
        sut.description = "A valid description"
        XCTAssertFalse(sut.areFieldsValid())
    }

    func test_areFieldsValid_returnsFalse_whenDescriptionIsEmpty() {
        sut.title = "Night Run"
        sut.description = ""
        XCTAssertFalse(sut.areFieldsValid())
    }

    func test_areFieldsValid_returnsFalse_whenCapacityIsZero() {
        sut.title = "Night Run"
        sut.description = "Come join us"
        sut.eventCapacity = 0
        XCTAssertFalse(sut.areFieldsValid())
    }

    func test_areFieldsValid_returnsFalse_whenCapacityIsNegative() {
        sut.title = "Night Run"
        sut.description = "Come join us"
        sut.eventCapacity = -5
        XCTAssertFalse(sut.areFieldsValid())
    }

    func test_areFieldsValid_returnsFalse_whenNoDateLocations() {
        sut.title = "Night Run"
        sut.description = "Come join us"
        sut.eventCapacity = 20
        // dateLocationsHolder is empty by default
        XCTAssertFalse(sut.areFieldsValid())
    }

    func test_areFieldsValid_returnsTrue_whenAllFieldsArePopulated() {
        sut.title = "Night Run"
        sut.description = "Come join us"
        sut.eventCapacity = 20
        let dateLocation = makeDateLocation()
        sut.dateLocationsHolder.append(dateLocation)
        // Running extra args are valid by default (distance=6, pace=8.3)
        XCTAssertTrue(sut.areFieldsValid())
    }

    func test_areFieldsValid_returnsFalse_whenCoverImgIsEmpty() {
        sut.coverImgURL = ""
        sut.title = "Night Run"
        sut.description = "Come join us"
        sut.eventCapacity = 20
        sut.dateLocationsHolder.append(makeDateLocation())
        XCTAssertFalse(sut.areFieldsValid())
    }

    // MARK: - Helpers

    private func makeDateLocation() -> DateLocations {
        DateLocations(
            startDateTime: Date(),
            endDateTime: Date().addingTimeInterval(3600),
            locations: [GeoPoint(latitude: 45.4, longitude: 9.1)]
        )
    }
}

// MARK: - ViewModelCoordinatorAddNewEvent Tests

final class ViewModelCoordinatorAddNewEventTests: XCTestCase {

    var sut: ViewModelCoordinatorAddNewEvent!

    override func setUp() {
        super.setUp()
        sut = ViewModelCoordinatorAddNewEvent()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // MARK: Default State

    func test_defaultStep_isStep1() {
        XCTAssertEqual(sut.currentStep, .step1)
    }

    func test_defaultIsDismissed_isFalse() {
        XCTAssertFalse(sut.isDismissed)
    }

    // MARK: Navigation

    func test_moveToStep2_changesCurrentStepToStep2() {
        sut.moveToStep2()
        XCTAssertEqual(sut.currentStep, .step2)
    }

    func test_moveToStep1_changesCurrentStepToStep1() {
        sut.moveToStep2()
        sut.moveToStep1()
        XCTAssertEqual(sut.currentStep, .step1)
    }

    func test_moveToStep1_fromStep1_remainsStep1() {
        sut.moveToStep1()
        XCTAssertEqual(sut.currentStep, .step1)
    }

    // MARK: createEvent - Invalid Fields

    func test_createEvent_withInvalidFields_doesNotSetIsDismissedImmediately() {
        // title, description empty → invalid
        sut.createEvent()
        // isDismissed is set async after sendRequest, but with invalid fields
        // the guard is missing in current impl — this documents current behaviour
        XCTAssertFalse(sut.isDismissed, "isDismissed should not be true synchronously")
    }
}

// MARK: - NewEventExtraArgsHolder Tests

final class NewEventExtraArgsHolderTests: XCTestCase {

    var sut: NewEventExtraArgsHoder!

    override func setUp() {
        super.setUp()
        sut = NewEventExtraArgsHoder()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func test_defaultActivity_isRunning() {
        XCTAssertEqual(sut.selectedActivity, .running)
    }

    func test_defaultExtraArgs_isRunningHolder() {
        XCTAssertTrue(sut.extraArgs is ExtraArgsHolderRunning)
    }
    func test_areFieldsValid_delegatesToExtraArgs() {
        // Running defaults are valid
        XCTAssertTrue(sut.areFieldsValid())
    }

    
}

// MARK: - ExtraArgsHolderCycling Tests

final class ExtraArgsHolderRunningTests: XCTestCase {

    var sut: ExtraArgsHolderRunning!

    override func setUp() {
        super.setUp()
        sut = ExtraArgsHolderRunning()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func test_areFieldsValid_withDefaultValues_returnsTrue() {
        XCTAssertTrue(sut.areFieldsValid())
    }

    func test_areFieldsValid_withPositiveValues_returnsTrue() {
        sut.proposedDistance = 5.0
        sut.propsosedPace = 6.0
        XCTAssertTrue(sut.areFieldsValid())
    }

    func test_areFieldsValid_withZeroDistance_returnsFalse() {
        sut.proposedDistance = 0
        XCTAssertFalse(sut.areFieldsValid())
    }

    func test_areFieldsValid_withZeroPace_returnsFalse() {
        sut.propsosedPace = 0
        XCTAssertFalse(sut.areFieldsValid())
    }

    func test_areFieldsValid_withNegativeDistance_returnsFalse() {
        sut.proposedDistance = -1
        XCTAssertFalse(sut.areFieldsValid())
    }

    func test_areFieldsValid_withNegativePace_returnsFalse() {
        sut.propsosedPace = -3.5
        XCTAssertFalse(sut.areFieldsValid())
    }

    func test_createEncodableRequest_returnsRunningRequest() {
        sut.proposedDistance = 10.0
        sut.propsosedPace = 5.5
        let request = sut.createEncodableRequest() as? RequestActivityDetailsRunning
        XCTAssertNotNil(request)
        XCTAssertEqual(request?.targetDistanceInKm, 10.0)
        XCTAssertEqual(request?.targetPace, 5.5)
        XCTAssertEqual(request?.activityType, "Running")
    }

    func test_createEncodableRequest_reflectsUpdatedValues() {
        sut.proposedDistance = 21.1
        sut.propsosedPace = 4.45
        let request = sut.createEncodableRequest() as? RequestActivityDetailsRunning
        XCTAssertEqual(request?.targetDistanceInKm, 21.1)
        XCTAssertEqual(request?.targetPace, 4.45)
    }
}

// MARK: - ExtraArgsHolderCycling Tests

final class ExtraArgsHolderCyclingTests: XCTestCase {

    var sut: ExtraArgsHolderCycling!

    override func setUp() {
        super.setUp()
        sut = ExtraArgsHolderCycling()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func test_areFieldsValid_withDefaultValues_returnsTrue() {
        XCTAssertTrue(sut.areFieldsValid())
    }

    func test_areFieldsValid_withPositiveValues_returnsTrue() {
        sut.proposedPowerInWatt = 250
        sut.proposedCadenceInRPM = 90
        XCTAssertTrue(sut.areFieldsValid())
    }

    func test_areFieldsValid_withZeroPower_returnsFalse() {
        sut.proposedPowerInWatt = 0
        XCTAssertFalse(sut.areFieldsValid())
    }

    func test_areFieldsValid_withZeroCadence_returnsFalse() {
        sut.proposedCadenceInRPM = 0
        XCTAssertFalse(sut.areFieldsValid())
    }

    func test_areFieldsValid_withNegativePower_returnsFalse() {
        sut.proposedPowerInWatt = -100
        XCTAssertFalse(sut.areFieldsValid())
    }

    func test_areFieldsValid_withNegativeCadence_returnsFalse() {
        sut.proposedCadenceInRPM = -10
        XCTAssertFalse(sut.areFieldsValid())
    }

    func test_createEncodableRequest_returnsCyclingRequest() {
        sut.proposedPowerInWatt = 250
        sut.proposedCadenceInRPM = 90
        let request = sut.createEncodableRequest() as? RequestActivityDetailsCycling
        XCTAssertNotNil(request)
        XCTAssertEqual(request?.powerInWatt, 250)
        XCTAssertEqual(request?.cadenceInRPM, 90)
        XCTAssertEqual(request?.activityType, "Cycling")
    }

    func test_createEncodableRequest_reflectsUpdatedValues() {
        sut.proposedPowerInWatt = 180
        sut.proposedCadenceInRPM = 75
        let request = sut.createEncodableRequest() as? RequestActivityDetailsCycling
        XCTAssertEqual(request?.powerInWatt, 180)
        XCTAssertEqual(request?.cadenceInRPM, 75)
    }
}

// MARK: - ExtraArgsHolderGym Tests

final class ExtraArgsHolderGymTests: XCTestCase {

    var sut: ExtraArgsHolderGym!   // ← hold at class level

    override func setUp() {
        super.setUp()
        sut = ExtraArgsHolderGym()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func test_areFieldsValid_alwaysReturnsTrue() {
        XCTAssertTrue(sut.areFieldsValid())
    }

    func test_createEncodableRequest_returnsGymRequest() {
        sut.proposedDayType = .leg
        let request = sut.createEncodableRequest() as? RequestActivityDetailsGym
        XCTAssertNotNil(request)
        XCTAssertEqual(request?.dayTyp, .leg)
        XCTAssertEqual(request?.activityType, "Gym")
    }

    func test_allGymDayTypes_areAvailable() {
        XCTAssertEqual(GymDayType.allCases.count, 4)
        XCTAssertTrue(GymDayType.allCases.contains(.push))
        XCTAssertTrue(GymDayType.allCases.contains(.pull))
        XCTAssertTrue(GymDayType.allCases.contains(.leg))
        XCTAssertTrue(GymDayType.allCases.contains(.arm))
    }
}

// MARK: - MultipleDateLocationsHolder Tests

final class MultipleDateLocationsHolderTests: XCTestCase {

    var sut: MultipleDateLocationsHolder!

    override func setUp() {
        super.setUp()
        sut = MultipleDateLocationsHolder()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func test_defaultState_lstIsEmpty() {
        XCTAssertTrue(sut.lst.isEmpty)
    }

    func test_areFieldsValid_returnsFalse_whenEmpty() {
        XCTAssertFalse(sut.areFieldsValid())
    }

    func test_areFieldsValid_returnsTrue_afterAppending() {
        sut.append(makeDateLocation())
        XCTAssertTrue(sut.areFieldsValid())
    }

    func test_append_increasesCount() {
        sut.append(makeDateLocation())
        sut.append(makeDateLocation())
        XCTAssertEqual(sut.lst.count, 2)
    }

    func test_subscript_returnsCorrectElement() {
        let dl = makeDateLocation()
        sut.append(dl)
        XCTAssertEqual(sut[0].id, dl.id)
    }

    func test_startAndEndIndex_matchLst() {
        sut.append(makeDateLocation())
        XCTAssertEqual(sut.startIndex, sut.lst.startIndex)
        XCTAssertEqual(sut.endIndex, sut.lst.endIndex)
    }

    private func makeDateLocation() -> DateLocations {
        DateLocations(
            startDateTime: Date(),
            endDateTime: Date().addingTimeInterval(3600),
            locations: [GeoPoint(latitude: 45.4, longitude: 9.1)]
        )
    }
}

// MARK: - CreateNewEventRequest Encoding Tests

final class CreateNewEventRequestEncodingTests: XCTestCase {

    func test_encode_producesValidJSON() throws {
        let activityDetails = RequestActivityDetailsRunning(targetDistanceInKm: 10, targetPace: 5.5)
        let start = ISO8601DateFormatter().date(from: "2026-06-01T08:00:00Z")!
        let end = ISO8601DateFormatter().date(from: "2026-06-01T10:00:00Z")!
        let dateLocation = DateLocations(startDateTime: start, endDateTime: end, locations: [])
        let request = CreateNewEventRequest(
            activityDetails: activityDetails,
            title: "Morning 10K",
            eventImage: "https://example.com/img.jpg",
            isPublic: true,
            joiningCondition: .requestFromHost,
            maxAllowedToJoin: 50,
            notes: "Casual pace",
            dateLocations: [dateLocation]
        )

        let data = try JSONEncoder().encode(request)
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]

        XCTAssertEqual(json["title"] as? String, "Morning 10K")
        XCTAssertEqual(json["isPublic"] as? Bool, true)
        XCTAssertEqual(json["maxAllowedToJoin"] as? Int, 50)
        XCTAssertEqual(json["notes"] as? String, "Casual pace")
        XCTAssertEqual(json["joiningCondition"] as? String, "requestFromHost")
        XCTAssertEqual(json["isDateConfirmed"] as? Bool, false)
        XCTAssertEqual(json["isLocationConfirmed"] as? Bool, false)
    }

    func test_joinCondition_autoJoin_encodesCorrectly() throws {
        let condition = JoinCondition.autoJoin
        let data = try JSONEncoder().encode(condition)
        let value = try JSONDecoder().decode(String.self, from: data)
        XCTAssertEqual(value, "autoJoin")
    }

    func test_joinCondition_requestFromHost_encodesCorrectly() throws {
        let condition = JoinCondition.requestFromHost
        let data = try JSONEncoder().encode(condition)
        let value = try JSONDecoder().decode(String.self, from: data)
        XCTAssertEqual(value, "requestFromHost")
    }

    func test_dateLocations_encodesISO8601Dates() throws {
        let formatter = ISO8601DateFormatter()
        let start = formatter.date(from: "2026-06-01T08:00:00Z")!
        let end = formatter.date(from: "2026-06-01T10:00:00Z")!
        let dl = DateLocations(startDateTime: start, endDateTime: end, locations: [])

        let data = try JSONEncoder().encode(dl)
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]

        XCTAssertEqual(json["startDateTime"] as? String, "2026-06-01T08:00:00Z")
        XCTAssertEqual(json["endDateTime"] as? String, "2026-06-01T10:00:00Z")
    }

    func test_gymDayType_encodesRawValue() throws {
        let data = try JSONEncoder().encode(GymDayType.push)
        let value = try JSONDecoder().decode(String.self, from: data)
        XCTAssertEqual(value, "Push")
    }
}

// MARK: - AddNewEventSteps Tests

final class AddNewEventStepsTests: XCTestCase {

    func test_step1_isDistinctFromStep2() {
        XCTAssertNotEqual(AddNewEventSteps.step1, AddNewEventSteps.step2)
    }

    func test_steps_equalityIsSelf() {
        XCTAssertEqual(AddNewEventSteps.step1, .step1)
        XCTAssertEqual(AddNewEventSteps.step2, .step2)
    }
}
