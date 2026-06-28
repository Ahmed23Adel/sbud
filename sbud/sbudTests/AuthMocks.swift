//
//  AuthMocks.swift
//  sbudTests
//

import XCTest
import Foundation
@testable import sbud

// MARK: - MockAuthOrchestrator

final class MockAuthOrchestrator: IAuthOrchestrator {

    // MARK: Call tracking
    var setAuthTypeGoogleCallCount = 0
    var setAuthTypeEmailAndPasswordCallCount = 0
    var signInNoArgsCallCount = 0
    var signUpNoArgsCallCount = 0
    var signInEmailCallCount = 0
    var signUpEmailCallCount = 0
    var sendPasswordResetCallCount = 0
    var sendPasswordResetCalledWithEmail: String?
    var sendVerificationEmailCallCount = 0

    // MARK: Stubbable results
    var signInResult: Result<Void, Error> = .success(())
    var signUpResult: Result<Void, Error> = .success(())
    var signInEmailResult: Result<Void, Error> = .success(())
    var signUpEmailResult: Result<Void, Error> = .success(())
    var sendPasswordResetResult: Result<Void, Error> = .success(())

    func setAuthTypeGoogle() { setAuthTypeGoogleCallCount += 1 }
    func setAuthTypeEmailAndPassword() { setAuthTypeEmailAndPasswordCallCount += 1 }

    func signIn() async throws {
        signInNoArgsCallCount += 1
        if case .failure(let e) = signInResult { throw e }
    }

    func signUp() async throws {
        signUpNoArgsCallCount += 1
        if case .failure(let e) = signUpResult { throw e }
    }

    func signIn(email: String, password: String) async throws {
        signInEmailCallCount += 1
        if case .failure(let e) = signInEmailResult { throw e }
    }

    func signUp(email: String, password: String) async throws {
        signUpEmailCallCount += 1
        if case .failure(let e) = signUpEmailResult { throw e }
    }

    func sendPasswordReset(email: String) async throws {
        sendPasswordResetCallCount += 1
        sendPasswordResetCalledWithEmail = email
        if case .failure(let e) = sendPasswordResetResult { throw e }
    }

    func sendVerificationEmail() {
        sendVerificationEmailCallCount += 1
    }
}

// MARK: - MockEmailExistenceChecker

final class MockEmailExistenceChecker: IEmailExistenceChecker {

    var isEmailTakenCallCount = 0
    var isEmailTakenCalledWithEmail: String?
    var stubbedResult: Result<Bool, Error> = .success(false)

    func isEmailTaken(_ email: String) async throws -> Bool {
        isEmailTakenCallCount += 1
        isEmailTakenCalledWithEmail = email
        switch stubbedResult {
        case .success(let value): return value
        case .failure(let error): throw error
        }
    }
}

// MARK: - MockGoogleSignUpManager

final class MockGoogleSignUpManager: IGoogleSignUpManager {

    var signUpWithGoogleCallCount = 0
    var stubbedResult: Result<Void, Error> = .success(())

    func signUpWithGoogle() async throws {
        signUpWithGoogleCallCount += 1
        if case .failure(let e) = stubbedResult { throw e }
    }
}

// MARK: - Shared test error

enum MockAuthTestError: Error, Equatable {
    case generic
    case network
}
