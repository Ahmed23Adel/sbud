//
//  ViewModelCoordinatorAddNewEventTests.swift
//  sbudTests
//

import XCTest
import FirebaseFirestore
@testable import sbud

// MARK: - Mock

final class MockCreateEventService: CreateEventRequesting {
    var callCount = 0
    var stubbedResult: Result<CreateNewEventResponse, Error> = .success(
        CreateNewEventResponse(eventId: "evt-1", flattenedEvents: [], message: "ok")
    )

    func createNewEvent(requestParams: CreateNewEventRequest) async throws -> CreateNewEventResponse {
        callCount += 1
        switch stubbedResult {
        case .success(let r): return r
        case .failure(let e): throw e
        }
    }
}

// MARK: - Tests

final class ViewModelCoordinatorAddNewEventTests: XCTestCase {

    private var mockService: MockCreateEventService!
    private var sut: ViewModelCoordinatorAddNewEvent!

    override func setUp() {
        super.setUp()
        mockService = MockCreateEventService()
        sut = ViewModelCoordinatorAddNewEvent(eventService: mockService)
    }

    override func tearDown() {
        sut = nil
        mockService = nil
        super.tearDown()
    }

    // MARK: - Helpers

    private func fillBuilderFields() {
        sut.newEventBuilder.coverImgURL = "https://example.com/img.jpg"
        sut.newEventBuilder.title = "Morning Run"
        sut.newEventBuilder.description = "Join us!"
        sut.newEventBuilder.eventCapacity = 20
        sut.newEventBuilder.dateLocationsHolder.append(DateLocations(
            startDateTime: Date(),
            endDateTime: Date().addingTimeInterval(3600),
            locations: [GeoPoint(latitude: 45, longitude: 9)]
        ))
    }

    // MARK: - Initial state

    func test_init_currentStepIsStep1() {
        XCTAssertEqual(sut.currentStep, .step1)
    }

    func test_init_isDismissedFalse() {
        XCTAssertFalse(sut.isDismissed)
    }

    func test_init_isLoadingFalse() {
        XCTAssertFalse(sut.isLoading)
    }

    // MARK: - Navigation

    func test_moveToStep2_setsStep2() {
        sut.moveToStep2()
        XCTAssertEqual(sut.currentStep, .step2)
    }

    func test_moveToStep1_afterStep2_setsStep1() {
        sut.moveToStep2()
        sut.moveToStep1()
        XCTAssertEqual(sut.currentStep, .step1)
    }

    func test_moveToStep1_alreadyOnStep1_staysStep1() {
        sut.moveToStep1()
        XCTAssertEqual(sut.currentStep, .step1)
    }

    // MARK: - createEvent — invalid fields

    func test_createEvent_withInvalidFields_doesNotCallService() {
        // Builder has empty title by default → invalid
        sut.createEvent()
        XCTAssertEqual(mockService.callCount, 0)
    }

    func test_createEvent_withInvalidFields_doesNotSetLoading() {
        sut.createEvent()
        XCTAssertFalse(sut.isLoading)
    }

    func test_createEvent_withInvalidFields_doesNotDismiss() {
        sut.createEvent()
        XCTAssertFalse(sut.isDismissed)
    }

    // MARK: - createEvent — valid fields, service succeeds

    func test_createEvent_validFields_callsServiceOnce() async throws {
        fillBuilderFields()
        sut.createEvent()
        try await Task.sleep(nanoseconds: 200_000_000)
        XCTAssertEqual(mockService.callCount, 1)
    }

    func test_createEvent_validFields_serviceSuccess_setsDismissed() async throws {
        fillBuilderFields()
        sut.createEvent()
        try await Task.sleep(nanoseconds: 200_000_000)
        XCTAssertTrue(sut.isDismissed)
    }

    func test_createEvent_validFields_serviceSuccess_isLoadingFalseAfter() async throws {
        fillBuilderFields()
        sut.createEvent()
        try await Task.sleep(nanoseconds: 200_000_000)
        XCTAssertFalse(sut.isLoading)
    }

    // MARK: - createEvent — valid fields, service fails

    func test_createEvent_validFields_serviceFailure_doesNotDismiss() async throws {
        fillBuilderFields()
        mockService.stubbedResult = .failure(URLError(.notConnectedToInternet))
        sut.createEvent()
        try await Task.sleep(nanoseconds: 200_000_000)
        XCTAssertFalse(sut.isDismissed)
    }

    func test_createEvent_validFields_serviceFailure_isLoadingFalseAfter() async throws {
        fillBuilderFields()
        mockService.stubbedResult = .failure(URLError(.notConnectedToInternet))
        sut.createEvent()
        try await Task.sleep(nanoseconds: 200_000_000)
        XCTAssertFalse(sut.isLoading)
    }

    func test_createEvent_validFields_serviceFailure_serviceStillCalled() async throws {
        fillBuilderFields()
        mockService.stubbedResult = .failure(URLError(.notConnectedToInternet))
        sut.createEvent()
        try await Task.sleep(nanoseconds: 200_000_000)
        XCTAssertEqual(mockService.callCount, 1)
    }
}
