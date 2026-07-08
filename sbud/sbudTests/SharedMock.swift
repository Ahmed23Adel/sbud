//
//  SharedMock.swift
//  sbud
//
//  Created by Erdal on 2.07.2026.
//

import Foundation
@testable import sbud

// MARK: - MockUserProfileFetching

final class MockUserProfileFetching: UserProfileFetching {
    var stubbedResult: Result<UserProfile?, Error> = .success(nil)
    private(set) var fetchCallCount = 0
    private(set) var lastRequestedId: String?

    func fetchProfile(_ id: String) async throws -> UserProfile? {
        fetchCallCount += 1
        lastRequestedId = id
        switch stubbedResult {
        case .success(let v): return v
        case .failure(let e): throw e
        }
    }
}

// MARK: - MockUserProfileUpdating

final class MockUserProfileUpdating: UserProfileUpdating {
    var stubbedResult: Result<Void, Error> = .success(())
    private(set) var callCount = 0
    private(set) var lastUid: String?
    private(set) var lastFields: [String: Any]?

    func updateUserProfileFields(uid: String, fields: [String: Any]) async throws {
        callCount += 1
        lastUid = uid
        lastFields = fields
        if case .failure(let e) = stubbedResult { throw e }
    }
}

// MARK: - MockProfileServiceManager

final class MockProfileServiceManager: IProfileServiceManager {
    var storedProfile: UserProfile?
    var isProfileSetupComplete: Bool = false

    var updateProfileStepResult: Result<Void, Error> = .success(())
    var uploadProfileImageResult: Result<String, Error> = .success("https://cdn.sbud.app/test.jpg")

    private(set) var getLocalProfileCallCount = 0
    private(set) var saveLocalCallCount = 0
    private(set) var updateStepCallCount = 0
    private(set) var uploadImageCallCount = 0
    private(set) var lastUpdatedFields: [String: Any]?
    private(set) var lastUpdatedUid: String?

    func getLocalProfile() -> UserProfile? {
        getLocalProfileCallCount += 1
        return storedProfile
    }
    func saveProfileToLocale(profile: UserProfile) {
        saveLocalCallCount += 1
        storedProfile = profile
    }
    func saveProfileToDatabase(profile: UserProfile) async throws { storedProfile = profile }
    func deleteProfileFromDatabase(uid: String) async throws {}
    func deleteProfileFromLocale() { storedProfile = nil }
    func syncProfileAfterLogin() async throws {}
    func updateProfileStep(uid: String, fields: [String: Any], localProfile: UserProfile) async throws {
        updateStepCallCount += 1
        lastUpdatedUid = uid
        lastUpdatedFields = fields
        if case .failure(let e) = updateProfileStepResult { throw e }
        storedProfile = localProfile
    }
    func uploadProfileImage(data: Data) async throws -> String {
        uploadImageCallCount += 1
        switch uploadProfileImageResult {
        case .success(let url): return url
        case .failure(let e): throw e
        }
    }
}

// MARK: - MockUsersEventFetching

final class MockUsersEventFetching: UsersEventFetching {
    var stubbedResult: Result<[UsersEvent], Error> = .success([])
    private(set) var lastUserId: String?

    func fetchCreatedEvents(userId: String) async throws -> [UsersEvent] {
        lastUserId = userId
        switch stubbedResult {
        case .success(let v): return v
        case .failure(let e): throw e
        }
    }
}

// MARK: - MockHostingEventsFetching

final class MockHostingEventsFetching: HostingEventsFetching {
    var stubbedResult: Result<[HostingEvent], Error> = .success([])

    func fetchHostingEvents() async throws -> [HostingEvent] {
        switch stubbedResult {
        case .success(let v): return v
        case .failure(let e): throw e
        }
    }
}

// MARK: - MockJoinedEventsFetching

final class MockJoinedEventsFetching: JoinedEventsFetching {
    var stubbedResult: Result<[UsersEvent], Error> = .success([])
    private(set) var lastUserId: String?

    func fetchJoinedEvents(userId: String) async throws -> [UsersEvent] {
        lastUserId = userId
        switch stubbedResult {
        case .success(let v): return v
        case .failure(let e): throw e
        }
    }
}

// MARK: - MockEventDeleting

final class MockEventDeleting: EventDeleting {
    var stubbedResult: Result<Void, Error> = .success(())
    private(set) var deleteCallCount = 0
    private(set) var lastEventId: String?

    func deleteEvent(eventId: String) async throws {
        deleteCallCount += 1
        lastEventId = eventId
        if case .failure(let e) = stubbedResult { throw e }
    }
}

// MARK: - MockHostInvitationFetching

final class MockHostInvitationFetching: HostInvitationFetching {
    var stubbedResult: Result<[HostInvitationItem], Error> = .success([])
    private(set) var lastUserId: String?

    func fetchInvitations(userId: String) async throws -> [HostInvitationItem] {
        lastUserId = userId
        switch stubbedResult {
        case .success(let v): return v
        case .failure(let e): throw e
        }
    }
}

// MARK: - MockHostInvitationResponding

final class MockHostInvitationResponding: HostInvitationResponding {
    var stubbedResult: Result<Void, Error> = .success(())
    private(set) var calls: [(eventId: String, accept: Bool)] = []

    func respond(eventId: String, accept: Bool) async throws {
        calls.append((eventId, accept))
        if case .failure(let e) = stubbedResult { throw e }
    }
}

// MARK: - Fixtures

extension UsersEvent {
    static func fixture(eventId: String = "e1", status: UsersEventStatus = .confirmed) -> UsersEvent {
        var e = UsersEvent()
        e.eventId = eventId
        e.title = "Event \(eventId)"
        e.status = status
        return e
    }
}

extension HostingEvent {
    static func fixture(eventId: String = "h1", status: String = "Confirmed") -> HostingEvent {
        HostingEvent(eventId: eventId, title: "Hosting \(eventId)",
                     activityType: "running", eventImage: "", status: status)
    }
}

extension JoinQueueResponse {
    static func fixture(pendingUserIds: [String] = [], confirmedCount: Int = 0) -> JoinQueueResponse {
        let users = pendingUserIds.map {
            PendingRequester(userId: $0, name: "User", surName: $0, profileImageUrl: nil)
        }
        return JoinQueueResponse(
            confirmedCount: confirmedCount,
            pendingCount: pendingUserIds.count,
            waitlistCount: 0,
            capacity: nil,
            isCapacityFull: false,
            waitlistMax: 0,
            pendingUsers: users
        )
    }
}
