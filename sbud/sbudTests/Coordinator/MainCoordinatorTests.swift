//
//  MainCoordinatorTests.swift
//  sbudTests
//
//  Created by Riccardo Maria Cadario on 02/07/2026.
//

import XCTest
import Combine
import FirebaseAuth
@testable import sbud

@MainActor
final class MainCoordinatorTests: XCTestCase {

    var sut: MainCoordinator!
    var mockAuthManager: MockAuthenticationManager!
    var mockProfileManager: MockProfileServiceManager!

    override func setUp() {
        super.setUp()
        mockAuthManager = MockAuthenticationManager()
        mockProfileManager = MockProfileServiceManager()

        sut = MainCoordinator(authService: mockAuthManager, profileService: mockProfileManager)
    }

    override func tearDown() {
        sut = nil
        mockAuthManager = nil
        mockProfileManager = nil
        super.tearDown()
    }

    // MARK: - Tests Navigazione Base

    func test_init_startsInLoadingRoute() {
        XCTAssertEqual(sut.currentRoute, .loading)
    }

    func test_navigateTo_changesRouteCorrectly() {
        sut.navigateTo(.signIn)
        XCTAssertEqual(sut.currentRoute, .signIn)
    }

    func test_goToHome_navigatesToHome() {
        sut.goToHome()
        XCTAssertEqual(sut.currentRoute, .home)
    }

    // MARK: - Tests Risoluzione Route Iniziale

    func test_resolveInitialRoute_whenUserNotAuthenticated_navigatesToSignUp() async throws {
        mockAuthManager.authStatusReturnValue = false

        sut.resolveInitialRoute()
        try await Task.sleep(nanoseconds: 50_000_000)

        XCTAssertEqual(sut.currentRoute, .signUp)
    }

    func test_resolveInitialRoute_whenAuthenticatedAndProfileComplete_navigatesToHome() async throws {
        mockAuthManager.authStatusReturnValue = true
        mockProfileManager.isProfileSetupComplete = true

        sut.resolveInitialRoute()
        try await Task.sleep(nanoseconds: 50_000_000)

        XCTAssertEqual(sut.currentRoute, .home)
    }

    func test_resolveInitialRoute_whenAuthenticatedAndProfileIncomplete_syncSucceeds_navigatesToHome() async throws {
        mockAuthManager.authStatusReturnValue = true
        mockProfileManager.isProfileSetupComplete = false

        mockProfileManager.onSyncProfile = { [weak self] in
            self?.mockProfileManager.isProfileSetupComplete = true
        }

        sut.resolveInitialRoute()
        try await Task.sleep(nanoseconds: 50_000_000)

        XCTAssertTrue(mockProfileManager.syncProfileAfterLoginCalled)
        XCTAssertEqual(sut.currentRoute, .home)
    }

    func test_resolveInitialRoute_whenAuthenticatedAndProfileIncomplete_syncFails_navigatesToProfileSetup() async throws {
        struct DummyError: Error {}
        mockAuthManager.authStatusReturnValue = true
        mockProfileManager.isProfileSetupComplete = false
        mockProfileManager.syncProfileAfterLoginError = DummyError()

        sut.resolveInitialRoute()
        try await Task.sleep(nanoseconds: 50_000_000)

        XCTAssertTrue(mockProfileManager.syncProfileAfterLoginCalled)
        XCTAssertEqual(sut.currentRoute, .profileSetup)
    }

    // MARK: - Tests Eventi di Autenticazione (Delegate)

    func test_coordinatorDidRequestLogout_clearsLocaleAndSignsOut() async throws {
        sut.coordinatorDidRequestLogout()

        XCTAssertTrue(mockProfileManager.deleteProfileFromLocaleCalled)
        XCTAssertEqual(sut.currentRoute, .signUp)

        try await Task.sleep(nanoseconds: 50_000_000)
        XCTAssertTrue(mockAuthManager.signOutCalled)
    }
    // MARK: - Deep link

        func test_deepLink_profile_whenHome_setsProfileUserId() {
            sut.goToHome()
            sut.handle(universalLink: URL(string: "sbud://profile/user123")!)
            XCTAssertEqual(sut.deepLinkProfileUserId, "user123")
        }

        func test_deepLink_event_whenHome_setsEventId() {
            sut.goToHome()
            sut.handle(universalLink: URL(string: "sbud://event/evento456")!)
            XCTAssertEqual(sut.deepLinkEventId, "evento456")
        }

        func test_deepLink_universalLink_profile_whenHome_setsProfileUserId() {
            sut.goToHome()
            sut.handle(universalLink: URL(string: "https://sbud-backend.onrender.com/profile/user789")!)
            XCTAssertEqual(sut.deepLinkProfileUserId, "user789")
        }

        func test_deepLink_beforeHome_isDeliveredOnGoToHome() {
            sut.navigateTo(.signIn)
            sut.handle(universalLink: URL(string: "sbud://profile/pendingUser")!)
            XCTAssertNil(sut.deepLinkProfileUserId)
            sut.goToHome()
            XCTAssertEqual(sut.deepLinkProfileUserId, "pendingUser")
        }

        func test_deepLink_unknownHost_doesNothing() {
            sut.goToHome()
            sut.handle(universalLink: URL(string: "https://sito-a-caso.com/profile/u1")!)
            XCTAssertNil(sut.deepLinkProfileUserId)
            XCTAssertNil(sut.deepLinkEventId)
        }
}

class MockAuthenticationManager: IAuthenticationManager {

    @Published var isSignedIn: Bool = false
    @Published var currentUser: FirebaseAuth.User? = nil

    var authStatusReturnValue = false
    var signOutCalled = false
    var signOutError: Error?

    func checkAuthStatus() -> Bool {
        return authStatusReturnValue
    }

    func signOut() async throws {
        signOutCalled = true
        if let error = signOutError {
            throw error
        }
    }

    func signIn() async throws {}
    func signUp() async throws {}
    func signIn(email: String, password: String) async throws {}
    func signUp(email: String, password: String) async throws {}
    
    
}
