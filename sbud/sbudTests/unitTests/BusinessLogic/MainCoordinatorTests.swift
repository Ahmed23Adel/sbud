//
//  MainCoordinatorTests.swift
//  sbudTests
//
//  Unit tests for MainCoordinator
//

import XCTest
import Combine
import FirebaseAuth
import FirebaseCore
@testable import sbud

@MainActor
final class MainCoordinatorTests: XCTestCase {
    var sut: MainCoordinator!
    var cancellables: Set<AnyCancellable>!
    var mockAuthManager: MockAuthenticationManager!

    override func setUp() {
        super.setUp()
        cancellables = []
        mockAuthManager = MockAuthenticationManager()
        // Note: You'll need to inject the mock into MainCoordinator
        // For now, we'll test with the real implementation
    }

    override func tearDown() {
        sut = nil
        cancellables = nil
        mockAuthManager = nil
        super.tearDown()
    }

    // MARK: - Initialization Tests

    func testInitialization_WhenUserIsAuthenticated_ShouldStartAtHomePage() {
        // Given
        mockAuthManager.isAuthenticated = true

        // When
        sut = MainCoordinator(authManager: mockAuthManager)
        print("testInitialization_WhenUserIsAuthenticated_ShouldStartAtHomePage", mockAuthManager.isAuthenticated, sut.currentRoute)
        // Then
        XCTAssertEqual(sut.currentRoute, .homePage, "Should initialize to homePage when user is authenticated")
    }

    func testInitialization_WhenUserIsNotAuthenticated_ShouldStartAtSignUp() {
        // Given
        mockAuthManager.isAuthenticated = false

        // When
        sut = MainCoordinator(authManager: mockAuthManager)

        // Then
        XCTAssertEqual(sut.currentRoute, .signUp, "Should initialize to signUp when user is not authenticated")
    }

    // MARK: - Navigation Tests

    func testNavigateTo_ShouldUpdateCurrentRoute() {
        // Given
        sut = MainCoordinator(authManager: MockAuthenticationManager())
        let expectedRoute: MainRoute = .signIn

        // When
        sut.navigateTo(expectedRoute)

        // Then
        XCTAssertEqual(sut.currentRoute, expectedRoute, "navigateTo should update currentRoute")
    }

    func testGoToSignUp_ShouldNavigateToSignUpRoute() {
        // Given
        sut = MainCoordinator(authManager: mockAuthManager)
        sut.currentRoute = .homePage

        // When
        sut.goToSignUp()

        // Then
        XCTAssertEqual(sut.currentRoute, .signUp, "goToSignUp should navigate to signUp route")
    }

    func testGoToSignIn_ShouldNavigateToSignInRoute() {
        // Given
        sut = MainCoordinator(authManager: mockAuthManager)
        sut.currentRoute = .signUp

        // When
        sut.goToSignIn()

        // Then
        XCTAssertEqual(sut.currentRoute, .signIn, "goToSignIn should navigate to signIn route")
    }

    func testGoToHome_ShouldNavigateToHomePageRoute() {
        // Given
        sut = MainCoordinator(authManager: mockAuthManager)
        sut.currentRoute = .signIn

        // When
        sut.goToHome()

        // Then
        XCTAssertEqual(sut.currentRoute, .homePage, "goToHome should navigate to homePage route")
    }

    // MARK: - Published Property Tests

    func testCurrentRoute_ShouldPublishChanges() {
        // Given
        sut = MainCoordinator(authManager: MockAuthenticationManager())
        let expectation = XCTestExpectation(description: "currentRoute should publish changes")
        var receivedRoutes: [MainRoute] = []

        sut.$currentRoute
            .dropFirst() // Skip initial value
            .sink { route in
                receivedRoutes.append(route)
                if receivedRoutes.count == 3 {
                    expectation.fulfill()
                }
            }
            .store(in: &cancellables)

        // When
        sut.goToSignIn()
        sut.goToHome()
        sut.goToSignUp()

        // Then
        wait(for: [expectation], timeout: 1.0)
        XCTAssertEqual(receivedRoutes, [.signIn, .homePage, .signUp], "Should publish all route changes")
    }

    // MARK: - Navigation Flow Tests

    func testNavigationFlow_CompleteAuthenticationFlow() {
        // Given
        sut = MainCoordinator(authManager: MockAuthenticationManager())
        sut.currentRoute = .signUp

        // When & Then - Simulate user flow
        sut.goToSignIn()
        XCTAssertEqual(sut.currentRoute, .signIn, "Should navigate from signUp to signIn")

        sut.goToHome()
        XCTAssertEqual(sut.currentRoute, .homePage, "Should navigate from signIn to homePage after successful login")
    }

    func testNavigationFlow_LogoutFlow() {
        // Given
        sut = MainCoordinator(authManager: MockAuthenticationManager())
        sut.currentRoute = .homePage

        // When
        sut.goToSignUp()

        // Then
        XCTAssertEqual(sut.currentRoute, .signUp, "Should navigate from homePage to signUp after logout")
    }
}

// MARK: - Mock Objects

class MockAuthenticationManager: IAuthenticationManager {
    var isSignedIn: Bool = false
    var currentUser: FirebaseAuth.User?
    var isLoading: Bool = true
    var isAuthenticated = false
    
    func signUp() async throws {
    
    }
    
    func signIn() async throws {
    
    }
    
    func signOut() async throws {
    
    }
    
    

    func checkAuthStatus() -> Bool {
        return isAuthenticated
    }
}

// MARK: - UI Tests for MainAppCoordinator

@MainActor
final class MainAppCoordinatorUITests: XCTestCase {

    func testMainAppCoordinator_ShouldRenderCorrectView_BasedOnRoute() {
        // This is more of an integration test
        // You would use ViewInspector library for this

        // Given
        let coordinator = MainCoordinator(authManager: MockAuthenticationManager())

        // When
        coordinator.currentRoute = .signUp

        // Then
        // Use ViewInspector or snapshot testing to verify SignUpView is rendered
        XCTAssertEqual(coordinator.currentRoute, .signUp)
    }
}

// MARK: - Performance Tests

@MainActor
final class MainCoordinatorPerformanceTests: XCTestCase {

    func testNavigationPerformance() {
        let coordinator = MainCoordinator(authManager: MockAuthenticationManager())

        measure {
            for _ in 0..<1000 {
                coordinator.goToSignIn()
                coordinator.goToHome()
                coordinator.goToSignUp()
            }
        }
    }
}
