//
//  SessionViewModelsTests.swift
//  sbud
//
//  Created by Riccardo Maria Cadario on 10/07/2026.
//


import XCTest
import SwiftData
import FirebaseFirestore
@testable import sbud

@MainActor
final class SessionViewModelsTests: XCTestCase {

    private var savedProfile: UserProfile?
    private var container: ModelContainer!
    private var context: ModelContext!

    override func setUp() async throws {
        try await super.setUp()
        savedProfile = ProfileManager.shared.getLocalProfile()
        ProfileManager.shared.saveProfileToLocale(profile: UserProfile(id: "session_test_user"))

        // SwiftData in memoria: niente file su disco, ogni test parte pulito
        let config = ModelConfiguration(isStoredInMemoryOnly: true)
        container = try ModelContainer(for: LocalOnGoingSession.self, configurations: config)
        context = ModelContext(container)
    }

    override func tearDown() async throws {
        if let savedProfile {
            ProfileManager.shared.saveProfileToLocale(profile: savedProfile)
        } else {
            ProfileManager.shared.deleteProfileFromLocale()
        }
        context = nil
        container = nil
        try await super.tearDown()
    }

    private func makeEvent(activity: ActivityType = .gym) -> EventFullDetails {
        var e = EventFullDetails.fixture(id: "session_evt_1")
        e.activityDetails = ExtraArgsHolder()
        e.activityDetails.selectedActivity = activity
        return e
    }

    // MARK: - Owner: init e scelta del collector

    func test_owner_init_gym_createsGymCollector() {
        let sut = ViewModelOwnerSession(eventDetails: makeEvent(activity: .gym), isSessionCreated: true)
        XCTAssertTrue(sut.metricsCollector is MetricsCollectorGym)
    }

    func test_owner_init_yoga_createsYogaCollector() {
        let sut = ViewModelOwnerSession(eventDetails: makeEvent(activity: .yoga), isSessionCreated: true)
        XCTAssertTrue(sut.metricsCollector is MetricsCollectorYoga)
    }

    func test_owner_init_tennis_createsTennisCollector() {
        let sut = ViewModelOwnerSession(eventDetails: makeEvent(activity: .tennis), isSessionCreated: true)
        XCTAssertTrue(sut.metricsCollector is MetricsCollectorTennis)
    }

    func test_owner_init_swimming_createsSwimmingCollector() {
        let sut = ViewModelOwnerSession(eventDetails: makeEvent(activity: .swimming), isSessionCreated: true)
        XCTAssertTrue(sut.metricsCollector is MetricsCollectorSwimming)
    }

    func test_owner_init_running_createsRunCollector() {
        let sut = ViewModelOwnerSession(eventDetails: makeEvent(activity: .running), isSessionCreated: true)
        XCTAssertTrue(sut.metricsCollector is MetricsCollectorRun)
    }

    func test_owner_init_cycling_createsCyclingCollector() {
        let sut = ViewModelOwnerSession(eventDetails: makeEvent(activity: .cycling), isSessionCreated: true)
        XCTAssertTrue(sut.metricsCollector is MetricsCollectorCycling)
    }

    func test_owner_init_skiing_createsSkiingCollector() {
        let sut = ViewModelOwnerSession(eventDetails: makeEvent(activity: .skiing), isSessionCreated: true)
        XCTAssertTrue(sut.metricsCollector is MetricsCollectorSkiing)
    }

    func test_owner_init_hiking_createsHikingCollector() {
        let sut = ViewModelOwnerSession(eventDetails: makeEvent(activity: .hiking), isSessionCreated: true)
        XCTAssertTrue(sut.metricsCollector is MetricsCollectorHiking)
    }

    // MARK: - Owner: sessione locale (SwiftData in memoria)

    func test_owner_saveSessionLocally_insertsRecord() throws {
        let sut = ViewModelOwnerSession(eventDetails: makeEvent(), isSessionCreated: true)
        sut.setModelContext(context: context)

        sut.saveSessoinLocally()

        let all = try context.fetch(FetchDescriptor<LocalOnGoingSession>())
        XCTAssertEqual(all.count, 1)
        XCTAssertEqual(all.first?.eventId, "session_evt_1")
        XCTAssertEqual(all.first?.creatorId, "session_test_user")
    }

    func test_owner_readLocalSessionDetails_restoresStartDate() {
        let sut = ViewModelOwnerSession(eventDetails: makeEvent(), isSessionCreated: true)
        sut.setModelContext(context: context)
        let savedDate = Date(timeIntervalSince1970: 1_700_000_000)
        context.insert(LocalOnGoingSession(
            creatorId: "session_test_user",
            eventId: "session_evt_1",
            startDateTime: savedDate,
            activityType: .gym
        ))

        sut.readLocalSessionDetails()

        XCTAssertEqual(sut.startDateTime, savedDate)
    }

    func test_owner_readLocalSessionDetails_noRecord_keepsCurrentDate() {
        let sut = ViewModelOwnerSession(eventDetails: makeEvent(), isSessionCreated: true)
        sut.setModelContext(context: context)
        let before = sut.startDateTime

        sut.readLocalSessionDetails()

        XCTAssertEqual(sut.startDateTime, before)
    }

    func test_owner_setMainCoordinator_storesIt() {
        let sut = ViewModelOwnerSession(eventDetails: makeEvent(), isSessionCreated: true)
        let coordinator = MainCoordinator(
            authService: MockAuthenticationManager(),
            profileService: MockProfileServiceManager()
        )
        sut.setMainCoordinator(coordinator)
        XCTAssertNotNil(sut.mainCoordinator)
    }

    // MARK: - Participant (ViewModelOthersSession)

    func test_participant_init_gym_createsGymCollector() {
        let sut = ViewModelOthersSession(eventDetails: makeEvent(activity: .gym), isSessionCreated: false)
        XCTAssertTrue(sut.metricsCollector is MetricsCollectorGym)
    }

    func test_participant_init_running_createsRunCollector() {
        let sut = ViewModelOthersSession(eventDetails: makeEvent(activity: .running), isSessionCreated: false)
        XCTAssertTrue(sut.metricsCollector is MetricsCollectorRun)
    }

    func test_participant_init_hiking_createsHikingCollector() {
        let sut = ViewModelOthersSession(eventDetails: makeEvent(activity: .hiking), isSessionCreated: false)
        XCTAssertTrue(sut.metricsCollector is MetricsCollectorHiking)
    }

    func test_participant_saveSessionLocally_insertsRecord() throws {
        let sut = ViewModelOthersSession(eventDetails: makeEvent(), isSessionCreated: false)
        sut.setModelContext(context: context)

        sut.saveSessionLocally()

        let all = try context.fetch(FetchDescriptor<LocalOnGoingSession>())
        XCTAssertEqual(all.count, 1)
    }

    func test_participant_readLocalSessionDetails_restoresStartDate_andGymCollector() {
        let sut = ViewModelOthersSession(eventDetails: makeEvent(activity: .gym), isSessionCreated: false)
        sut.setModelContext(context: context)
        let savedDate = Date(timeIntervalSince1970: 1_700_000_000)
        context.insert(LocalOnGoingSession(
            creatorId: "session_test_user",
            eventId: "session_evt_1",
            startDateTime: savedDate,
            activityType: .gym
        ))

        sut.readLocalSessionDetails()

        XCTAssertEqual(sut.startDateTime, savedDate)
    }

    // MARK: - Participant: onEndSessionTapped (Firestore emulato)

    func test_participant_endTapped_creatorHasEnded_showsSimpleConfirm() async throws {
        // Seminiamo l'evento con finalEndDateTime presente
        try await Firestore.firestore().collection("Events").document("session_evt_1")
            .setData(["finalEndDateTime": Timestamp(date: Date())])
        let sut = ViewModelOthersSession(eventDetails: makeEvent(), isSessionCreated: false)

        sut.onEndSessionTapped()
        for _ in 0..<50 {
            if sut.isShowSimpleConfirm || sut.isShowEarlyEndWarning { break }
            try await Task.sleep(nanoseconds: 100_000_000)
        }

        XCTAssertTrue(sut.isShowSimpleConfirm)
        XCTAssertFalse(sut.isShowEarlyEndWarning)
        XCTAssertFalse(sut.isLoading)
    }

    func test_participant_endTapped_creatorNotEnded_showsEarlyWarning() async throws {
        try await Firestore.firestore().collection("Events").document("session_evt_1")
            .setData(["title": "ancora in corso"])  // niente finalEndDateTime
        let sut = ViewModelOthersSession(eventDetails: makeEvent(), isSessionCreated: false)

        sut.onEndSessionTapped()
        for _ in 0..<50 {
            if sut.isShowSimpleConfirm || sut.isShowEarlyEndWarning { break }
            try await Task.sleep(nanoseconds: 100_000_000)
        }

        XCTAssertTrue(sut.isShowEarlyEndWarning)
        XCTAssertFalse(sut.isShowSimpleConfirm)
    }
}