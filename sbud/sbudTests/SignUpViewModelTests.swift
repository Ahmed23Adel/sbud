//
//  SignUpViewModelTests.swift
//  sbudTests
//

import XCTest
import FirebaseAuth
@testable import sbud

@MainActor
final class SignUpViewModelTests: XCTestCase {

    private var sut: SignUpViewModel!
    private var mockOrchestrator: MockAuthOrchestrator!
    private var mockEmailChecker: MockEmailExistenceChecker!

    override func setUp() {
        super.setUp()
        mockOrchestrator  = MockAuthOrchestrator()
        mockEmailChecker  = MockEmailExistenceChecker()
        sut = SignUpViewModel(authManager: mockOrchestrator, emailChecker: mockEmailChecker)
    }

    override func tearDown() {
        sut              = nil
        mockOrchestrator = nil
        mockEmailChecker = nil
        super.tearDown()
    }

    // MARK: - Initial state

    func test_initialState_emailIsEmpty() {
        XCTAssertEqual(sut.email, "")
    }

    func test_initialState_isLoadingFalse() {
        XCTAssertFalse(sut.isLoading)
    }

    func test_initialState_showAlertFalse() {
        XCTAssertFalse(sut.showAlert)
    }

    func test_initialState_emailIsValidFalse() {
        XCTAssertFalse(sut.emailIsValid)
    }

    func test_initialState_emailValidationFailedFalse() {
        XCTAssertFalse(sut.emailValidationFailed)
    }

    // MARK: - signUpWithEmail: password mismatch

    func test_signUpWithEmail_passwordMismatch_doesNotCallAuth() async throws {
        sut.email           = "user@example.com"
        sut.password        = "abc123"
        sut.confirmPassword = "different"

        try await sut.signUpWithEmail()

        XCTAssertEqual(mockOrchestrator.signUpEmailCallCount, 0)
    }

    func test_signUpWithEmail_passwordMismatch_doesNotSendVerificationEmail() async throws {
        sut.email           = "user@example.com"
        sut.password        = "abc123"
        sut.confirmPassword = "different"

        try await sut.signUpWithEmail()

        XCTAssertEqual(mockOrchestrator.sendVerificationEmailCallCount, 0)
    }

    // MARK: - signUpWithEmail: validation guards

    func test_signUpWithEmail_withInvalidEmail_doesNotCallAuth() async throws {
        sut.email           = "notanemail"
        sut.password        = "abc123"
        sut.confirmPassword = "abc123"

        try await sut.signUpWithEmail()

        XCTAssertEqual(mockOrchestrator.signUpEmailCallCount, 0)
    }

    func test_signUpWithEmail_withInvalidEmail_showsEmailAlert() async throws {
        sut.email           = "notanemail"
        sut.password        = "abc123"
        sut.confirmPassword = "abc123"

        try await sut.signUpWithEmail()

        XCTAssertTrue(sut.showAlert)
        XCTAssertEqual(sut.alertMsg, "Insert a valid email (ex. name@mail.com)")
    }

    func test_signUpWithEmail_withWeakPassword_doesNotCallAuth() async throws {
        sut.email           = "user@example.com"
        sut.password        = "abc"        // too short, no number
        sut.confirmPassword = "abc"

        try await sut.signUpWithEmail()

        XCTAssertEqual(mockOrchestrator.signUpEmailCallCount, 0)
    }

    func test_signUpWithEmail_withWeakPassword_showsPasswordAlert() async throws {
        sut.email           = "user@example.com"
        sut.password        = "abc"
        sut.confirmPassword = "abc"

        try await sut.signUpWithEmail()

        XCTAssertTrue(sut.showAlert)
        XCTAssertEqual(sut.alertMsg, "Password must contain at least 6 characters, 1 letter, and 1 number at least")
    }

    // MARK: - signUpWithEmail: happy path

    func test_signUpWithEmail_setsAuthTypeEmailAndPassword() async throws {
        sut.email           = "user@example.com"
        sut.password        = "abc123"
        sut.confirmPassword = "abc123"

        try await sut.signUpWithEmail()

        XCTAssertEqual(mockOrchestrator.setAuthTypeEmailAndPasswordCallCount, 1)
    }

    func test_signUpWithEmail_callsSignUpExactlyOnce() async throws {
        sut.email           = "user@example.com"
        sut.password        = "abc123"
        sut.confirmPassword = "abc123"

        try await sut.signUpWithEmail()

        XCTAssertEqual(mockOrchestrator.signUpEmailCallCount, 1)
    }

    func test_signUpWithEmail_onSuccess_callsSendVerificationEmail() async throws {
        sut.email           = "user@example.com"
        sut.password        = "abc123"
        sut.confirmPassword = "abc123"

        try await sut.signUpWithEmail()

        XCTAssertEqual(mockOrchestrator.sendVerificationEmailCallCount, 1)
    }

    func test_signUpWithEmail_onSuccess_isLoadingFalse() async throws {
        sut.email           = "user@example.com"
        sut.password        = "abc123"
        sut.confirmPassword = "abc123"

        try await sut.signUpWithEmail()

        XCTAssertFalse(sut.isLoading)
    }

    func test_signUpWithEmail_onSuccess_isSigningUpFalse() async throws {
        sut.email           = "user@example.com"
        sut.password        = "abc123"
        sut.confirmPassword = "abc123"

        try await sut.signUpWithEmail()

        XCTAssertFalse(sut.isSigningUp)
    }

    func test_signUpWithEmail_onSuccess_showAlertFalse() async throws {
        sut.email           = "user@example.com"
        sut.password        = "abc123"
        sut.confirmPassword = "abc123"

        try await sut.signUpWithEmail()

        XCTAssertFalse(sut.showAlert)
    }

    // MARK: - signUpWithEmail: Firebase-specific error messages

    func test_signUpWithEmail_emailAlreadyInUse_showsCorrectMessage() async throws {
        sut.email           = "user@example.com"
        sut.password        = "abc123"
        sut.confirmPassword = "abc123"
        let error = NSError(domain: "FIRAuthErrorDomain",
                            code: AuthErrorCode.emailAlreadyInUse.rawValue)
        mockOrchestrator.signUpEmailResult = .failure(error)

        try await sut.signUpWithEmail()

        XCTAssertTrue(sut.showAlert)
        XCTAssertEqual(sut.alertMsg, "This email is already in use. Try sign in")
    }

    func test_signUpWithEmail_invalidEmail_showsCorrectMessage() async throws {
        sut.email           = "user@example.com"
        sut.password        = "abc123"
        sut.confirmPassword = "abc123"
        let error = NSError(domain: "FIRAuthErrorDomain",
                            code: AuthErrorCode.invalidEmail.rawValue)
        mockOrchestrator.signUpEmailResult = .failure(error)

        try await sut.signUpWithEmail()

        XCTAssertTrue(sut.showAlert)
        XCTAssertEqual(sut.alertMsg, "Format of the email is wrong.")
    }

    func test_signUpWithEmail_weakPassword_showsCorrectMessage() async throws {
        sut.email           = "user@example.com"
        sut.password        = "abc123"
        sut.confirmPassword = "abc123"
        let error = NSError(domain: "FIRAuthErrorDomain",
                            code: AuthErrorCode.weakPassword.rawValue)
        mockOrchestrator.signUpEmailResult = .failure(error)

        try await sut.signUpWithEmail()

        XCTAssertTrue(sut.showAlert)
        XCTAssertEqual(sut.alertMsg, "The password is too short. (minimum 6 characters)")
    }

    func test_signUpWithEmail_genericError_showsGenericMessage() async throws {
        sut.email           = "user@example.com"
        sut.password        = "abc123"
        sut.confirmPassword = "abc123"
        mockOrchestrator.signUpEmailResult = .failure(MockAuthTestError.generic)

        try await sut.signUpWithEmail()

        XCTAssertTrue(sut.showAlert)
        // Generic / unknown error codes fall into the "Generic error:" branch
        XCTAssertTrue(
            sut.alertMsg.hasPrefix("Error:") || sut.alertMsg.hasPrefix("Generic error:"),
            "Expected a generic error message, got: \(sut.alertMsg)"
        )
    }

    // MARK: - signUpWithEmail: failure side effects

    func test_signUpWithEmail_onFailure_isLoadingFalse() async throws {
        sut.email           = "user@example.com"
        sut.password        = "abc123"
        sut.confirmPassword = "abc123"
        mockOrchestrator.signUpEmailResult = .failure(MockAuthTestError.generic)

        try await sut.signUpWithEmail()

        XCTAssertFalse(sut.isLoading)
    }

    func test_signUpWithEmail_onFailure_isSigningUpFalse() async throws {
        sut.email           = "user@example.com"
        sut.password        = "abc123"
        sut.confirmPassword = "abc123"
        mockOrchestrator.signUpEmailResult = .failure(MockAuthTestError.generic)

        try await sut.signUpWithEmail()

        XCTAssertFalse(sut.isSigningUp)
    }

    func test_signUpWithEmail_onFailure_doesNotSendVerificationEmail() async throws {
        sut.email           = "user@example.com"
        sut.password        = "abc123"
        sut.confirmPassword = "abc123"
        mockOrchestrator.signUpEmailResult = .failure(MockAuthTestError.network)

        try await sut.signUpWithEmail()

        XCTAssertEqual(mockOrchestrator.sendVerificationEmailCallCount, 0)
    }

    // MARK: - validateEmail

    func test_validateEmail_whenEmailIsTaken_setsEmailValidationFailed() async throws {
        sut.email = "taken@example.com"
        mockEmailChecker.stubbedResult = .success(true)

        try await sut.validateEmail()

        XCTAssertTrue(sut.emailValidationFailed)
    }

    func test_validateEmail_whenEmailIsTaken_emailIsValidFalse() async throws {
        sut.email = "taken@example.com"
        mockEmailChecker.stubbedResult = .success(true)

        try await sut.validateEmail()

        XCTAssertFalse(sut.emailIsValid)
    }

    func test_validateEmail_whenEmailIsAvailable_emailIsValidTrue() async throws {
        sut.email = "new@example.com"
        mockEmailChecker.stubbedResult = .success(false)

        try await sut.validateEmail()

        XCTAssertTrue(sut.emailIsValid)
    }

    func test_validateEmail_whenEmailIsAvailable_emailValidationFailedFalse() async throws {
        sut.email = "new@example.com"
        mockEmailChecker.stubbedResult = .success(false)

        try await sut.validateEmail()

        XCTAssertFalse(sut.emailValidationFailed)
    }

    func test_validateEmail_passesCorrectEmailToChecker() async throws {
        sut.email = "check@sbud.com"
        mockEmailChecker.stubbedResult = .success(false)

        try await sut.validateEmail()

        XCTAssertEqual(mockEmailChecker.isEmailTakenCalledWithEmail, "check@sbud.com")
    }

    func test_validateEmail_callsCheckerExactlyOnce() async throws {
        sut.email = "user@example.com"

        try await sut.validateEmail()

        XCTAssertEqual(mockEmailChecker.isEmailTakenCallCount, 1)
    }

    func test_validateEmail_resetsEmailValidationFailedBeforeCheck() async throws {
        sut.emailValidationFailed = true   // pre-set stale state
        sut.email = "user@example.com"
        mockEmailChecker.stubbedResult = .success(false)

        try await sut.validateEmail()

        XCTAssertFalse(sut.emailValidationFailed)
    }

    func test_validateEmail_isLoadingFalseAfterSuccess() async throws {
        sut.email = "user@example.com"

        try await sut.validateEmail()

        XCTAssertFalse(sut.isLoading)
    }

    func test_validateEmail_onCheckerThrow_propagatesError() async {
        sut.email = "user@example.com"
        mockEmailChecker.stubbedResult = .failure(MockAuthTestError.network)

        do {
            try await sut.validateEmail()
            XCTFail("Expected error to be thrown")
        } catch {
            XCTAssertEqual(error as? MockAuthTestError, .network)
        }
    }

    // MARK: - signUpWithGoogle

    func test_signUpWithGoogle_setsAuthTypeGoogle() async {
        await sut.signUpWithGoogle()

        XCTAssertEqual(mockOrchestrator.setAuthTypeGoogleCallCount, 1)
    }

    func test_signUpWithGoogle_callsSignUpOnce() async {
        await sut.signUpWithGoogle()

        XCTAssertEqual(mockOrchestrator.signUpNoArgsCallCount, 1)
    }

    func test_signUpWithGoogle_onSuccess_showAlertFalse() async {
        mockOrchestrator.signUpResult = .success(())

        await sut.signUpWithGoogle()

        XCTAssertFalse(sut.showAlert)
    }

    func test_signUpWithGoogle_onFailure_showsAlert() async {
        mockOrchestrator.signUpResult = .failure(MockAuthTestError.generic)

        await sut.signUpWithGoogle()

        XCTAssertTrue(sut.showAlert)
    }

    func test_signUpWithGoogle_onFailure_showsCorrectMessage() async {
        mockOrchestrator.signUpResult = .failure(MockAuthTestError.generic)

        await sut.signUpWithGoogle()

        XCTAssertEqual(sut.alertMsg, "Problem with user registration, please try again")
    }

    func test_signUpWithGoogle_doesNotCallEmailSignUp() async {
        await sut.signUpWithGoogle()

        XCTAssertEqual(mockOrchestrator.signUpEmailCallCount, 0)
    }

}
