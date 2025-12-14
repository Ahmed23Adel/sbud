//
//  AuthenticationManagerTests.swift
//  sbudTests
//
//  Created by ahmed on 12/12/2025.
//

import Foundation
import XCTest
import FirebaseCore
import FirebaseAuth
import GoogleSignIn
import Combine
@testable import sbud

@MainActor
class AuthenticationManagerTests: XCTestCase {
    // system under test
    var sut: AuthenticationManager!
    var cancellables: Set<AnyCancellable>!

    // gets called before every single test method called
    override func setUp() {
        super.setUp()
        cancellables = Set<AnyCancellable>()
        UserDefaults.standard.removeObject(forKey: AppStorageConstants.signInMehtod)
    }
    // called after every test
    override func tearDown() {
        sut = nil
        cancellables = nil
        UserDefaults.standard.removeObject(forKey: AppStorageConstants.signInMehtod)
        super.tearDown()
    }

    func testInit_WhenSignInMethodUnknown_SetsUserLoggedOut() {
        // Arrange
        UserDefaults.standard.set(AuthenticationConstants.methodUnknown, forKey: AppStorageConstants.signInMehtod)

        // Act
        sut = AuthenticationManager()

        // You need this because Combine emits asynchronously, and XCTest must wait for the value.
        // wait till i call fulfill
        let expectation = XCTestExpectation(description: "User logged out")

        // listen to publisher$isSignedIn
        // combine publish its initial value when subscribed
        // but you want the next one triggered by setUserLoggedOut
        sut.$isSignedIn
            .dropFirst()
            .sink { isSignedIn in
                XCTAssertFalse(isSignedIn)
                expectation.fulfill() // Fulfills the expectation so the test continues
            }
            // if you don't use it, ARC releases it
            .store(in: &cancellables) // It keeps your Combine subscription alive.

        wait(for: [expectation], timeout: 1.0)

        // Assert
        XCTAssertFalse(sut.isSignedIn)
        XCTAssertNil(sut.currentUser)
        XCTAssertFalse(sut.isLoading)
    }

    func testInit_WhenSignInMethodGoogle_InitializesGoogleManager() {
        // Arrange
        UserDefaults.standard.set(AuthenticationConstants.methodGoogle, forKey: AppStorageConstants.signInMehtod)

        // Act
        sut = AuthenticationManager()

        // Assert
        XCTAssertEqual(sut.signInMethod, AuthenticationConstants.methodGoogle)
    }

    func testInit_WhenSignInMethodEmailAndPassword_InitializesEmailPasswordManager() {
        // Arrange
        UserDefaults.standard.set(
            AuthenticationConstants.methodEmailAndPassword,
            forKey: AppStorageConstants.signInMehtod)

        // Act
        sut = AuthenticationManager()

        // Assert
        XCTAssertEqual(sut.signInMethod, AuthenticationConstants.methodEmailAndPassword)
    }

    func testSignOut_ClearsSignInMethodAndManager() async throws {
        // Arrange
        UserDefaults.standard.set(AuthenticationConstants.methodGoogle, forKey: AppStorageConstants.signInMehtod)
        sut = AuthenticationManager()

        // Act
        do {
            try await sut.signOut()
        } catch {
            // Expected to fail in test environment without Firebase
        }

        // Assert
        XCTAssertEqual(sut.signInMethod, AuthenticationConstants.methodUnknown)
    }
}
