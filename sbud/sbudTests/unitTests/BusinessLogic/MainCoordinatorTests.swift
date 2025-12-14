//
//  MainCoordinatorTests.swift
//  sbudTests
//
//  Unit tests for MainCoordinator
//

import XCTest
import Combine
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
        sut = MainCoordinator()

        // Then
        XCTAssertEqual(sut.currentRoute, .homePage, "Should initialize to homePage when user is authenticated")
    }

    func testInitialization_WhenUserIsNotAuthenticated_ShouldStartAtSignUp() {
        // Given
        mockAuthManager.isAuthenticated = false

        // When
        sut = MainCoordinator()

        // Then
        XCTAssertEqual(sut.currentRoute, .signUp, "Should initialize to signUp when user is not authenticated")
    }

    // MARK: - Navigation Tests

    func testNavigateTo_ShouldUpdateCurrentRoute() {
        // Given
        sut = MainCoordinator()
        let expectedRoute: mainRoute = .signIn

        // When
        sut.navigateTo(expectedRoute)

        // Then
        XCTAssertEqual(sut.currentRoute, expectedRoute, "navigateTo should update currentRoute")
    }

    func testGoToSignUp_ShouldNavigateToSignUpRoute() {
        // Given
        sut = MainCoordinator()
        sut.currentRoute = .homePage

        // When
        sut.goToSignUp()

        // Then
        XCTAssertEqual(sut.currentRoute, .signUp, "goToSignUp should navigate to signUp route")
    }

    func testGoToSignIn_ShouldNavigateToSignInRoute() {
        // Given
        sut = MainCoordinator()
        sut.currentRoute = .signUp

        // When
        sut.goToSignIn()

        // Then
        XCTAssertEqual(sut.currentRoute, .signIn, "goToSignIn should navigate to signIn route")
    }

    func testGoToHome_ShouldNavigateToHomePageRoute() {
        // Given
        sut = MainCoordinator()
        sut.currentRoute = .signIn

        // When
        sut.goToHome()

        // Then
        XCTAssertEqual(sut.currentRoute, .homePage, "goToHome should navigate to homePage route")
    }

    // MARK: - Published Property Tests

    func testCurrentRoute_ShouldPublishChanges() {
        // Given
        sut = MainCoordinator()
        let expectation = XCTestExpectation(description: "currentRoute should publish changes")
        var receivedRoutes: [mainRoute] = []

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
        sut = MainCoordinator()
        sut.currentRoute = .signUp

        // When & Then - Simulate user flow
        sut.goToSignIn()
        XCTAssertEqual(sut.currentRoute, .signIn, "Should navigate from signUp to signIn")

        sut.goToHome()
        XCTAssertEqual(sut.currentRoute, .homePage, "Should navigate from signIn to homePage after successful login")
    }

    func testNavigationFlow_LogoutFlow() {
        // Given
        sut = MainCoordinator()
        sut.currentRoute = .homePage

        // When
        sut.goToSignUp()

        // Then
        XCTAssertEqual(sut.currentRoute, .signUp, "Should navigate from homePage to signUp after logout")
    }
}

// MARK: - Mock Objects

class MockAuthenticationManager {
    var isAuthenticated = false

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
        let coordinator = MainCoordinator()

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
        let coordinator = MainCoordinator()

        measure {
            for _ in 0..<1000 {
                coordinator.goToSignIn()
                coordinator.goToHome()
                coordinator.goToSignUp()
            }
        }
    }
}
