//
//  AuthIntegrationTests.swift
//  sbudTests
//
//  Integration tests for the auth module.
//  What's real: SignInViewModel, SignUpViewModel, InputValidators, AuthenticationManagerGoogle.
//  What's mocked: IAuthOrchestrator, IEmailExistenceChecker, IGoogleSignUpManager (external boundaries).
//
//  These tests verify that:
//  - Real validation logic flows through to real auth calls correctly.
//  - Error messages are wired to the right ViewModel properties end-to-end.
//  - The Google manager's routing logic works with a real AuthenticationManagerGoogle.
//

import XCTest
import FirebaseAuth
@testable import sbud

@MainActor
final class AuthIntegrationTests: XCTestCase {

    private var mockOrchestrator: MockAuthOrchestrator!
    private var mockEmailChecker: MockEmailExistenceChecker!
    private var mockGoogleManager: MockGoogleSignUpManager!
    private var signInVM: SignInViewModel!
    private var signUpVM: SignUpViewModel!
    private var googleAuthManager: AuthenticationManagerGoogle!

    override func setUp() {
        super.setUp()
        mockOrchestrator  = MockAuthOrchestrator()
        mockEmailChecker  = MockEmailExistenceChecker()
        mockGoogleManager = MockGoogleSignUpManager()
        signInVM          = SignInViewModel(authManager: mockOrchestrator)
        signUpVM          = SignUpViewModel(authManager: mockOrchestrator, emailChecker: mockEmailChecker)
        googleAuthManager = AuthenticationManagerGoogle(googleSignUpManager: mockGoogleManager)
    }

    override func tearDown() {
        signInVM          = nil
        signUpVM          = nil
        mockOrchestrator  = nil
        mockEmailChecker  = nil
        mockGoogleManager = nil
        googleAuthManager = nil
        super.tearDown()
    }

    // MARK: - Sign-in: full validation → auth pipeline

    func test_signIn_validCredentials_authCalledOnce() async throws {
        signInVM.email    = "athlete@sbud.com"
        signInVM.password = "secure1"

        try await signInVM.singInWithEmail()

        XCTAssertEqual(mockOrchestrator.signInEmailCallCount, 1)
        XCTAssertFalse(signInVM.showAlert)
    }

    func test_signIn_invalidEmail_blocksAuthAndShowsEmailAlert() async throws {
        signInVM.email    = "not-an-email"
        signInVM.password = "secure1"

        try await signInVM.singInWithEmail()

        XCTAssertEqual(mockOrchestrator.signInEmailCallCount, 0)
        XCTAssertTrue(signInVM.showAlert)
        XCTAssertEqual(signInVM.alertMsg, "Insert a valid email (ex. name@mail.com)")
    }

    func test_signIn_passwordWithoutNumber_blocksAuth() async throws {
        signInVM.email    = "athlete@sbud.com"
        signInVM.password = "abcdefg"   // letters only

        try await signInVM.singInWithEmail()

        XCTAssertEqual(mockOrchestrator.signInEmailCallCount, 0)
        XCTAssertTrue(signInVM.showAlert)
        XCTAssertEqual(signInVM.alertMsg,
                       "Password must contain at least 6 characters, 1 letter, and 1 number at least")
    }

    func test_signIn_authFailure_showsWrongCredentialsAlert() async throws {
        signInVM.email    = "athlete@sbud.com"
        signInVM.password = "secure1"
        mockOrchestrator.signInEmailResult = .failure(MockAuthTestError.generic)

        try await signInVM.singInWithEmail()

        XCTAssertTrue(signInVM.showAlert)
        XCTAssertEqual(signInVM.alertMsg, "Email or password are incorrect, please try again")
        XCTAssertFalse(signInVM.isLoading)
        XCTAssertFalse(signInVM.isSigningIn)
    }

    func test_signIn_successResetsAllLoadingState() async throws {
        signInVM.email    = "athlete@sbud.com"
        signInVM.password = "secure1"

        try await signInVM.singInWithEmail()

        XCTAssertFalse(signInVM.isLoading)
        XCTAssertFalse(signInVM.isSigningIn)
        XCTAssertFalse(signInVM.showAlert)
    }

    // MARK: - Sign-up: full validation → auth pipeline

    func test_signUp_validInputs_callsAuthAndVerification() async throws {
        signUpVM.email           = "newuser@sbud.com"
        signUpVM.password        = "secure1"
        signUpVM.confirmPassword = "secure1"

        try await signUpVM.signUpWithEmail()

        XCTAssertEqual(mockOrchestrator.signUpEmailCallCount, 1)
        XCTAssertEqual(mockOrchestrator.sendVerificationEmailCallCount, 1)
        XCTAssertFalse(signUpVM.showAlert)
    }

    func test_signUp_passwordMismatch_blocksAll() async throws {
        signUpVM.email           = "newuser@sbud.com"
        signUpVM.password        = "secure1"
        signUpVM.confirmPassword = "different"

        try await signUpVM.signUpWithEmail()

        XCTAssertEqual(mockOrchestrator.signUpEmailCallCount, 0)
        XCTAssertEqual(mockOrchestrator.sendVerificationEmailCallCount, 0)
    }

    func test_signUp_emailAlreadyInUse_showsSpecificMessage() async throws {
        signUpVM.email           = "taken@sbud.com"
        signUpVM.password        = "secure1"
        signUpVM.confirmPassword = "secure1"
        let error = NSError(domain: "FIRAuthErrorDomain",
                            code: AuthErrorCode.emailAlreadyInUse.rawValue)
        mockOrchestrator.signUpEmailResult = .failure(error)

        try await signUpVM.signUpWithEmail()

        XCTAssertTrue(signUpVM.showAlert)
        XCTAssertEqual(signUpVM.alertMsg, "This email is already in use. Try sign in")
        XCTAssertEqual(mockOrchestrator.sendVerificationEmailCallCount, 0,
                       "Verification email must not be sent after a failed registration")
    }

    func test_signUp_authFailure_resetsLoadingAndSigningUp() async throws {
        signUpVM.email           = "newuser@sbud.com"
        signUpVM.password        = "secure1"
        signUpVM.confirmPassword = "secure1"
        mockOrchestrator.signUpEmailResult = .failure(MockAuthTestError.generic)

        try await signUpVM.signUpWithEmail()

        XCTAssertFalse(signUpVM.isLoading)
        XCTAssertFalse(signUpVM.isSigningUp)
    }

    // MARK: - validateEmail integration

    func test_validateEmail_takenEmail_updatesAllFlags() async throws {
        signUpVM.email = "taken@sbud.com"
        mockEmailChecker.stubbedResult = .success(true)

        try await signUpVM.validateEmail()

        XCTAssertTrue(signUpVM.emailValidationFailed)
        XCTAssertFalse(signUpVM.emailIsValid)
        XCTAssertFalse(signUpVM.isLoading)
        XCTAssertEqual(mockEmailChecker.isEmailTakenCalledWithEmail, "taken@sbud.com")
    }

    func test_validateEmail_availableEmail_updatesAllFlags() async throws {
        signUpVM.email = "free@sbud.com"
        mockEmailChecker.stubbedResult = .success(false)

        try await signUpVM.validateEmail()

        XCTAssertFalse(signUpVM.emailValidationFailed)
        XCTAssertTrue(signUpVM.emailIsValid)
        XCTAssertFalse(signUpVM.isLoading)
    }

    func test_validateEmail_consecutiveCalls_alwaysResetsFailedFlag() async throws {
        signUpVM.email = "first@sbud.com"
        mockEmailChecker.stubbedResult = .success(true)
        try await signUpVM.validateEmail()
        XCTAssertTrue(signUpVM.emailValidationFailed)

        // Second call with available email — failed flag must clear
        signUpVM.email = "second@sbud.com"
        mockEmailChecker.stubbedResult = .success(false)
        try await signUpVM.validateEmail()

        XCTAssertFalse(signUpVM.emailValidationFailed)
        XCTAssertTrue(signUpVM.emailIsValid)
    }

    // MARK: - Forgot password integration

    func test_forgotPassword_validEmail_callsResetAndShowsConfirmation() async {
        signInVM.email = "reset@sbud.com"

        await signInVM.forgotPassword()

        XCTAssertEqual(mockOrchestrator.sendPasswordResetCallCount, 1)
        XCTAssertEqual(mockOrchestrator.sendPasswordResetCalledWithEmail, "reset@sbud.com")
        XCTAssertTrue(signInVM.showAlert)
        XCTAssertEqual(signInVM.alertMsg, "Password reset email sent! Check your inbox.")
        XCTAssertFalse(signInVM.isLoading)
    }

    func test_forgotPassword_emptyEmail_neverCallsReset() async {
        signInVM.email = ""

        await signInVM.forgotPassword()

        XCTAssertEqual(mockOrchestrator.sendPasswordResetCallCount, 0)
        XCTAssertEqual(signInVM.alertMsg, "Please enter your email address first")
    }

    func test_forgotPassword_serviceFailure_showsErrorMessage() async {
        signInVM.email = "reset@sbud.com"
        mockOrchestrator.sendPasswordResetResult = .failure(MockAuthTestError.network)

        await signInVM.forgotPassword()

        XCTAssertTrue(signInVM.showAlert)
        XCTAssertEqual(signInVM.alertMsg,
                       "Could not send reset email. Make sure the address is correct.")
        XCTAssertFalse(signInVM.isLoading)
    }

    // MARK: - AuthenticationManagerGoogle + MockGoogleSignUpManager

    func test_googleManager_signIn_delegatesToGoogleSDK() async throws {
        try await googleAuthManager.signIn()

        XCTAssertEqual(mockGoogleManager.signUpWithGoogleCallCount, 1)
    }

    func test_googleManager_signUp_delegatesToGoogleSDK() async throws {
        try await googleAuthManager.signUp()

        XCTAssertEqual(mockGoogleManager.signUpWithGoogleCallCount, 1)
    }

    func test_googleManager_emailSignIn_throwsUnauthorized() async {
        do {
            try await googleAuthManager.signIn(email: "u@e.com", password: "pass123")
            XCTFail("Expected AuthError.unauthorizedAction")
        } catch AuthError.unauthorizedAction {
            // ✅
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func test_googleManager_emailSignUp_throwsUnauthorized() async {
        do {
            try await googleAuthManager.signUp(email: "u@e.com", password: "pass123")
            XCTFail("Expected AuthError.unauthorizedAction")
        } catch AuthError.unauthorizedAction {
            // ✅
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func test_googleManager_propagatesSDKError_throughSignIn() async {
        mockGoogleManager.stubbedResult = .failure(GoogleSignUpError.missingClientID)

        do {
            try await googleAuthManager.signIn()
            XCTFail("Expected error to be thrown")
        } catch {
            if case GoogleSignUpError.missingClientID = error { /* ✅ */ }
            else { XCTFail("Wrong error: \(error)") }
        }
    }

    func test_googleManager_propagatesSDKError_throughSignUp() async {
        mockGoogleManager.stubbedResult = .failure(GoogleSignUpError.cannotFindIdToken)

        do {
            try await googleAuthManager.signUp()
            XCTFail("Expected error to be thrown")
        } catch {
            if case GoogleSignUpError.cannotFindIdToken = error { /* ✅ */ }
            else { XCTFail("Wrong error: \(error)") }
        }
    }

    // MARK: - Google sign-in from SignInViewModel (Bug fix regression)

    func test_signInVM_googleSignIn_callsSignInOnOrchestrator() async {
        // Regression: before the fix, authManager.signIn() was commented out and never called
        await signInVM.signUpWithGoogle()

        XCTAssertEqual(mockOrchestrator.signInNoArgsCallCount, 1,
                       "Regression: signIn() must be called — it was previously commented out")
    }

    func test_signInVM_googleSignIn_setsAuthTypeGoogle() async {
        await signInVM.signUpWithGoogle()

        XCTAssertEqual(mockOrchestrator.setAuthTypeGoogleCallCount, 1)
    }
}
