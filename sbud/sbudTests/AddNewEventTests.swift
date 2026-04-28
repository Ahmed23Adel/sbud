//
//  AddNewEventTests.swift
//  sbudTests
//
//  Comprehensive unit test suite for the Add New Event feature.
//

import XCTest
import FirebaseFirestore
@testable import sbud

// MARK: - Helpers

private func makeValidDateLocation() -> DateLocations {
    DateLocations(
        startDateTime: Date(),
        endDateTime: Date().addingTimeInterval(3600),
        locations: [GeoPoint(latitude: 37.7749, longitude: -122.4194)]
    )
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

    // MARK: areFieldsValid

    func test_areFieldsValid_emptyList_returnsFalse() {
        XCTAssertFalse(sut.areFieldsValid())
    }

    func test_areFieldsValid_oneItem_returnsTrue() {
        sut.append(makeValidDateLocation())
        XCTAssertTrue(sut.areFieldsValid())
    }

    func test_areFieldsValid_multipleItems_returnsTrue() {
        sut.append(makeValidDateLocation())
        sut.append(makeValidDateLocation())
        XCTAssertTrue(sut.areFieldsValid())
    }

    // MARK: Collection conformance

    func test_startAndEndIndex_matchInternalList() {
        sut.append(makeValidDateLocation())
        sut.append(makeValidDateLocation())
        XCTAssertEqual(sut.startIndex, 0)
        XCTAssertEqual(sut.endIndex, 2)
    }

    func test_subscript_returnsCorrectElement() {
        let dl = makeValidDateLocation()
        sut.append(dl)
        XCTAssertEqual(sut[0].id, dl.id)
    }

    func test_count_reflectsAppendedItems() {
        XCTAssertEqual(sut.lst.count, 0)
        sut.append(makeValidDateLocation())
        XCTAssertEqual(sut.lst.count, 1)
    }
}

// MARK: - ExtraArgsHolder Tests (activity switching)

final class ExtraArgsHolderTests: XCTestCase {

    var sut: ExtraArgsHolder!

    override func setUp() {
        super.setUp()
        sut = ExtraArgsHolder()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func test_defaultActivity_isRunning() {
        XCTAssertEqual(sut.selectedActivity, .running)
        XCTAssertTrue(sut.extraArgs is ExtraArgsHolderRunning)
    }

    func test_switchToCycling_updatesExtraArgs() {
        sut.selectedActivity = .cycling
        sut.updateExtraArgs()
        XCTAssertTrue(sut.extraArgs is ExtraArgsHolderCycling)
    }

    func test_switchToGym_updatesExtraArgs() {
        sut.selectedActivity = .gym
        sut.updateExtraArgs()
        XCTAssertTrue(sut.extraArgs is ExtraArgsHolderGym)
    }

    func test_switchToSkiing_updatesExtraArgs() {
        sut.selectedActivity = .skiing
        sut.updateExtraArgs()
        XCTAssertTrue(sut.extraArgs is ExtraArgsHolderSkiing)
    }

    func test_switchToSwimming_updatesExtraArgs() {
        sut.selectedActivity = .swimming
        sut.updateExtraArgs()
        XCTAssertTrue(sut.extraArgs is ExtraArgsHolderSwimming)
    }

    func test_switchToHiking_updatesExtraArgs() {
        sut.selectedActivity = .hiking
        sut.updateExtraArgs()
        XCTAssertTrue(sut.extraArgs is ExtraArgsHolderHiking)
    }

    func test_switchToYoga_updatesExtraArgs() {
        sut.selectedActivity = .yoga
        sut.updateExtraArgs()
        XCTAssertTrue(sut.extraArgs is ExtraArgsHolderYoga)
    }

    func test_switchToTennis_updatesExtraArgs() {
        sut.selectedActivity = .tennis
        sut.updateExtraArgs()
        XCTAssertTrue(sut.extraArgs is ExtraArgsHolderTennis)
    }

    func test_areFieldsValid_delegatesToExtraArgs() {
        // Running with positive defaults → valid
        sut.selectedActivity = .running
        sut.updateExtraArgs()
        XCTAssertTrue(sut.areFieldsValid())
    }
}

// MARK: - Sport-Specific ExtraArgs Validation Tests

final class ExtraArgsHolderRunningTests: XCTestCase {

    func test_defaultValues_areValid() {
        let sut = ExtraArgsHolderRunning()
        XCTAssertTrue(sut.areFieldsValid())
    }

    func test_zeroDistance_isInvalid() {
        let sut = ExtraArgsHolderRunning()
        sut.proposedDistance = 0
        XCTAssertFalse(sut.areFieldsValid())
    }

    func test_negativePace_isInvalid() {
        let sut = ExtraArgsHolderRunning()
        sut.proposedPace = -1
        XCTAssertFalse(sut.areFieldsValid())
    }

    func test_zeroPace_isInvalid() {
        let sut = ExtraArgsHolderRunning()
        sut.proposedPace = 0
        XCTAssertFalse(sut.areFieldsValid())
    }

    func test_activityType_isRunning() {
        let sut = ExtraArgsHolderRunning()
        XCTAssertEqual(sut.activityType, ActivityType.running.rawValue)
    }

    func test_encoding_containsExpectedKeys() throws {
        let sut = ExtraArgsHolderRunning()
        let data = try JSONEncoder().encode(sut)
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]
        XCTAssertNotNil(json["activityType"])
        XCTAssertNotNil(json["proposedDistance"])
        XCTAssertNotNil(json["proposedPace"])
        XCTAssertNotNil(json["proposedRunningType"])
    }
}

final class ExtraArgsHolderCyclingTests: XCTestCase {

    func test_defaultValues_areValid() {
        XCTAssertTrue(ExtraArgsHolderCycling().areFieldsValid())
    }

    func test_zeroPower_isInvalid() {
        let sut = ExtraArgsHolderCycling()
        sut.proposedPowerInWatt = 0
        XCTAssertFalse(sut.areFieldsValid())
    }

    func test_zeroCadence_isInvalid() {
        let sut = ExtraArgsHolderCycling()
        sut.proposedCadenceInRPM = 0
        XCTAssertFalse(sut.areFieldsValid())
    }

    func test_activityType_isCycling() {
        XCTAssertEqual(ExtraArgsHolderCycling().activityType, ActivityType.cycling.rawValue)
    }
}

final class ExtraArgsHolderGymTests: XCTestCase {

    func test_areFieldsValid_alwaysTrue() {
        XCTAssertTrue(ExtraArgsHolderGym().areFieldsValid())
    }

    func test_activityType_isGym() {
        XCTAssertEqual(ExtraArgsHolderGym().activityType, ActivityType.gym.rawValue)
    }
}

final class ExtraArgsHolderSkiingTests: XCTestCase {

    func test_defaultValues_areValid() {
        XCTAssertTrue(ExtraArgsHolderSkiing().areFieldsValid())
    }

    func test_zeroSpeed_isInvalid() {
        let sut = ExtraArgsHolderSkiing()
        sut.proposedSpeedInKmH = 0
        XCTAssertFalse(sut.areFieldsValid())
    }

    func test_zeroVerticalDrop_isInvalid() {
        let sut = ExtraArgsHolderSkiing()
        sut.proposedVerticalDropInM = 0
        XCTAssertFalse(sut.areFieldsValid())
    }
}

final class ExtraArgsHolderSwimmingTests: XCTestCase {

    func test_defaultValues_areValid() {
        XCTAssertTrue(ExtraArgsHolderSwimming().areFieldsValid())
    }

    func test_zeroDistance_isInvalid() {
        let sut = ExtraArgsHolderSwimming()
        sut.proposedDistanceInM = 0
        XCTAssertFalse(sut.areFieldsValid())
    }

    func test_zeroPace_isInvalid() {
        let sut = ExtraArgsHolderSwimming()
        sut.proposedPacePer100M = 0
        XCTAssertFalse(sut.areFieldsValid())
    }

    func test_activityType_isSwimming() {
        XCTAssertEqual(ExtraArgsHolderSwimming().activityType, ActivityType.swimming.rawValue)
    }
}

final class ExtraArgsHolderHikingTests: XCTestCase {

    func test_defaultValues_areValid() {
        XCTAssertTrue(ExtraArgsHolderHiking().areFieldsValid())
    }

    func test_zeroDistance_isInvalid() {
        let sut = ExtraArgsHolderHiking()
        sut.proposedDistanceInKm = 0
        XCTAssertFalse(sut.areFieldsValid())
    }

    func test_zeroElevation_isValid() {
        // elevation >= 0 is acceptable (flat hike)
        let sut = ExtraArgsHolderHiking()
        sut.proposedElevationGainInM = 0
        XCTAssertTrue(sut.areFieldsValid())
    }

    func test_negativeDistance_isInvalid() {
        let sut = ExtraArgsHolderHiking()
        sut.proposedDistanceInKm = -1
        XCTAssertFalse(sut.areFieldsValid())
    }
}

final class ExtraArgsHolderYogaTests: XCTestCase {

    func test_defaultValues_areValid() {
        XCTAssertTrue(ExtraArgsHolderYoga().areFieldsValid())
    }

    func test_zeroDuration_isInvalid() {
        let sut = ExtraArgsHolderYoga()
        sut.proposedDurationInMin = 0
        XCTAssertFalse(sut.areFieldsValid())
    }

    func test_intensityBelowOne_isInvalid() {
        let sut = ExtraArgsHolderYoga()
        sut.proposedIntensityLevel = 0
        XCTAssertFalse(sut.areFieldsValid())
    }

    func test_intensityAboveTen_isInvalid() {
        let sut = ExtraArgsHolderYoga()
        sut.proposedIntensityLevel = 11
        XCTAssertFalse(sut.areFieldsValid())
    }

    func test_intensityAtBoundaries_areValid() {
        let sut = ExtraArgsHolderYoga()
        sut.proposedIntensityLevel = 1
        XCTAssertTrue(sut.areFieldsValid())
        sut.proposedIntensityLevel = 10
        XCTAssertTrue(sut.areFieldsValid())
    }
}

final class ExtraArgsHolderTennisTests: XCTestCase {

    func test_defaultValues_areValid() {
        XCTAssertTrue(ExtraArgsHolderTennis().areFieldsValid())
    }

    func test_zeroSets_isInvalid() {
        let sut = ExtraArgsHolderTennis()
        sut.proposedSets = 0
        XCTAssertFalse(sut.areFieldsValid())
    }

    func test_fourSets_isInvalid() {
        let sut = ExtraArgsHolderTennis()
        sut.proposedSets = 4
        XCTAssertFalse(sut.areFieldsValid())
    }

    func test_zeroDuration_isInvalid() {
        let sut = ExtraArgsHolderTennis()
        sut.proposedDurationInMin = 0
        XCTAssertFalse(sut.areFieldsValid())
    }

    func test_setsAtLowerBound_isValid() {
        let sut = ExtraArgsHolderTennis()
        sut.proposedSets = 1
        XCTAssertTrue(sut.areFieldsValid())
    }

    func test_setsAtUpperBound_isValid() {
        let sut = ExtraArgsHolderTennis()
        sut.proposedSets = 3
        XCTAssertTrue(sut.areFieldsValid())
    }
}

// MARK: - NewEventBuilder Validation Tests

final class NewEventBuilderValidationTests: XCTestCase {

    // Since NewEventBuilder reads from ProfileManager on init, we test
    // areFieldsValid() by seeding all required fields manually after init.

    private func makeValidBuilder() -> NewEventBuilder {
        let builder = NewEventBuilder()
        builder.coverImgURL = "https://example.com/image.png"
        builder.title = "Morning Run"
        builder.description = "A fun 5K run in the park"
        builder.eventCapacity = 50
        // activityExtraArgs defaults to running with positive values → valid
        builder.dateLocationsHolder.append(makeValidDateLocation())
        return builder
    }

    func test_allFieldsValid_returnsTrue() {
        let builder = makeValidBuilder()
        XCTAssertTrue(builder.areFieldsValid())
    }

    func test_emptyTitle_returnsFalse() {
        let builder = makeValidBuilder()
        builder.title = ""
        XCTAssertFalse(builder.areFieldsValid())
    }

    func test_emptyDescription_returnsFalse() {
        let builder = makeValidBuilder()
        builder.description = ""
        XCTAssertFalse(builder.areFieldsValid())
    }

    func test_emptyCoverImage_returnsFalse() {
        let builder = makeValidBuilder()
        builder.coverImgURL = ""
        XCTAssertFalse(builder.areFieldsValid())
    }

    func test_zeroCapacity_returnsFalse() {
        let builder = makeValidBuilder()
        builder.eventCapacity = 0
        XCTAssertFalse(builder.areFieldsValid())
    }

    func test_negativeCapacity_returnsFalse() {
        let builder = makeValidBuilder()
        builder.eventCapacity = -5
        XCTAssertFalse(builder.areFieldsValid())
    }

    func test_noDateLocations_returnsFalse() {
        let builder = makeValidBuilder()
        builder.dateLocationsHolder = MultipleDateLocationsHolder()
        XCTAssertFalse(builder.areFieldsValid())
    }

    func test_invalidExtraArgs_returnsFalse() {
        let builder = makeValidBuilder()
        // Force invalid running args
        let runningArgs = builder.activityExtraArgs.extraArgs as! ExtraArgsHolderRunning
        runningArgs.proposedDistance = 0
        XCTAssertFalse(builder.areFieldsValid())
    }

    func test_capacityOfOne_returnsTrue() {
        let builder = makeValidBuilder()
        builder.eventCapacity = 1
        XCTAssertTrue(builder.areFieldsValid())
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

    // MARK: Step navigation

    func test_initialStep_isStep1() {
        XCTAssertEqual(sut.currentStep, .step1)
    }

    func test_moveToStep2_changesStep() {
        sut.moveToStep2()
        XCTAssertEqual(sut.currentStep, .step2)
    }

    func test_moveToStep1_fromStep2_returnsToStep1() {
        sut.moveToStep2()
        sut.moveToStep1()
        XCTAssertEqual(sut.currentStep, .step1)
    }

    func test_initialIsDismissed_isFalse() {
        XCTAssertFalse(sut.isDismissed)
    }

    func test_initialIsLoading_isFalse() {
        XCTAssertFalse(sut.isLoading)
    }

    // MARK: createEvent with invalid fields

    func test_createEvent_withInvalidFields_doesNotDismiss() {
        // Builder has empty title/description by default → invalid
        sut.newEventBuilder.title = ""
        sut.createEvent()
        // isDismissed must remain false; no network call should be made
        XCTAssertFalse(sut.isDismissed)
    }

    func test_createEvent_withInvalidFields_doesNotSetLoading() {
        sut.newEventBuilder.title = ""
        sut.createEvent()
        // isLoading should stay false (no async task started for invalid input)
        XCTAssertFalse(sut.isLoading)
    }



// MARK: - Testable subclass / mock seam

/// Subclass that overrides the async send so we don't hit the real network.
@Observable
final class ViewModelCoordinatorAddNewEventMockable: ViewModelCoordinatorAddNewEvent {

    var mockSuccess = true

    func seedValidBuilder() {
        newEventBuilder.coverImgURL = "https://example.com/img.png"
        newEventBuilder.title = "Test Event"
        newEventBuilder.description = "A great test event"
        newEventBuilder.eventCapacity = 20
        newEventBuilder.dateLocationsHolder.append(makeValidDateLocation())
    }

    override func createEvent() {
        if !newEventBuilder.areFieldsValid() {
            newEventBuilder.generateErrorMsg()
            return
        }
        Task {
            isLoading = true
            // Simulate async network work
            try? await Task.sleep(nanoseconds: 10_000_000)
            if mockSuccess {
                isDismissed = true
            }
            isLoading = false
        }
    }
}

// MARK: - CreateNewEventRequest Encoding Tests

final class CreateNewEventRequestEncodingTests: XCTestCase {

    func makeRequest() -> CreateNewEventRequest {
        let dl = makeValidDateLocation()
        return CreateNewEventRequest(
            activityDetails: ExtraArgsHolderRunning(),
            title: "Morning Run",
            eventImage: "https://example.com/img.png",
            isPublic: true,
            joiningCondition: .requestFromHost,
            maxAllowedToJoin: 50,
            notes: "Come ready to sweat",
            dateLocations: [dl]
        )
    }

    func test_encoding_doesNotThrow() {
        let request = makeRequest()
        XCTAssertNoThrow(try JSONEncoder().encode(request))
    }

    func test_encoding_containsTitle() throws {
        let data = try JSONEncoder().encode(makeRequest())
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]
        XCTAssertEqual(json["title"] as? String, "Morning Run")
    }

    func test_encoding_containsIsPublic() throws {
        let data = try JSONEncoder().encode(makeRequest())
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]
        XCTAssertEqual(json["isPublic"] as? Bool, true)
    }

    func test_encoding_containsJoiningCondition() throws {
        let data = try JSONEncoder().encode(makeRequest())
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]
        XCTAssertEqual(json["joiningCondition"] as? String, "requestFromHost")
    }

    func test_encoding_containsMaxAllowedToJoin() throws {
        let data = try JSONEncoder().encode(makeRequest())
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]
        XCTAssertEqual(json["maxAllowedToJoin"] as? Int, 50)
    }

    func test_encoding_dateLocations_areISO8601() throws {
        let data = try JSONEncoder().encode(makeRequest())
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]
        let dateLocations = json["dateLocations"] as? [[String: Any]]
        XCTAssertNotNil(dateLocations)
        XCTAssertFalse(dateLocations!.isEmpty)
        let first = dateLocations!.first!
        XCTAssertNotNil(first["startDateTime"] as? String)
        XCTAssertNotNil(first["endDateTime"] as? String)
    }

    func test_autoJoin_encodesCorrectly() throws {
        var request = makeRequest()
        // Can't mutate let, so build a new one
        let request2 = CreateNewEventRequest(
            activityDetails: ExtraArgsHolderRunning(),
            title: "Test",
            eventImage: "img",
            isPublic: false,
            joiningCondition: .autoJoin,
            maxAllowedToJoin: 10,
            notes: "",
            dateLocations: []
        )
        let data = try JSONEncoder().encode(request2)
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]
        XCTAssertEqual(json["joiningCondition"] as? String, "autoJoin")
    }
}

// MARK: - DateLocations Encoding Tests

final class DateLocationsEncodingTests: XCTestCase {

    func test_encoding_startDateIsISO8601String() throws {
        let dl = makeValidDateLocation()
        let data = try JSONEncoder().encode(dl)
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]
        let startStr = json["startDateTime"] as? String
        XCTAssertNotNil(startStr)
        // ISO8601 strings contain a 'T'
        XCTAssertTrue(startStr!.contains("T"))
    }

    func test_encoding_endDateIsISO8601String() throws {
        let dl = makeValidDateLocation()
        let data = try JSONEncoder().encode(dl)
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]
        let endStr = json["endDateTime"] as? String
        XCTAssertNotNil(endStr)
        XCTAssertTrue(endStr!.contains("T"))
    }

    func test_encoding_containsLocations() throws {
        let dl = makeValidDateLocation()
        let data = try JSONEncoder().encode(dl)
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]
        XCTAssertNotNil(json["locations"])
    }

    func test_uniqueIDs_forDifferentInstances() {
        let dl1 = makeValidDateLocation()
        let dl2 = makeValidDateLocation()
        XCTAssertNotEqual(dl1.id, dl2.id)
    }
}

// MARK: - JoinCondition Tests

final class JoinConditionTests: XCTestCase {

    func test_allCases_count() {
        XCTAssertEqual(JoinCondition.allCases.count, 2)
    }

    func test_requestFromHost_rawValue() {
        XCTAssertEqual(JoinCondition.requestFromHost.rawValue, "Manual Approval by event hosts")
    }

    func test_autoJoin_rawValue() {
        XCTAssertEqual(JoinCondition.autoJoin.rawValue, "Auto join")
    }
}

// MARK: - GymDayType Tests

final class GymDayTypeTests: XCTestCase {

    func test_allCases_count() {
        XCTAssertEqual(GymDayType.allCases.count, 8)
    }

    func test_rawValues_areCorrect() {
        XCTAssertEqual(GymDayType.push.rawValue, "Push")
        XCTAssertEqual(GymDayType.pull.rawValue, "Pull")
        XCTAssertEqual(GymDayType.fullBody.rawValue, "Full Body")
    }
}

// MARK: - CreateNewEventResponse Decoding Tests

final class CreateNewEventResponseDecodingTests: XCTestCase {

    func test_decoding_validJSON() throws {
        let json = """
        {
          "eventId": "evt123",
          "flattenedEvents": [
            { "flattenedEventId": "fe1", "dateLocationId": "dl1" }
          ],
          "message": "Event created successfully"
        }
        """.data(using: .utf8)!

        let response = try JSONDecoder().decode(CreateNewEventResponse.self, from: json)
        XCTAssertEqual(response.eventId, "evt123")
        XCTAssertEqual(response.flattenedEvents.count, 1)
        XCTAssertEqual(response.flattenedEvents.first?.flattenedEventId, "fe1")
        XCTAssertEqual(response.flattenedEvents.first?.dateLocationId, "dl1")
        XCTAssertEqual(response.message, "Event created successfully")
    }

    func test_decoding_emptyFlattenedEvents() throws {
        let json = """
        { "eventId": "x", "flattenedEvents": [], "message": "ok" }
        """.data(using: .utf8)!
        let response = try JSONDecoder().decode(CreateNewEventResponse.self, from: json)
        XCTAssertTrue(response.flattenedEvents.isEmpty)
    }
}

// MARK: - AddNewEventSteps Tests

final class AddNewEventStepsTests: XCTestCase {

    func test_step1_andStep2_areDistinct() {
        XCTAssertNotEqual(AddNewEventSteps.step1, AddNewEventSteps.step2)
    }
}
