//
//  AuthenticationManagerEmailAndPasswordTests.swift
//  sbudTests
//
//  Tests that don't require a live Firebase connection.
//  Methods that call Auth.auth().signIn/signUp/signOut are excluded — those
//  belong in an end-to-end suite against the Firebase emulator.
//

import XCTest
import FirebaseAuth
@testable import sbud

final class AuthenticationManagerEmailAndPasswordTests: XCTestCase {

    private var sut: AuthenticationManagerEmailAndPassword!

    override func setUp() {
        super.setUp()
        sut = AuthenticationManagerEmailAndPassword()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // MARK: - signIn() / signUp() no-arg overloads (always unauthorized)

    func test_signIn_noArgs_throwsUnauthorizedAction() async {
        do {
            try await sut.signIn()
            XCTFail("Expected AuthError.unauthorizedAction to be thrown")
        } catch AuthError.unauthorizedAction {
            // ✅
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }

    func test_signUp_noArgs_throwsUnauthorizedAction() async {
        do {
            try await sut.signUp()
            XCTFail("Expected AuthError.unauthorizedAction to be thrown")
        } catch AuthError.unauthorizedAction {
            // ✅
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }

    func test_signIn_noArgs_doesNotMutateCurrentUser() async {
        let before = sut.currentUser
        try? await sut.signIn()
        XCTAssertEqual(sut.currentUser?.uid, before?.uid)
    }

    func test_signUp_noArgs_doesNotMutateCurrentUser() async {
        let before = sut.currentUser
        try? await sut.signUp()
        XCTAssertEqual(sut.currentUser?.uid, before?.uid)
    }

    // MARK: - Initial state

    func test_initialState_isSignedInFalse() {
        XCTAssertFalse(sut.isSignedIn)
    }

    func test_initialState_currentUserIsNil() {
        XCTAssertNil(sut.currentUser)
    }

}
