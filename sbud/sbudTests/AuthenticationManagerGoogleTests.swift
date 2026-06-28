//
//  AuthenticationManagerGoogleTests.swift
//  sbudTests
//
//  NOTE: AuthenticationManagerGoogle.init registers a Firebase Auth state-change
//  listener, so these tests require Firebase to be configured in the test host app.
//  If Firebase isn't initialised (no host app), setUp will crash — run tests via
//  the sbud scheme, not a standalone test plan.
//

import XCTest
@testable import sbud

final class AuthenticationManagerGoogleTests: XCTestCase {

    private var sut: AuthenticationManagerGoogle!
    private var mockGoogleManager: MockGoogleSignUpManager!

    override func setUp() {
        super.setUp()
        mockGoogleManager = MockGoogleSignUpManager()
        sut = AuthenticationManagerGoogle(googleSignUpManager: mockGoogleManager)
    }

    override func tearDown() {
        sut = nil
        mockGoogleManager = nil
        super.tearDown()
    }

    // MARK: - signUp() routes to GoogleSignUpManager

    func test_signUp_callsGoogleSignUpManagerOnce() async throws {
        try await sut.signUp()
        XCTAssertEqual(mockGoogleManager.signUpWithGoogleCallCount, 1)
    }

    func test_signUp_onManagerSuccess_doesNotThrow() async {
        mockGoogleManager.stubbedResult = .success(())
        do {
            try await sut.signUp()
        } catch {
            XCTFail("Expected no error but got: \(error)")
        }
    }

    func test_signUp_propagatesMissingClientIDError() async {
        mockGoogleManager.stubbedResult = .failure(GoogleSignUpError.missingClientID)
        do {
            try await sut.signUp()
            XCTFail("Expected error to be thrown")
        } catch {
            if case GoogleSignUpError.missingClientID = error { /* ✅ */ }
            else { XCTFail("Expected .missingClientID, got \(error)") }
        }
    }

    func test_signUp_propagatesCannotFindIdTokenError() async {
        mockGoogleManager.stubbedResult = .failure(GoogleSignUpError.cannotFindIdToken)
        do {
            try await sut.signUp()
            XCTFail("Expected error to be thrown")
        } catch {
            if case GoogleSignUpError.cannotFindIdToken = error { /* ✅ */ }
            else { XCTFail("Expected .cannotFindIdToken, got \(error)") }
        }
    }

    // MARK: - signIn() routes to same GoogleSignUpManager path

    func test_signIn_callsGoogleSignUpManagerOnce() async throws {
        try await sut.signIn()
        XCTAssertEqual(mockGoogleManager.signUpWithGoogleCallCount, 1)
    }

    func test_signIn_propagatesGoogleManagerError() async {
        mockGoogleManager.stubbedResult = .failure(GoogleSignUpError.cannotGetRootViewController)
        do {
            try await sut.signIn()
            XCTFail("Expected error to be thrown")
        } catch {
            if case GoogleSignUpError.cannotGetRootViewController = error { /* ✅ */ }
            else { XCTFail("Expected .cannotGetRootViewController, got \(error)") }
        }
    }

    func test_signIn_andSignUp_doNotShareCallCount() async throws {
        // Each method call is independent
        try await sut.signIn()
        try await sut.signUp()
        XCTAssertEqual(mockGoogleManager.signUpWithGoogleCallCount, 2)
    }

    // MARK: - Email methods are unauthorized (Google manager doesn't handle email)

    func test_signInWithEmail_throwsUnauthorizedAction() async {
        do {
            try await sut.signIn(email: "user@example.com", password: "abc123")
            XCTFail("Expected AuthError.unauthorizedAction")
        } catch AuthError.unauthorizedAction {
            // ✅
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func test_signUpWithEmail_throwsUnauthorizedAction() async {
        do {
            try await sut.signUp(email: "user@example.com", password: "abc123")
            XCTFail("Expected AuthError.unauthorizedAction")
        } catch AuthError.unauthorizedAction {
            // ✅
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func test_signInWithEmail_doesNotCallGoogleManager() async {
        try? await sut.signIn(email: "user@example.com", password: "abc123")
        XCTAssertEqual(mockGoogleManager.signUpWithGoogleCallCount, 0)
    }

    func test_signUpWithEmail_doesNotCallGoogleManager() async {
        try? await sut.signUp(email: "user@example.com", password: "abc123")
        XCTAssertEqual(mockGoogleManager.signUpWithGoogleCallCount, 0)
    }

}
