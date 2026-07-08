//
//  SignInViewModelTests.swift
//  sbudTests
//

import XCTest
@testable import sbud

@MainActor
final class SignInViewModelTests: XCTestCase {

    private var sut: SignInViewModel!
    private var mockOrchestrator: MockAuthOrchestrator!

    override func setUp() {
        super.setUp()
        mockOrchestrator = MockAuthOrchestrator()
        sut = SignInViewModel(authManager: mockOrchestrator)
    }

    override func tearDown() {
        sut = nil
        mockOrchestrator = nil
        super.tearDown()
    }

    // MARK: - Initial state

    func test_initialState_emailIsEmpty() {
        XCTAssertEqual(sut.email, "")
    }

    func test_initialState_passwordIsEmpty() {
        XCTAssertEqual(sut.password, "")
    }

    func test_initialState_isLoadingFalse() {
        XCTAssertFalse(sut.isLoading)
    }

    func test_initialState_showAlertFalse() {
        XCTAssertFalse(sut.showAlert)
    }

    func test_initialState_isSigningInFalse() {
        XCTAssertFalse(sut.isSigningIn)
    }

    // MARK: - singInWithEmail: validation guards

    func test_singInWithEmail_withInvalidEmail_doesNotCallAuth() async throws {
        sut.email = "notanemail"
        sut.password = "abc123"

        try await sut.singInWithEmail()

        XCTAssertEqual(mockOrchestrator.signInEmailCallCount, 0)
    }

    func test_singInWithEmail_withInvalidEmail_showsAlert() async throws {
        sut.email = "notanemail"
        sut.password = "abc123"

        try await sut.singInWithEmail()

        XCTAssertTrue(sut.showAlert)
        XCTAssertEqual(sut.alertMsg, "Insert a valid email (ex. name@mail.com)")
    }

    func test_singInWithEmail_withEmptyEmail_doesNotCallAuth() async throws {
        sut.email = ""
        sut.password = "abc123"

        try await sut.singInWithEmail()

        XCTAssertEqual(mockOrchestrator.signInEmailCallCount, 0)
    }

    func test_singInWithEmail_withWeakPassword_doesNotCallAuth() async throws {
        sut.email = "user@example.com"
        sut.password = "abc"            // too short, no number

        try await sut.singInWithEmail()

        XCTAssertEqual(mockOrchestrator.signInEmailCallCount, 0)
    }

    func test_singInWithEmail_withWeakPassword_showsPasswordAlert() async throws {
        sut.email = "user@example.com"
        sut.password = "abc"

        try await sut.singInWithEmail()

        XCTAssertTrue(sut.showAlert)
        XCTAssertEqual(sut.alertMsg, "Password must contain at least 6 characters, 1 letter, and 1 number at least")
    }

    func test_singInWithEmail_withOnlyNumbersPassword_doesNotCallAuth() async throws {
        sut.email = "user@example.com"
        sut.password = "123456"         // no letter

        try await sut.singInWithEmail()

        XCTAssertEqual(mockOrchestrator.signInEmailCallCount, 0)
    }

    // MARK: - singInWithEmail: happy path

    func test_singInWithEmail_setsAuthTypeEmailAndPassword() async throws {
        sut.email = "user@example.com"
        sut.password = "abc123"

        try await sut.singInWithEmail()

        XCTAssertEqual(mockOrchestrator.setAuthTypeEmailAndPasswordCallCount, 1)
    }

    func test_singInWithEmail_callsSignInExactlyOnce() async throws {
        sut.email = "user@example.com"
        sut.password = "abc123"

        try await sut.singInWithEmail()

        XCTAssertEqual(mockOrchestrator.signInEmailCallCount, 1)
    }

    func test_singInWithEmail_onSuccess_isLoadingFalse() async throws {
        sut.email = "user@example.com"
        sut.password = "abc123"

        try await sut.singInWithEmail()

        XCTAssertFalse(sut.isLoading)
    }

    func test_singInWithEmail_onSuccess_isSigningInFalse() async throws {
        sut.email = "user@example.com"
        sut.password = "abc123"

        try await sut.singInWithEmail()

        XCTAssertFalse(sut.isSigningIn)
    }

    func test_singInWithEmail_onSuccess_showAlertFalse() async throws {
        sut.email = "user@example.com"
        sut.password = "abc123"

        try await sut.singInWithEmail()

        XCTAssertFalse(sut.showAlert)
    }

    // MARK: - singInWithEmail: failure path

    func test_singInWithEmail_onAuthFailure_showsAlert() async throws {
        sut.email = "user@example.com"
        sut.password = "abc123"
        mockOrchestrator.signInEmailResult = .failure(MockAuthTestError.generic)

        try await sut.singInWithEmail()

        XCTAssertTrue(sut.showAlert)
    }

    func test_singInWithEmail_onAuthFailure_showsCorrectMessage() async throws {
        sut.email = "user@example.com"
        sut.password = "abc123"
        mockOrchestrator.signInEmailResult = .failure(MockAuthTestError.generic)

        try await sut.singInWithEmail()

        XCTAssertEqual(sut.alertMsg, "Email or password are incorrect, please try again")
    }

    func test_singInWithEmail_onAuthFailure_isLoadingFalse() async throws {
        sut.email = "user@example.com"
        sut.password = "abc123"
        mockOrchestrator.signInEmailResult = .failure(MockAuthTestError.network)

        try await sut.singInWithEmail()

        XCTAssertFalse(sut.isLoading)
    }

    func test_singInWithEmail_onAuthFailure_isSigningInFalse() async throws {
        sut.email = "user@example.com"
        sut.password = "abc123"
        mockOrchestrator.signInEmailResult = .failure(MockAuthTestError.network)

        try await sut.singInWithEmail()

        XCTAssertFalse(sut.isSigningIn)
    }

    // MARK: - forgotPassword

    func test_forgotPassword_withEmptyEmail_showsRequiredAlert() async {
        sut.email = ""

        await sut.forgotPassword()

        XCTAssertTrue(sut.showAlert)
        XCTAssertEqual(sut.alertMsg, "Please enter your email address first")
    }

    func test_forgotPassword_withEmptyEmail_doesNotCallResetService() async {
        sut.email = ""

        await sut.forgotPassword()

        XCTAssertEqual(mockOrchestrator.sendPasswordResetCallCount, 0)
    }

    func test_forgotPassword_withEmail_callsResetServiceOnce() async {
        sut.email = "user@example.com"

        await sut.forgotPassword()

        XCTAssertEqual(mockOrchestrator.sendPasswordResetCallCount, 1)
    }

    func test_forgotPassword_passesEmailToResetService() async {
        sut.email = "athlete@sbud.com"

        await sut.forgotPassword()

        XCTAssertEqual(mockOrchestrator.sendPasswordResetCalledWithEmail, "athlete@sbud.com")
    }

    func test_forgotPassword_onSuccess_showsSuccessAlert() async {
        sut.email = "user@example.com"
        mockOrchestrator.sendPasswordResetResult = .success(())

        await sut.forgotPassword()

        XCTAssertTrue(sut.showAlert)
        XCTAssertEqual(sut.alertMsg, "Password reset email sent! Check your inbox.")
    }

    func test_forgotPassword_onSuccess_isLoadingFalse() async {
        sut.email = "user@example.com"

        await sut.forgotPassword()

        XCTAssertFalse(sut.isLoading)
    }

    func test_forgotPassword_onFailure_showsErrorAlert() async {
        sut.email = "user@example.com"
        mockOrchestrator.sendPasswordResetResult = .failure(MockAuthTestError.network)

        await sut.forgotPassword()

        XCTAssertTrue(sut.showAlert)
        XCTAssertEqual(sut.alertMsg, "Could not send reset email. Make sure the address is correct.")
    }

    func test_forgotPassword_onFailure_isLoadingFalse() async {
        sut.email = "user@example.com"
        mockOrchestrator.sendPasswordResetResult = .failure(MockAuthTestError.network)

        await sut.forgotPassword()

        XCTAssertFalse(sut.isLoading)
    }

    // MARK: - signUpWithGoogle (Bug fix regression — was silently commented out before)

    func test_signUpWithGoogle_setsAuthTypeGoogle() async {
        await sut.signUpWithGoogle()

        XCTAssertEqual(mockOrchestrator.setAuthTypeGoogleCallCount, 1)
    }

    func test_signUpWithGoogle_callsSignInOnce() async {
        // Regression: signIn() was commented out — verify it is now called
        await sut.signUpWithGoogle()

        XCTAssertEqual(mockOrchestrator.signInNoArgsCallCount, 1)
    }

    func test_signUpWithGoogle_onSuccess_doesNotShowAlert() async {
        mockOrchestrator.signInResult = .success(())

        await sut.signUpWithGoogle()

        XCTAssertFalse(sut.showAlert)
    }

    func test_signUpWithGoogle_onFailure_showsAlert() async {
        mockOrchestrator.signInResult = .failure(MockAuthTestError.generic)

        await sut.signUpWithGoogle()

        XCTAssertTrue(sut.showAlert)
    }

    func test_signUpWithGoogle_onFailure_showsCorrectMessage() async {
        mockOrchestrator.signInResult = .failure(MockAuthTestError.generic)

        await sut.signUpWithGoogle()

        XCTAssertEqual(sut.alertMsg, "Problem with user registration, please try again")
    }

    func test_signUpWithGoogle_doesNotCallEmailSignIn() async {
        await sut.signUpWithGoogle()

        XCTAssertEqual(mockOrchestrator.signInEmailCallCount, 0)
    }

    // MARK: - setCoordinator

    func test_setCoordinator_assignsCoordinator() {
        // Coordinator is optional — we just verify nothing crashes when nil
        sut.setCoordinator(coordinator: MainCoordinator(
            authService: AuthenticationManager.shared,
            profileService: ProfileManager.shared
        ))
        XCTAssertNotNil(sut.coordinator)
    }

}
