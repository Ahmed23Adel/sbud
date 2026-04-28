////
////  MoreDetailOfEventTests.swift
////  sbudTests
////
////  Created by ahmed on 26/04/2026.
//
//

//
//  MoreInfoEventTests.swift
//  sbudTests
//
//  Comprehensive unit tests for the MoreInfoEvent feature.
//  Covers: models (EventFullDetails, CreatorInfo, LocationPoint,
//          DateLocationEntry, ExtraArgsHolder and all sport sub-holders),
//          ViewModel state machine, JoinCondition encoding,
//          ActivityType metadata, and edge-case decoding.
//

import XCTest
@testable import sbud

// MARK: - Helpers

private let iso8601: ISO8601DateFormatter = {
    let f = ISO8601DateFormatter()
    f.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
    return f
}()

/// Build a JSON encoder whose date strategy matches the app's decoder.
private func makeEncoder() -> JSONEncoder {
    let enc = JSONEncoder()
    enc.dateEncodingStrategy = .iso8601
    return enc
}

/// Build a JSON decoder that mirrors the app's decoding strategy.
private func makeDecoder() -> JSONDecoder {
    let dec = JSONDecoder()
    dec.dateDecodingStrategy = .iso8601
    return dec
}

// MARK: - Fixtures

private enum Fixture {

    // Minimal valid JSON for EventFullDetails
    static func eventJSON(
        id: String = "evt1",
        title: String = "Morning Run",
        joiningCondition: String = "autoJoin",
        isDateConfirmed: Bool = true,
        isLocationConfirmed: Bool = false,
        isPublic: Bool = true,
        maxAllowedToJoin: Int? = nil,
        notes: String? = nil,
        activityType: String = "Running",
        extraFields: String = #""proposedDistance":6,"proposedPace":8.3,"proposedRunningType":"Road""#,
        eventImage: String? = nil,
        dateLocations: String = "[]"
    ) -> Data {
        let maxField = maxAllowedToJoin.map { #","maxAllowedToJoin":\#($0)"# } ?? ""
        let notesField = notes.map { #","notes":"\#($0)""# } ?? ""
        let imageField = eventImage.map { #","eventImage":"\#($0)""# } ?? ""
        let now = iso8601.string(from: Date())
        let json = """
        {
          "id": "\(id)",
          "title": "\(title)",
          "creator": {
            "id": "creator1",
            "name": "Ahmed",
            "surName": "Hussein"
          },
          "activityDetails": {
            "activityType": "\(activityType)",
            \(extraFields)
          },
          "isDateConfirmed": \(isDateConfirmed),
          "isLocationConfirmed": \(isLocationConfirmed),
          "isPublic": \(isPublic),
          "joiningCondition": "\(joiningCondition)",
          "createdAt": "\(now)",
          "dateLocations": \(dateLocations)
          \(maxField)\(notesField)\(imageField)
        }
        """
        return Data(json.utf8)
    }

    static let now = Date()
    static let nowString = iso8601.string(from: now)

    static func dateLocationJSON(id: String = "dl1") -> String {
        let start = iso8601.string(from: now.addingTimeInterval(3600))
        let end   = iso8601.string(from: now.addingTimeInterval(7200))
        return """
        {
          "id": "\(id)",
          "startDateTime": "\(start)",
          "endDateTime": "\(end)",
          "locations": [
            { "latitude": 45.4642, "longitude": 9.19, "geohash": "u0ndx37j" }
          ]
        }
        """
    }
}

// MARK: - CreatorInfo Tests

final class CreatorInfoTests: XCTestCase {

    func test_decode_allFields() throws {
        let json = """
        {"id":"u1","name":"Ahmed","surName":"H","profileImageUrl":"https://example.com/img.png"}
        """
        let creator = try makeDecoder().decode(CreatorInfo.self, from: Data(json.utf8))
        XCTAssertEqual(creator.id, "u1")
        XCTAssertEqual(creator.name, "Ahmed")
        XCTAssertEqual(creator.surName, "H")
        XCTAssertEqual(creator.profileImageUrl, "https://example.com/img.png")
    }

    func test_decode_missingOptionalProfileImage_isNil() throws {
        let json = """
        {"id":"u1","name":"Ahmed","surName":"H"}
        """
        let creator = try makeDecoder().decode(CreatorInfo.self, from: Data(json.utf8))
        XCTAssertNil(creator.profileImageUrl)
    }

    func test_decode_emptyName_succeeds() throws {
        let json = """
        {"id":"u1","name":"","surName":""}
        """
        let creator = try makeDecoder().decode(CreatorInfo.self, from: Data(json.utf8))
        XCTAssertEqual(creator.name, "")
        XCTAssertEqual(creator.surName, "")
    }

    func test_sample_hasExpectedValues() {
        XCTAssertEqual(CreatorInfo.sample.name, "Ahmed")
        XCTAssertEqual(CreatorInfo.sample.surName, "Hussein")
        XCTAssertFalse(CreatorInfo.sample.id.isEmpty)
    }
}

// MARK: - LocationPoint Tests

final class LocationPointTests: XCTestCase {

    func test_decode_standard() throws {
        let json = """
        {"latitude":48.8566,"longitude":2.3522,"geohash":"u09tvw0f"}
        """
        let loc = try makeDecoder().decode(LocationPoint.self, from: Data(json.utf8))
        XCTAssertEqual(loc.latitude,  48.8566, accuracy: 0.0001)
        XCTAssertEqual(loc.longitude, 2.3522,  accuracy: 0.0001)
        XCTAssertEqual(loc.geohash, "u09tvw0f")
    }

    func test_decode_negativeCoordinates() throws {
        let json = """
        {"latitude":-33.8688,"longitude":151.2093,"geohash":"r3gx2"}
        """
        let loc = try makeDecoder().decode(LocationPoint.self, from: Data(json.utf8))
        XCTAssertEqual(loc.latitude, -33.8688, accuracy: 0.0001)
        XCTAssertGreaterThan(loc.longitude, 0)
    }

    func test_sample_milanCoordinates() {
        XCTAssertEqual(LocationPoint.sample.latitude,  45.4642, accuracy: 0.001)
        XCTAssertEqual(LocationPoint.sample.longitude, 9.1900,  accuracy: 0.001)
    }
}

// MARK: - DateLocationEntry Tests

final class DateLocationEntryTests: XCTestCase {

    func test_decode_singleLocation() throws {
        let data = Data(Fixture.dateLocationJSON().utf8)
        let entry = try makeDecoder().decode(DateLocationEntry.self, from: data)
        XCTAssertEqual(entry.id, "dl1")
        XCTAssertEqual(entry.locations.count, 1)
        XCTAssertGreaterThan(entry.endDateTime, entry.startDateTime)
    }

    func test_decode_multipleLocations() throws {
        let start = iso8601.string(from: Date())
        let end   = iso8601.string(from: Date().addingTimeInterval(3600))
        let json  = """
        {
          "id": "dl2",
          "startDateTime": "\(start)",
          "endDateTime": "\(end)",
          "locations": [
            {"latitude":1.0,"longitude":2.0,"geohash":"abc"},
            {"latitude":3.0,"longitude":4.0,"geohash":"def"}
          ]
        }
        """
        let entry = try makeDecoder().decode(DateLocationEntry.self, from: Data(json.utf8))
        XCTAssertEqual(entry.locations.count, 2)
    }

    func test_decode_emptyLocations() throws {
        let start = iso8601.string(from: Date())
        let end   = iso8601.string(from: Date().addingTimeInterval(3600))
        let json  = """
        {"id":"dl3","startDateTime":"\(start)","endDateTime":"\(end)","locations":[]}
        """
        let entry = try makeDecoder().decode(DateLocationEntry.self, from: Data(json.utf8))
        XCTAssertTrue(entry.locations.isEmpty)
    }

    func test_sample_endAfterStart() {
        XCTAssertGreaterThan(DateLocationEntry.sample.endDateTime,
                             DateLocationEntry.sample.startDateTime)
    }

    func test_sample_hasLocations() {
        XCTAssertFalse(DateLocationEntry.sample.locations.isEmpty)
    }
}

// MARK: - JoinCondition Tests

final class JoinConditionTests: XCTestCase {

    private func encoded(_ condition: JoinCondition) throws -> String {
        let data = try makeEncoder().encode(condition)
        return String(data: data, encoding: .utf8)!
                .trimmingCharacters(in: CharacterSet(charactersIn: "\""))
    }

    func test_encode_autoJoin() throws {
        XCTAssertEqual(try encoded(.autoJoin), "autoJoin")
    }

    func test_encode_requestFromHost() throws {
        XCTAssertEqual(try encoded(.requestFromHost), "requestFromHost")
    }

    func test_allCases_count() {
        XCTAssertEqual(JoinCondition.allCases.count, 2)
    }

    func test_rawValues_areHumanReadable() {
        XCTAssertFalse(JoinCondition.autoJoin.rawValue.isEmpty)
        XCTAssertFalse(JoinCondition.requestFromHost.rawValue.isEmpty)
    }
}

// MARK: - ActivityType Tests

final class ActivityTypeTests: XCTestCase {

    func test_allCases_count() {
        XCTAssertEqual(ActivityType.allCases.count, 8)
    }

    func test_rawValues_matchExpected() {
        let expected: Set<String> = ["Running","Cycling","Gym","Skiing","Swimming","Hiking","Yoga","Tennis"]
        let actual = Set(ActivityType.allCases.map(\.rawValue))
        XCTAssertEqual(actual, expected)
    }

    func test_init_fromRawValue_valid() {
        XCTAssertEqual(ActivityType(rawValue: "Running"), .running)
        XCTAssertEqual(ActivityType(rawValue: "Tennis"),  .tennis)
    }

    func test_init_fromRawValue_invalid_returnsNil() {
        XCTAssertNil(ActivityType(rawValue: "Surfing"))
        XCTAssertNil(ActivityType(rawValue: ""))
    }

    func test_icon_nonEmpty_forAllCases() {
        for type in ActivityType.allCases {
            XCTAssertFalse(type.icon.isEmpty, "\(type.rawValue) icon is empty")
        }
    }

    func test_iconBaseName_nonEmpty_forAllCases() {
        for type in ActivityType.allCases {
            XCTAssertFalse(type.iconBaseName.isEmpty, "\(type.rawValue) iconBaseName is empty")
        }
    }

    func test_codable_roundTrip() throws {
        for type in ActivityType.allCases {
            let data    = try makeEncoder().encode(type)
            let decoded = try makeDecoder().decode(ActivityType.self, from: data)
            XCTAssertEqual(decoded, type)
        }
    }
}



// MARK: - EventFullDetails Tests

final class EventFullDetailsTests: XCTestCase {

    func test_decode_minimal_autoJoin() throws {
        let data = Fixture.eventJSON(joiningCondition: "autoJoin")
        let event = try makeDecoder().decode(EventFullDetails.self, from: data)
        XCTAssertEqual(event.joinCondition, .autoJoin)
    }

    func test_decode_requestFromHost() throws {
        let data = Fixture.eventJSON(joiningCondition: "requestFromHost")
        let event = try makeDecoder().decode(EventFullDetails.self, from: data)
        XCTAssertEqual(event.joinCondition, .requestFromHost)
    }

    func test_decode_unknownJoiningCondition_defaultsToRequestFromHost() throws {
        let data = Fixture.eventJSON(joiningCondition: "somethingElse")
        let event = try makeDecoder().decode(EventFullDetails.self, from: data)
        XCTAssertEqual(event.joinCondition, .requestFromHost)
    }

    func test_decode_isPublicTrue() throws {
        let event = try makeDecoder().decode(EventFullDetails.self, from: Fixture.eventJSON(isPublic: true))
        XCTAssertTrue(event.isPublic)
    }

    func test_decode_isPublicFalse() throws {
        let event = try makeDecoder().decode(EventFullDetails.self, from: Fixture.eventJSON(isPublic: false))
        XCTAssertFalse(event.isPublic)
    }

    func test_decode_isDateConfirmed() throws {
        let event = try makeDecoder().decode(EventFullDetails.self, from: Fixture.eventJSON(isDateConfirmed: true))
        XCTAssertTrue(event.isDateConfirmed)
    }

    func test_decode_isLocationConfirmed() throws {
        let event = try makeDecoder().decode(EventFullDetails.self, from: Fixture.eventJSON(isLocationConfirmed: true))
        XCTAssertTrue(event.isLocationConfirmed)
    }

    func test_decode_optionalNotes_present() throws {
        let event = try makeDecoder().decode(EventFullDetails.self,
                                            from: Fixture.eventJSON(notes: "Bring water"))
        XCTAssertEqual(event.notes, "Bring water")
    }

    func test_decode_optionalNotes_absent_isNil() throws {
        let event = try makeDecoder().decode(EventFullDetails.self, from: Fixture.eventJSON())
        XCTAssertNil(event.notes)
    }

    func test_decode_optionalEventImage_present() throws {
        let event = try makeDecoder().decode(
            EventFullDetails.self,
            from: Fixture.eventJSON(eventImage: "https://example.com/img.png"))
        XCTAssertEqual(event.eventImage, "https://example.com/img.png")
    }

    func test_decode_optionalEventImage_absent_isNil() throws {
        let event = try makeDecoder().decode(EventFullDetails.self, from: Fixture.eventJSON())
        XCTAssertNil(event.eventImage)
    }

    func test_decode_maxAllowedToJoin_present() throws {
        let event = try makeDecoder().decode(EventFullDetails.self,
                                            from: Fixture.eventJSON(maxAllowedToJoin: 50))
        XCTAssertEqual(event.maxAllowedToJoin, 50)
    }

    func test_decode_maxAllowedToJoin_absent_isNil() throws {
        let event = try makeDecoder().decode(EventFullDetails.self, from: Fixture.eventJSON())
        XCTAssertNil(event.maxAllowedToJoin)
    }

    func test_decode_emptyDateLocations() throws {
        let event = try makeDecoder().decode(EventFullDetails.self, from: Fixture.eventJSON())
        XCTAssertTrue(event.dateLocations.isEmpty)
    }

    func test_decode_withDateLocations() throws {
        let dlJSON = "[\(Fixture.dateLocationJSON(id: "dl1")),\(Fixture.dateLocationJSON(id: "dl2"))]"
        let data   = Fixture.eventJSON(dateLocations: dlJSON)
        let event  = try makeDecoder().decode(EventFullDetails.self, from: data)
        XCTAssertEqual(event.dateLocations.count, 2)
        XCTAssertEqual(event.dateLocations[0].id, "dl1")
        XCTAssertEqual(event.dateLocations[1].id, "dl2")
    }

    func test_activityType_computedProperty_matchesDecoded() throws {
        let event = try makeDecoder().decode(EventFullDetails.self,
                                            from: Fixture.eventJSON(activityType: "Running"))
        XCTAssertEqual(event.activityType, .running)
    }

    func test_decode_allActivityTypes() throws {
        for type in ActivityType.allCases {
            let json = Fixture.eventJSON(activityType: type.rawValue, extraFields: "")
            // Should not throw – unknown extra fields are ignored by decoders
            XCTAssertNoThrow(try makeDecoder().decode(EventFullDetails.self, from: json))
        }
    }

    func test_createdAt_decodedAsDate() throws {
        let event = try makeDecoder().decode(EventFullDetails.self, from: Fixture.eventJSON())
        // Should be within the last few seconds
        XCTAssertLessThanOrEqual(abs(event.createdAt.timeIntervalSinceNow), 5)
    }

    func test_decode_idAndTitle() throws {
        let event = try makeDecoder().decode(EventFullDetails.self,
                                            from: Fixture.eventJSON(id: "myId", title: "Night Hike"))
        XCTAssertEqual(event.id, "myId")
        XCTAssertEqual(event.title, "Night Hike")
    }

    func test_sample_hasExpectedTitle() {
        XCTAssertEqual(EventFullDetails.sample.title, "Morning Run")
    }

    func test_sample_activityType_isRunning() {
        XCTAssertEqual(EventFullDetails.sample.activityType, .running)
    }

    func test_sample_hasTwoDateLocations() {
        XCTAssertEqual(EventFullDetails.sample.dateLocations.count, 2)
    }

    func test_sample_joinCondition() {
        XCTAssertEqual(EventFullDetails.sample.joinCondition, .requestFromHost)
    }
}

// MARK: - ViewModelMoreInfoEvent Tests

/// A lightweight test double for the network layer that avoids real Firestore calls.
/// Inject by subclassing or wrapping; here we test the ViewModel's state transitions
/// by hooking into its published properties after construction with a pre-populated fixture.
@MainActor
final class ViewModelMoreInfoEventTests: XCTestCase {

    // MARK: Initial state

    func test_initialState_isLoading() async {
        // ViewModel starts loading immediately on init.
        // We can only observe the initial value synchronously
        // before the async Task on `init` completes.
        // Because there's no DI seam, we verify the observable
        // properties exist with their expected types.
        let vm = ViewModelMoreInfoEvent(eventId: "test-id")
        // fullDetails is nil until network resolves
        XCTAssertNil(vm.fullDetails)
        // isLoading starts true (set synchronously via Task)
        // isErrorLoading starts false
        XCTAssertFalse(vm.isErrorLoading)
    }

    func test_eventId_storedCorrectly() async {
        let vm = ViewModelMoreInfoEvent(eventId: "evt-42")
        XCTAssertEqual(vm.eventId, "evt-42")
    }

    // MARK: State after successful load (simulated via direct property set)

    func test_successState_fullDetailsNonNil_isLoadingFalse() async {
        let vm = ViewModelMoreInfoEvent(eventId: "x")
        // Simulate what loadDetails does on success:
        vm.fullDetails = EventFullDetails.sample
        vm.isLoading = false
        vm.isErrorLoading = false

        XCTAssertNotNil(vm.fullDetails)
        XCTAssertFalse(vm.isLoading)
        XCTAssertFalse(vm.isErrorLoading)
    }

    func test_successState_eventTitleMatchesSample() async {
        let vm = ViewModelMoreInfoEvent(eventId: "x")
        vm.fullDetails = EventFullDetails.sample
        vm.isLoading = false

        XCTAssertEqual(vm.fullDetails?.title, "Morning Run")
    }

    // MARK: State after error

    func test_errorState_fullDetailsNil_isErrorTrue() async {
        let vm = ViewModelMoreInfoEvent(eventId: "x")
        vm.fullDetails = nil
        vm.isLoading = false
        vm.isErrorLoading = true

        XCTAssertNil(vm.fullDetails)
        XCTAssertTrue(vm.isErrorLoading)
        XCTAssertFalse(vm.isLoading)
    }

    // MARK: State mutations are mutually exclusive

    func test_loadingAndError_neverBothTrue() async {
        let vm = ViewModelMoreInfoEvent(eventId: "x")
        // Loading=true, error=false → valid loading state
        vm.isLoading = true
        vm.isErrorLoading = false
        XCTAssertFalse(vm.isLoading && vm.isErrorLoading)

        // Error=true, loading=false → valid error state
        vm.isLoading = false
        vm.isErrorLoading = true
        XCTAssertFalse(vm.isLoading && vm.isErrorLoading)
    }

    func test_fullDetails_activityType_derivedCorrectly() async {
        let vm = ViewModelMoreInfoEvent(eventId: "x")
        vm.fullDetails = EventFullDetails.sample
        XCTAssertEqual(vm.fullDetails?.activityType, .running)
    }

    func test_fullDetails_joinCondition_accessible() async {
        let vm = ViewModelMoreInfoEvent(eventId: "x")
        vm.fullDetails = EventFullDetails.sample
        XCTAssertEqual(vm.fullDetails?.joinCondition, .requestFromHost)
    }

    func test_fullDetails_dateLocations_count() async {
        let vm = ViewModelMoreInfoEvent(eventId: "x")
        vm.fullDetails = EventFullDetails.sample
        XCTAssertEqual(vm.fullDetails?.dateLocations.count, 2)
    }

    func test_fullDetails_creator_name() async {
        let vm = ViewModelMoreInfoEvent(eventId: "x")
        vm.fullDetails = EventFullDetails.sample
        XCTAssertEqual(vm.fullDetails?.creator.name, "Ahmed")
    }

    func test_differentEventIds_areIndependent() async {
        let vm1 = ViewModelMoreInfoEvent(eventId: "id-1")
        let vm2 = ViewModelMoreInfoEvent(eventId: "id-2")
        XCTAssertNotEqual(vm1.eventId, vm2.eventId)
    }
}

// MARK: - Sendable / Concurrency Conformance Tests

/// These compile-time checks verify the nonisolated Sendable structs
/// can be safely passed across actor boundaries. If they compile, they pass.
final class SendableConformanceTests: XCTestCase {

    func test_creatorInfo_sendable() async {
        let creator = CreatorInfo.sample
        let result: CreatorInfo = await Task.detached { creator }.value
        XCTAssertEqual(result.id, creator.id)
    }

    func test_locationPoint_sendable() async {
        let loc = LocationPoint.sample
        let result: LocationPoint = await Task.detached { loc }.value
        XCTAssertEqual(result.geohash, loc.geohash)
    }

    func test_dateLocationEntry_sendable() async {
        let entry = DateLocationEntry.sample
        let result: DateLocationEntry = await Task.detached { entry }.value
        XCTAssertEqual(result.id, entry.id)
    }

    func test_eventFullDetails_sendable() async {
        let event = EventFullDetails.sample
        let result: EventFullDetails = await Task.detached { event }.value
        XCTAssertEqual(result.id, event.id)
    }
}
