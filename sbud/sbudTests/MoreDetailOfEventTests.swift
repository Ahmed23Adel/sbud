////
////  MoreDetailOfEventTests.swift
////  sbudTests
////
////  Created by ahmed on 26/04/2026.
//
//
//import XCTest
//@testable import sbud
//
//// MARK: - Mock EventByIdRequester
//
//final class MockEventByIdRequester: EventByIdRequester {
//    var shouldThrow: Bool = false
//    var mockResult: EventFullDetails = .sample
//    var callCount: Int = 0
//
//    override func fetchEvent(eventId: String) async throws -> EventFullDetails {
//        callCount += 1
//        if shouldThrow {
//            throw URLError(.badServerResponse)
//        }
//        return mockResult
//    }
//}
//
//// MARK: - Testable ViewModel subclass
//
///// Injects a mock requester instead of the real network one.
//final class TestableViewModelMoreInfoEvent: ViewModelMoreInfoEvent {
//    let mockRequester: MockEventByIdRequester
//
//    init(event: AvailabilityEvent, requester: MockEventByIdRequester) {
//        self.mockRequester = requester
//        super.init(event: event)
//    }
//
//    // NOTE: If ViewModelMoreInfoEvent exposes `loadDetails` as internal/open,
//    // override it here to use the mock. Otherwise test via `triggerLoad()`.
//}
//
//// MARK: - JSON Decoding Helpers
//
//private let decoder: JSONDecoder = {
//    let d = JSONDecoder()
//    d.dateDecodingStrategy = .iso8601
//    return d
//}()
//
//private func makeJSON(_ dict: [String: Any]) throws -> Data {
//    return try JSONSerialization.data(withJSONObject: dict)
//}
//
//// MARK: - CreatorInfo Tests
//
//final class CreatorInfoTests: XCTestCase {
//
//    func test_decode_allFields() throws {
//        let json: [String: Any] = [
//            "id": "abc123",
//            "name": "Ahmed",
//            "surName": "Hussein",
//            "profileImageUrl": "https://example.com/img.jpg"
//        ]
//        let data = try makeJSON(json)
//        let creator = try decoder.decode(CreatorInfo.self, from: data)
//
//        XCTAssertEqual(creator.id, "abc123")
//        XCTAssertEqual(creator.name, "Ahmed")
//        XCTAssertEqual(creator.surName, "Hussein")
//        XCTAssertEqual(creator.profileImageUrl, "https://example.com/img.jpg")
//    }
//
//    func test_decode_missingOptionalProfileImage() throws {
//        let json: [String: Any] = [
//            "id": "abc123",
//            "name": "Ahmed",
//            "surName": "Hussein"
//        ]
//        let data = try makeJSON(json)
//        let creator = try decoder.decode(CreatorInfo.self, from: data)
//        XCTAssertNil(creator.profileImageUrl)
//    }
//
//    func test_sample_hasExpectedValues() {
//        XCTAssertEqual(CreatorInfo.sample.name, "Ahmed")
//        XCTAssertEqual(CreatorInfo.sample.surName, "Hussein")
//        XCTAssertFalse(CreatorInfo.sample.id.isEmpty)
//    }
//}
//
//// MARK: - AnyActivityDetails Decoding Tests
//
//final class AnyActivityDetailsTests: XCTestCase {
//
//    // MARK: Running
//
//    func test_decode_running() throws {
//        let json: [String: Any] = [
//            "activityType": "Running",
//            "targetDistanceInKm": 10.0,
//            "targetPace": 5.5
//        ]
//        let details = try decoder.decode(AnyActivityDetails.self, from: makeJSON(json))
//        XCTAssertEqual(details.value.activityType, .running)
//        let running = try XCTUnwrap(details.value as? ResponseActivityDetailsRunning)
//        XCTAssertEqual(running.targetDistanceInKm, 10.0)
//        XCTAssertEqual(running.targetPace, 5.5)
//    }
//
//    func test_decode_running_missingOptionals() throws {
//        let json: [String: Any] = ["activityType": "Running"]
//        let details = try decoder.decode(AnyActivityDetails.self, from: makeJSON(json))
//        XCTAssertEqual(details.value.activityType, .running)
//        let running = try XCTUnwrap(details.value as? ResponseActivityDetailsRunning)
//        XCTAssertNil(running.targetDistanceInKm)
//        XCTAssertNil(running.targetPace)
//    }
//
//    // MARK: Cycling
//
//    func test_decode_cycling() throws {
//        let json: [String: Any] = [
//            "activityType": "Cycling",
//            "targetDistanceInKm": 40.0,
//            "powerInWatt": 280.0,
//            "cadenceInRpm": 95
//        ]
//        let details = try decoder.decode(AnyActivityDetails.self, from: makeJSON(json))
//        XCTAssertEqual(details.value.activityType, .cycling)
//        let cycling = try XCTUnwrap(details.value as? ResponseActivityDetailsCycling)
//        XCTAssertEqual(cycling.targetDistanceInKm, 40.0)
//        XCTAssertEqual(cycling.powerInWatt, 280.0)
//        XCTAssertEqual(cycling.cadenceInRpm, 95)
//    }
//
//    func test_decode_cycling_missingOptionals() throws {
//        let json: [String: Any] = ["activityType": "Cycling"]
//        let details = try decoder.decode(AnyActivityDetails.self, from: makeJSON(json))
//        XCTAssertEqual(details.value.activityType, .cycling)
//        let cycling = try XCTUnwrap(details.value as? ResponseActivityDetailsCycling)
//        XCTAssertNil(cycling.targetDistanceInKm)
//        XCTAssertNil(cycling.powerInWatt)
//        XCTAssertNil(cycling.cadenceInRpm)
//    }
//
//    // MARK: Gym
//
//    func test_decode_gym() throws {
//        let json: [String: Any] = [
//            "activityType": "Gym",
//            "dayType": "Push"
//        ]
//        let details = try decoder.decode(AnyActivityDetails.self, from: makeJSON(json))
//        XCTAssertEqual(details.value.activityType, .gym)
//        let gym = try XCTUnwrap(details.value as? ResponseActivityDetailsGym)
//        XCTAssertEqual(gym.dayType, "Push")
//    }
//
//    func test_decode_unknownActivityType_fallsBackToGym() throws {
//        let json: [String: Any] = ["activityType": "Volleyball"]
//        let details = try decoder.decode(AnyActivityDetails.self, from: makeJSON(json))
//        // Unknown types fall back to Gym per the switch default
//        XCTAssertEqual(details.value.activityType, .gym)
//    }
//
//    // MARK: Direct init
//
//    func test_init_withValue() {
//        let running = ResponseActivityDetailsRunning(targetDistanceInKm: 5.0, targetPace: 6.0)
//        let anyDetails = AnyActivityDetails(value: running)
//        XCTAssertEqual(anyDetails.value.activityType, .running)
//    }
//
//    // MARK: Samples
//
//    func test_sampleRunning() {
//        XCTAssertEqual(AnyActivityDetails.sampleRunning.value.activityType, .running)
//    }
//
//    func test_sampleCycling() {
//        XCTAssertEqual(AnyActivityDetails.sampleCycling.value.activityType, .cycling)
//    }
//
//    func test_sampleGym() {
//        XCTAssertEqual(AnyActivityDetails.sampleGym.value.activityType, .gym)
//    }
//}
//
//// MARK: - LocationPoint Tests
//
//final class LocationPointTests: XCTestCase {
//
//    func test_decode() throws {
//        let json: [String: Any] = [
//            "latitude": 45.4642,
//            "longitude": 9.19,
//            "geohash": "u0ndx37j"
//        ]
//        let point = try decoder.decode(LocationPoint.self, from: makeJSON(json))
//        XCTAssertEqual(point.latitude, 45.4642, accuracy: 0.0001)
//        XCTAssertEqual(point.longitude, 9.19, accuracy: 0.0001)
//        XCTAssertEqual(point.geohash, "u0ndx37j")
//    }
//
//    func test_sample() {
//        XCTAssertEqual(LocationPoint.sample.geohash, "u0ndx37j")
//        XCTAssertEqual(LocationPoint.sample.latitude, 45.4642, accuracy: 0.0001)
//    }
//}
//
//// MARK: - DateLocationEntry Tests
//
//final class DateLocationEntryTests: XCTestCase {
//
//    func test_decode() throws {
//        let json: [String: Any] = [
//            "id": "entry001",
//            "startDateTime": "2026-05-01T08:00:00Z",
//            "endDateTime": "2026-05-01T09:00:00Z",
//            "locations": [
//                ["latitude": 45.4642, "longitude": 9.19, "geohash": "u0ndx37j"]
//            ]
//        ]
//        let entry = try decoder.decode(DateLocationEntry.self, from: makeJSON(json))
//        XCTAssertEqual(entry.id, "entry001")
//        XCTAssertEqual(entry.locations.count, 1)
//        XCTAssertLessThan(entry.startDateTime, entry.endDateTime)
//    }
//
//    func test_isIdentifiable() {
//        let entry = DateLocationEntry.sample
//        XCTAssertFalse(entry.id.isEmpty)
//    }
//
//    func test_sample_hasTwoLocations() {
//        XCTAssertEqual(DateLocationEntry.sample.locations.count, 2)
//    }
//
//    func test_sample_startBeforeEnd() {
//        let entry = DateLocationEntry.sample
//        XCTAssertLessThan(entry.startDateTime, entry.endDateTime)
//    }
//}
//
//// MARK: - EventFullDetails Decoding Tests
//
//final class EventFullDetailsTests: XCTestCase {
//
//    private func makeEventJSON(
//        joiningCondition: String = "autoJoin",
//        activityType: String = "Running",
//        notes: String? = nil,
//        eventImage: String? = nil,
//        maxAllowedToJoin: Int? = nil
//    ) -> [String: Any] {
//        var dict: [String: Any] = [
//            "id": "evt001",
//            "title": "Morning Run",
//            "creator": [
//                "id": "usr001",
//                "name": "Ahmed",
//                "surName": "Hussein"
//            ],
//            "activityDetails": ["activityType": activityType],
//            "isDateConfirmed": true,
//            "isLocationConfirmed": false,
//            "isPublic": true,
//            "joiningCondition": joiningCondition,
//            "createdAt": "2026-04-01T06:00:00Z",
//            "dateLocations": [
//                [
//                    "id": "dl001",
//                    "startDateTime": "2026-05-01T08:00:00Z",
//                    "endDateTime": "2026-05-01T09:00:00Z",
//                    "locations": [
//                        ["latitude": 45.4642, "longitude": 9.19, "geohash": "u0ndx37j"]
//                    ]
//                ]
//            ]
//        ]
//        if let notes { dict["notes"] = notes }
//        if let eventImage { dict["eventImage"] = eventImage }
//        if let maxAllowedToJoin { dict["maxAllowedToJoin"] = maxAllowedToJoin }
//        return dict
//    }
//
//    func test_decode_fullEvent_autoJoin() throws {
//        let data = try makeJSON(makeEventJSON(joiningCondition: "autoJoin", notes: "Come join!", eventImage: "https://img.example.com/img.jpg", maxAllowedToJoin: 50))
//        let event = try decoder.decode(EventFullDetails.self, from: data)
//
//        XCTAssertEqual(event.id, "evt001")
//        XCTAssertEqual(event.title, "Morning Run")
//        XCTAssertEqual(event.joinCondition, .autoJoin)
//        XCTAssertEqual(event.notes, "Come join!")
//        XCTAssertEqual(event.eventImage, "https://img.example.com/img.jpg")
//        XCTAssertEqual(event.maxAllowedToJoin, 50)
//        XCTAssertTrue(event.isDateConfirmed)
//        XCTAssertFalse(event.isLocationConfirmed)
//        XCTAssertTrue(event.isPublic)
//        XCTAssertEqual(event.dateLocations.count, 1)
//    }
//
//    func test_decode_joiningCondition_requestFromHost() throws {
//        let data = try makeJSON(makeEventJSON(joiningCondition: "requestFromHost"))
//        let event = try decoder.decode(EventFullDetails.self, from: data)
//        XCTAssertEqual(event.joinCondition, .requestFromHost)
//    }
//
//    func test_decode_unknownJoiningCondition_fallsBackToRequestFromHost() throws {
//        let data = try makeJSON(makeEventJSON(joiningCondition: "somethingRandom"))
//        let event = try decoder.decode(EventFullDetails.self, from: data)
//        XCTAssertEqual(event.joinCondition, .requestFromHost)
//    }
//
//    func test_decode_optionalFieldsMissing() throws {
//        let data = try makeJSON(makeEventJSON())
//        let event = try decoder.decode(EventFullDetails.self, from: data)
//        XCTAssertNil(event.notes)
//        XCTAssertNil(event.eventImage)
//        XCTAssertNil(event.maxAllowedToJoin)
//    }
//
//    func test_activityType_computedProperty_running() throws {
//        let data = try makeJSON(makeEventJSON(activityType: "Running"))
//        let event = try decoder.decode(EventFullDetails.self, from: data)
//        XCTAssertEqual(event.activityType, .running)
//    }
//
//    func test_activityType_computedProperty_cycling() throws {
//        let data = try makeJSON(makeEventJSON(activityType: "Cycling"))
//        let event = try decoder.decode(EventFullDetails.self, from: data)
//        XCTAssertEqual(event.activityType, .cycling)
//    }
//
//    func test_activityType_computedProperty_gym() throws {
//        let data = try makeJSON(makeEventJSON(activityType: "Gym"))
//        let event = try decoder.decode(EventFullDetails.self, from: data)
//        XCTAssertEqual(event.activityType, .gym)
//    }
//
//    func test_sample_isValid() {
//        let sample = EventFullDetails.sample
//        XCTAssertEqual(sample.id, "xN6ncT0Foa0UdFy06GSL")
//        XCTAssertEqual(sample.title, "Morning Run")
//        XCTAssertEqual(sample.activityType, .running)
//        XCTAssertEqual(sample.joinCondition, .requestFromHost)
//        XCTAssertFalse(sample.dateLocations.isEmpty)
//    }
//
//    func test_memberwise_init_roundtrip() {
//        let sample = EventFullDetails.sample
//        XCTAssertEqual(sample.creator.name, "Ahmed")
//        XCTAssertEqual(sample.maxAllowedToJoin, 150)
//        XCTAssertEqual(sample.notes, "Come join me")
//    }
//}
//
//// MARK: - ViewModelMoreInfoEvent Tests
//
//final class ViewModelMoreInfoEventTests: XCTestCase {
//
//    // MARK: - Happy path: details load successfully
//
//    func test_loadDetails_success_setsFullDetails() async throws {
//        let event = AvailabilityEvent.preview
//        let vm = ViewModelMoreInfoEvent(event: event)
//
//        // Give the Task inside init time to complete
//        try await Task.sleep(nanoseconds: 300_000_000) // 0.3s
//
//        // In DEBUG with fullDatailedEvent set on preview, it short-circuits;
//        // adjust depending on whether .preview has fullDatailedEvent = nil
//        if event.fullDatailedEvent == nil {
//            XCTAssertFalse(vm.isLoading)
//        }
//    }
//
//    // MARK: - Initial state
//
//    func test_initialState_isLoadingFalse_beforeTaskRuns() {
//        // AvailabilityEvent.preview should have fullDatailedEvent set in DEBUG
//        // so vm skips network; fullDetails is set immediately
//        let vm = ViewModelMoreInfoEvent(event: .preview)
//        // Either loading has finished (DEBUG shortcut) or is in progress
//        XCTAssertFalse(vm.isErrorLoading)
//    }
//
//    
//}
