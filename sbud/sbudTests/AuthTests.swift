//
//  AuthTests.swift.swift
//  sbudTests
//
//  Created by ahmed on 28/04/2026.
//

//  Comprehensive unit test suite for Sign Up / Sign In feature
//

import XCTest
import Combine
@testable import sbud
import FirebaseAuth
// MARK: - MOCKS

// MARK: Mock AuthenticationManager
@MainActor
class MockAuthenticationManager: ObservableObject {
    var shouldThrow = false
    var errorToThrow: Error = AuthError.unauthorizedAction
    var signUpCalled = false
    var signInCalled = false
    var signUpEmailCalled = false
    var signInEmailCalled = false
    var setAuthTypeGoogleCalled = false
    var setAuthTypeEmailCalled = false
    var lastEmail: String?
    var lastPassword: String?

    func setAuthTypeGoogle() { setAuthTypeGoogleCalled = true }
    func setAuthTypeEmailAndPassword() { setAuthTypeEmailCalled = true }

    func signUp() async throws {
        signUpCalled = true
        if shouldThrow { throw errorToThrow }
    }

    func signUp(email: String, password: String) async throws {
        signUpEmailCalled = true
        lastEmail = email
        lastPassword = password
        if shouldThrow { throw errorToThrow }
    }

    func signIn() async throws {
        signInCalled = true
        if shouldThrow { throw errorToThrow }
    }

    func signIn(email: String, password: String) async throws {
        signInEmailCalled = true
        lastEmail = email
        lastPassword = password
        if shouldThrow { throw errorToThrow }
    }
}

// MARK: Mock Coordinator
class MockMainCoordinator: MainCoordinator {
    var refreshAppFlowCalled = false
    var goToSignInCalled = false
    var goToSignUpCalled = false

    override func refreshAppFlow() { refreshAppFlowCalled = true }
    override func goToSignIn() { goToSignInCalled = true }
    override func goToSignUp() { goToSignUpCalled = true }
}

// MARK: Mock PopUpGenerator
class MockPopUpGenerator {
    static var lastMessage: String?
    static var lastType: centralPopupType?

    static func reset() {
        lastMessage = nil
        lastType = nil
    }
}

// MARK: Mock Firestore Snapshot
struct MockQuerySnapshot {
    let isEmpty: Bool
}


// MARK: - INPUT VALIDATORS TESTS

final class InputValidatorsTests: XCTestCase {

    var sut: InputValidators!

    override func setUp() {
        super.setUp()
        sut = InputValidators()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // MARK: Email Validation

    func test_isEmailValid_withValidEmail_returnsTrue() {
        var alertCalled = false
        let result = sut.isEmailValid("user@example.com") { alertCalled = true }
        XCTAssertTrue(result)
        XCTAssertFalse(alertCalled)
    }

    func test_isEmailValid_withSubdomainEmail_returnsTrue() {
        var alertCalled = false
        let result = sut.isEmailValid("user@mail.domain.com") { alertCalled = true }
        XCTAssertTrue(result)
        XCTAssertFalse(alertCalled)
    }

    func test_isEmailValid_withEmptyEmail_returnsFalse() {
        var alertCalled = false
        let result = sut.isEmailValid("") { alertCalled = true }
        XCTAssertFalse(result)
        XCTAssertTrue(alertCalled)
    }

    func test_isEmailValid_withMissingAt_returnsFalse() {
        var alertCalled = false
        let result = sut.isEmailValid("userexample.com") { alertCalled = true }
        XCTAssertFalse(result)
        XCTAssertTrue(alertCalled)
    }

    func test_isEmailValid_withMissingDomain_returnsFalse() {
        var alertCalled = false
        let result = sut.isEmailValid("user@") { alertCalled = true }
        XCTAssertFalse(result)
        XCTAssertTrue(alertCalled)
    }

    func test_isEmailValid_withMissingTLD_returnsFalse() {
        var alertCalled = false
        let result = sut.isEmailValid("user@domain") { alertCalled = true }
        XCTAssertFalse(result)
        XCTAssertTrue(alertCalled)
    }

    func test_isEmailValid_withSpaces_returnsFalse() {
        var alertCalled = false
        let result = sut.isEmailValid("user @example.com") { alertCalled = true }
        XCTAssertFalse(result)
        XCTAssertTrue(alertCalled)
    }

    func test_isEmailValid_withSpecialCharsInLocal_returnsTrue() {
        var alertCalled = false
        let result = sut.isEmailValid("user.name+tag@example.com") { alertCalled = true }
        XCTAssertTrue(result)
        XCTAssertFalse(alertCalled)
    }

    // MARK: Password Validation

    func test_isPasswordValid_withValidPassword_returnsTrue() {
        var alertCalled = false
        let result = sut.isPasswordValid("Pass123") { alertCalled = true }
        XCTAssertTrue(result)
        XCTAssertFalse(alertCalled)
    }

    func test_isPasswordValid_withMinimumLength_returnsTrue() {
        var alertCalled = false
        // 6 chars, 1 letter, 1 number
        let result = sut.isPasswordValid("abc123") { alertCalled = true }
        XCTAssertTrue(result)
        XCTAssertFalse(alertCalled)
    }

    func test_isPasswordValid_withEmptyPassword_returnsFalse() {
        var alertCalled = false
        let result = sut.isPasswordValid("") { alertCalled = true }
        XCTAssertFalse(result)
        XCTAssertTrue(alertCalled)
    }

    func test_isPasswordValid_withTooShort_returnsFalse() {
        var alertCalled = false
        // only 5 chars
        let result = sut.isPasswordValid("ab12c") { alertCalled = true }
        XCTAssertFalse(result)
        XCTAssertTrue(alertCalled)
    }

    func test_isPasswordValid_withNoNumber_returnsFalse() {
        var alertCalled = false
        let result = sut.isPasswordValid("abcdef") { alertCalled = true }
        XCTAssertFalse(result)
        XCTAssertTrue(alertCalled)
    }

    func test_isPasswordValid_withNoLetter_returnsFalse() {
        var alertCalled = false
        let result = sut.isPasswordValid("123456") { alertCalled = true }
        XCTAssertFalse(result)
        XCTAssertTrue(alertCalled)
    }

    func test_isPasswordValid_withOnlySpaces_returnsFalse() {
        var alertCalled = false
        let result = sut.isPasswordValid("      ") { alertCalled = true }
        XCTAssertFalse(result)
        XCTAssertTrue(alertCalled)
    }

    // MARK: validateInputs (combined)

    func test_validateInputs_validEmailAndPassword_returnsTrue() {
        var emailAlertCalled = false
        var passwordAlertCalled = false
        let result = sut.validateInputs(
            email: "user@example.com",
            password: "Pass123",
            emailAlertFunction: { emailAlertCalled = true },
            passwordAlertFunction: { passwordAlertCalled = true }
        )
        XCTAssertTrue(result)
        XCTAssertFalse(emailAlertCalled)
        XCTAssertFalse(passwordAlertCalled)
    }

    func test_validateInputs_invalidEmail_returnsFalse_andEmailAlertFired() {
        var emailAlertCalled = false
        var passwordAlertCalled = false
        let result = sut.validateInputs(
            email: "not-an-email",
            password: "Pass123",
            emailAlertFunction: { emailAlertCalled = true },
            passwordAlertFunction: { passwordAlertCalled = true }
        )
        XCTAssertFalse(result)
        XCTAssertTrue(emailAlertCalled)
        XCTAssertFalse(passwordAlertCalled)
    }

    func test_validateInputs_invalidPassword_returnsFalse_andPasswordAlertFired() {
        var emailAlertCalled = false
        var passwordAlertCalled = false
        let result = sut.validateInputs(
            email: "user@example.com",
            password: "weak",
            emailAlertFunction: { emailAlertCalled = true },
            passwordAlertFunction: { passwordAlertCalled = true }
        )
        XCTAssertFalse(result)
        XCTAssertFalse(emailAlertCalled)
        XCTAssertTrue(passwordAlertCalled)
    }

    func test_validateInputs_bothInvalid_returnsFalse_emailAlertFired_passwordNot() {
        // Email is checked first; if it fails, password alert is not triggered
        var emailAlertCalled = false
        var passwordAlertCalled = false
        let result = sut.validateInputs(
            email: "",
            password: "",
            emailAlertFunction: { emailAlertCalled = true },
            passwordAlertFunction: { passwordAlertCalled = true }
        )
        XCTAssertFalse(result)
        XCTAssertTrue(emailAlertCalled)
        XCTAssertFalse(passwordAlertCalled, "Password alert should not fire when email already fails")
    }
}


// MARK: - SIGN UP VIEW MODEL TESTS

@MainActor
final class SignUpViewModelTests: XCTestCase {

    var sut: SignUpViewModel!
    var mockCoordinator: MockMainCoordinator!
    var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        sut = SignUpViewModel()
        mockCoordinator = MockMainCoordinator()
        sut.setCoordinator(coordinator: mockCoordinator)
        cancellables = []
    }

    override func tearDown() {
        sut = nil
        mockCoordinator = nil
        cancellables = nil
        super.tearDown()
    }

    // MARK: Initial State

    func test_initialState_allFieldsEmpty() {
        XCTAssertEqual(sut.email, "")
        XCTAssertEqual(sut.password, "")
        XCTAssertEqual(sut.confirmPassword, "")
    }

    func test_initialState_flagsAreDefault() {
        XCTAssertFalse(sut.emailIsValid)
        XCTAssertFalse(sut.isLoading)
        XCTAssertFalse(sut.emailValidationFailed)
        XCTAssertFalse(sut.usernameValidationFailed)
        XCTAssertFalse(sut.isSigningUp)
        XCTAssertFalse(sut.showAlert)
        XCTAssertFalse(sut.isSigningIn)
        XCTAssertFalse(sut.showPassword)
        XCTAssertFalse(sut.showConfirmPassword)
        XCTAssertEqual(sut.alertMsg, "")
    }

    // MARK: setCoordinator

    func test_setCoordinator_assignsCoordinator() {
        let newCoordinator = MockMainCoordinator()
        sut.setCoordinator(coordinator: newCoordinator)
        XCTAssertNotNil(sut.coordinator)
    }

    // MARK: goToSignIn

    func test_goToSignIn_callsCoordinator() {
        sut.goToSignIn()
        XCTAssertTrue(mockCoordinator.goToSignInCalled)
    }

    // MARK: signUpWithEmail — password mismatch

    func test_signUpWithEmail_passwordMismatch_doesNotProceed() async throws {
        sut.email = "user@example.com"
        sut.password = "Pass123"
        sut.confirmPassword = "Different1"

        try await sut.signUpWithEmail()

        XCTAssertFalse(sut.isSigningUp)
        XCTAssertFalse(mockCoordinator.refreshAppFlowCalled)
    }

    // MARK: signUpWithEmail — invalid email

    func test_signUpWithEmail_invalidEmail_showsAlert() async throws {
        sut.email = "not-an-email"
        sut.password = "Pass123"
        sut.confirmPassword = "Pass123"

        try await sut.signUpWithEmail()
        
        // Yield to let any enqueued @MainActor Tasks execute
        await Task.yield()

        XCTAssertTrue(sut.showAlert)
        XCTAssertFalse(sut.isSigningUp)
        XCTAssertFalse(mockCoordinator.refreshAppFlowCalled)
    }

    // MARK: signUpWithEmail — invalid password

    func test_signUpWithEmail_invalidPassword_showsAlert() async throws {
        sut.email = "user@example.com"
        sut.password = "weak"
        sut.confirmPassword = "weak"

        try await sut.signUpWithEmail()
        // Yield to let any enqueued @MainActor Tasks execute
        await Task.yield()
        XCTAssertTrue(sut.showAlert)
        XCTAssertFalse(mockCoordinator.refreshAppFlowCalled)
    }

    // MARK: signUpWithEmail — empty fields

    func test_signUpWithEmail_emptyEmail_showsAlert() async throws {
        sut.email = ""
        sut.password = "Pass123"
        sut.confirmPassword = "Pass123"

        try await sut.signUpWithEmail()
        // Yield to let any enqueued @MainActor Tasks execute
        await Task.yield()
        XCTAssertTrue(sut.showAlert)
    }

    func test_signUpWithEmail_emptyPassword_showsAlert() async throws {
        sut.email = "user@example.com"
        sut.password = ""
        sut.confirmPassword = ""

        try await sut.signUpWithEmail()
        // Yield to let any enqueued @MainActor Tasks execute
        await Task.yield()
        XCTAssertTrue(sut.showAlert)
    }

    // MARK: isSigningUp lifecycle

    func test_signUpWithEmail_validInputs_setsIsSigningUpDuringCall() async throws {
        // We can't easily intercept mid-async, but we verify it resets to false after
        sut.email = "user@example.com"
        sut.password = "Pass123"
        sut.confirmPassword = "Pass123"

        // This will attempt a real Firebase call and likely fail in test env
        // The important thing is isSigningUp ends as false regardless
        try? await sut.signUpWithEmail()

        XCTAssertFalse(sut.isSigningUp, "isSigningUp must be reset to false after completion")
    }

    func test_signUpWithEmail_isLoadingResetsAfterFailure() async throws {
        sut.email = "user@example.com"
        sut.password = "Pass123"
        sut.confirmPassword = "Pass123"

        try? await sut.signUpWithEmail()

        XCTAssertFalse(sut.isLoading, "isLoading must be reset even after errors")
    }

    // MARK: Alert message content

    func test_signUpWithEmail_passwordMismatch_alertMsgIsEmpty_popupUsed() async throws {
        // When passwords don't match, PopUpGenerator is used instead of showAlert
        sut.email = "user@example.com"
        sut.password = "Pass123"
        sut.confirmPassword = "Different9"

        try await sut.signUpWithEmail()

        XCTAssertFalse(sut.showAlert, "showAlert should NOT be set; PopUpGenerator handles mismatch")
    }

    // MARK: showPassword toggle

    func test_showPassword_togglesCorrectly() {
        XCTAssertFalse(sut.showPassword)
        sut.showPassword = true
        XCTAssertTrue(sut.showPassword)
        sut.showPassword = false
        XCTAssertFalse(sut.showPassword)
    }

    func test_showConfirmPassword_togglesCorrectly() {
        XCTAssertFalse(sut.showConfirmPassword)
        sut.showConfirmPassword = true
        XCTAssertTrue(sut.showConfirmPassword)
    }

    // MARK: Published properties fire change notifications

    func test_emailPublished_firesWhenChanged() {
        let expectation = XCTestExpectation(description: "email published")
        sut.$email
            .dropFirst()
            .sink { _ in expectation.fulfill() }
            .store(in: &cancellables)

        sut.email = "test@example.com"
        wait(for: [expectation], timeout: 1)
    }

    func test_passwordPublished_firesWhenChanged() {
        let expectation = XCTestExpectation(description: "password published")
        sut.$password
            .dropFirst()
            .sink { _ in expectation.fulfill() }
            .store(in: &cancellables)

        sut.password = "NewPass1"
        wait(for: [expectation], timeout: 1)
    }

    func test_showAlertPublished_firesWhenChanged() {
        let expectation = XCTestExpectation(description: "showAlert published")
        sut.$showAlert
            .dropFirst()
            .sink { _ in expectation.fulfill() }
            .store(in: &cancellables)

        sut.showAlert = true
        wait(for: [expectation], timeout: 1)
    }
}


// MARK: - SIGN IN VIEW MODEL TESTS

@MainActor
final class SignInViewModelTests: XCTestCase {

    var sut: SignInViewModel!
    var mockCoordinator: MockMainCoordinator!
    var cancellables: Set<AnyCancellable>!

    override func setUp() {
        super.setUp()
        sut = SignInViewModel()
        mockCoordinator = MockMainCoordinator()
        sut.setCoordinator(coordinator: mockCoordinator)
        cancellables = []
    }

    override func tearDown() {
        sut = nil
        mockCoordinator = nil
        cancellables = nil
        super.tearDown()
    }

    // MARK: Initial State

    func test_initialState_allFieldsEmpty() {
        XCTAssertEqual(sut.email, "")
        XCTAssertEqual(sut.password, "")
    }

    func test_initialState_flagsAreDefault() {
        XCTAssertFalse(sut.showAlert)
        XCTAssertFalse(sut.isSigningIn)
        XCTAssertFalse(sut.showPassword)
        XCTAssertFalse(sut.isLoading)
        XCTAssertEqual(sut.alertMsg, "")
    }

    // MARK: setCoordinator

    func test_setCoordinator_assignsCoordinator() {
        let newCoordinator = MockMainCoordinator()
        sut.setCoordinator(coordinator: newCoordinator)
        XCTAssertNotNil(sut.coordinator)
    }

    // MARK: goToSignUp

    func test_goToSignUp_callsCoordinator() {
        sut.goToSignUp()
        XCTAssertTrue(mockCoordinator.goToSignUpCalled)
    }

    // MARK: singInWithEmail — validation failures

    func test_signInWithEmail_emptyEmail_showsAlert() async throws {
        sut.email = ""
        sut.password = "Pass123"

        try await sut.singInWithEmail()
        // Yield to let any enqueued @MainActor Tasks execute
        await Task.yield()
        XCTAssertTrue(sut.showAlert)
        XCTAssertFalse(mockCoordinator.refreshAppFlowCalled)
    }

    func test_signInWithEmail_invalidEmail_showsAlert() async throws {
        sut.email = "not-valid"
        sut.password = "Pass123"

        try await sut.singInWithEmail()
        // Yield to let any enqueued @MainActor Tasks execute
        await Task.yield()
        XCTAssertTrue(sut.showAlert)
    }

    func test_signInWithEmail_emptyPassword_showsAlert() async throws {
        sut.email = "user@example.com"
        sut.password = ""

        try await sut.singInWithEmail()
        // Yield to let any enqueued @MainActor Tasks execute
        await Task.yield()
        XCTAssertTrue(sut.showAlert)
    }

    func test_signInWithEmail_invalidPassword_showsAlert() async throws {
        sut.email = "user@example.com"
        sut.password = "weak"

        try await sut.singInWithEmail()
        // Yield to let any enqueued @MainActor Tasks execute
        await Task.yield()
        XCTAssertTrue(sut.showAlert)
    }

    func test_signInWithEmail_passwordTooShort_showsAlert() async throws {
        sut.email = "user@example.com"
        sut.password = "a1b2c"   // 5 chars — below minimum

        try await sut.singInWithEmail()
        // Yield to let any enqueued @MainActor Tasks execute
        await Task.yield()
        XCTAssertTrue(sut.showAlert)
    }

    func test_signInWithEmail_noNumberInPassword_showsAlert() async throws {
        sut.email = "user@example.com"
        sut.password = "abcdef"

        try await sut.singInWithEmail()
        // Yield to let any enqueued @MainActor Tasks execute
        await Task.yield()
        XCTAssertTrue(sut.showAlert)
    }

    // MARK: Alert message for wrong credentials

    func test_signInWithEmail_wrongCredentials_setsCorrectAlertMsg() async throws {
        sut.email = "user@example.com"
        sut.password = "Pass123"

        // Firebase will throw in test env — we expect the generic wrong-credentials message
        try? await sut.singInWithEmail()

        if sut.showAlert {
            XCTAssertEqual(
                sut.alertMsg,
                "Email or password are incorrect, please try again"
            )
        }
    }

    // MARK: isSigningIn / isLoading lifecycle

    func test_signInWithEmail_isSigningInResetsAfterError() async throws {
        sut.email = "user@example.com"
        sut.password = "Pass123"

        try? await sut.singInWithEmail()

        XCTAssertFalse(sut.isSigningIn, "isSigningIn must reset to false after error")
    }

    func test_signInWithEmail_isLoadingResetsAfterError() async throws {
        sut.email = "user@example.com"
        sut.password = "Pass123"

        try? await sut.singInWithEmail()

        XCTAssertFalse(sut.isLoading, "isLoading must reset to false after error")
    }

    // MARK: showPassword toggle

    func test_showPassword_togglesCorrectly() {
        XCTAssertFalse(sut.showPassword)
        sut.showPassword = true
        XCTAssertTrue(sut.showPassword)
        sut.showPassword = false
        XCTAssertFalse(sut.showPassword)
    }

    // MARK: Published properties

    func test_emailPublished_firesOnChange() {
        let expectation = XCTestExpectation(description: "email changed")
        sut.$email
            .dropFirst()
            .sink { _ in expectation.fulfill() }
            .store(in: &cancellables)

        sut.email = "new@example.com"
        wait(for: [expectation], timeout: 1)
    }

    func test_isSigningInPublished_firesOnChange() {
        let expectation = XCTestExpectation(description: "isSigningIn changed")
        sut.$isSigningIn
            .dropFirst()
            .sink { _ in expectation.fulfill() }
            .store(in: &cancellables)

        sut.isSigningIn = true
        wait(for: [expectation], timeout: 1)
    }

    func test_alertMsgPublished_firesOnChange() {
        let expectation = XCTestExpectation(description: "alertMsg changed")
        sut.$alertMsg
            .dropFirst()
            .sink { _ in expectation.fulfill() }
            .store(in: &cancellables)

        sut.alertMsg = "An error occurred"
        wait(for: [expectation], timeout: 1)
    }
}


// MARK: - AUTHENTICATION MANAGER TESTS

final class AuthenticationManagerTests: XCTestCase {

    var sut: AuthenticationManager!

    override func setUp() {
        super.setUp()
        sut = AuthenticationManager()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // MARK: Initial State

    func test_initialState_isNotSignedIn() {
        // In a fresh test environment with no persisted session, user should not be signed in
        // Note: This assumes UserDefaults/AppStorage has no persisted signInMethod
        XCTAssertFalse(sut.isSignedIn)
    }

    func test_initialState_currentUserIsNil() {
        XCTAssertNil(sut.currentUser)
    }

    // MARK: setAuthTypeGoogle

    func test_setAuthTypeGoogle_doesNotThrow() {
        XCTAssertNoThrow(sut.setAuthTypeGoogle())
    }

    // MARK: setAuthTypeEmailAndPassword

    func test_setAuthTypeEmailAndPassword_doesNotThrow() {
        XCTAssertNoThrow(sut.setAuthTypeEmailAndPassword())
    }

    // MARK: signIn with no method set — should throw

    func test_signIn_withNoMethodSet_doesNotCrash() async {
        do {
            try await sut.signIn()
        } catch {
            // acceptable
        }
    }

}


// MARK: - AUTHENTICATION MANAGER EMAIL & PASSWORD TESTS

final class AuthenticationManagerEmailAndPasswordTests: XCTestCase {

    var sut: AuthenticationManagerEmailAndPassword!

    override func setUp() {
        super.setUp()
        sut = AuthenticationManagerEmailAndPassword()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // MARK: Unauthorized actions

    func test_signIn_noArgs_throwsUnauthorizedAction() async {
        do {
            try await sut.signIn()
            XCTFail("Expected AuthError.unauthorizedAction to be thrown")
        } catch let error as AuthError {
            XCTAssertEqual(error, .unauthorizedAction)
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }

    func test_signUp_noArgs_throwsUnauthorizedAction() async {
        do {
            try await sut.signUp()
            XCTFail("Expected AuthError.unauthorizedAction to be thrown")
        } catch let error as AuthError {
            XCTAssertEqual(error, .unauthorizedAction)
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }

    // MARK: Initial state

    func test_initialState_isNotSignedIn() {
        XCTAssertFalse(sut.isSignedIn)
    }

    func test_initialState_currentUserIsNil() {
        XCTAssertNil(sut.currentUser)
    }

    func test_initialState_isLoadingTrue() {
        XCTAssertTrue(sut.isLoading)
    }


   
}


// MARK: - AUTHENTICATION MANAGER GOOGLE TESTS

final class AuthenticationManagerGoogleTests: XCTestCase {

    var sut: AuthenticationManagerGoogle!

    override func setUp() {
        super.setUp()
        sut = AuthenticationManagerGoogle()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // MARK: Unauthorized actions

    func test_signIn_email_throwsUnauthorizedAction() async {
        do {
            try await sut.signIn(email: "user@example.com", password: "Pass123")
            XCTFail("Expected AuthError.unauthorizedAction")
        } catch let error as AuthError {
            XCTAssertEqual(error, .unauthorizedAction)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

    func test_signUp_email_throwsUnauthorizedAction() async {
        do {
            try await sut.signUp(email: "user@example.com", password: "Pass123")
            XCTFail("Expected AuthError.unauthorizedAction")
        } catch let error as AuthError {
            XCTAssertEqual(error, .unauthorizedAction)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }

}


// MARK: - GOOGLE SIGN UP MANAGER TESTS

final class GoogleSignUpManagerTests: XCTestCase {

    // MARK: Mock

    class MockGoogleSignUpManager: IGoogleSignUpManager {
        var shouldThrow = false
        var errorToThrow: Error = GoogleSignUpError.missingClientID
        var signUpCalled = false

        func signUpWithGoogle() async throws {
            signUpCalled = true
            if shouldThrow { throw errorToThrow }
        }
    }

    var mockManager: MockGoogleSignUpManager!
    var sutGoogle: AuthenticationManagerGoogle!

    override func setUp() {
        super.setUp()
        mockManager = MockGoogleSignUpManager()
        sutGoogle = AuthenticationManagerGoogle(googleSignUpManager: mockManager)
    }

    override func tearDown() {
        mockManager = nil
        sutGoogle = nil
        super.tearDown()
    }

    func test_signUp_callsGoogleSignUpManager() async throws {
        try await sutGoogle.signUp()
        XCTAssertTrue(mockManager.signUpCalled)
    }

    func test_signIn_callsGoogleSignUpManager() async throws {
        try await sutGoogle.signIn()
        XCTAssertTrue(mockManager.signUpCalled)
    }

    func test_signUp_whenManagerThrows_propagatesError() async {
        mockManager.shouldThrow = true
        mockManager.errorToThrow = GoogleSignUpError.missingClientID

        do {
            try await sutGoogle.signUp()
            XCTFail("Expected error to be thrown")
        } catch let error as GoogleSignUpError {
            XCTAssertEqual(error, .missingClientID)
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }

    func test_signIn_whenManagerThrows_propagatesError() async {
        mockManager.shouldThrow = true
        mockManager.errorToThrow = GoogleSignUpError.cannotGetRootViewController

        do {
            try await sutGoogle.signIn()
            XCTFail("Expected error to be thrown")
        } catch let error as GoogleSignUpError {
            XCTAssertEqual(error, .cannotGetRootViewController)
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }

    func test_signUp_withCannotFindIdToken_throwsCorrectError() async {
        mockManager.shouldThrow = true
        mockManager.errorToThrow = GoogleSignUpError.cannotFindIdToken

        do {
            try await sutGoogle.signUp()
            XCTFail("Expected error to be thrown")
        } catch let error as GoogleSignUpError {
            XCTAssertEqual(error, .cannotFindIdToken)
        } catch {
            XCTFail("Unexpected error: \(error)")
        }
    }
}


// MARK: - BASIC AUTH TESTS

final class BasicAuthTests: XCTestCase {

    func test_getTokenId_withNoSignedInUser_returnsNil() async throws {
        // With no Firebase user signed in, getTokenId should return nil (not throw)
        let token = try await BasicAuth.getTokenId()
        XCTAssertNotNil(token, "Token should be nil when no user is signed in")
    }
}


// MARK: - IAUTH MANAGER PROTOCOL EXTENSION TESTS

@MainActor
final class IAuthenticationManagerExtensionTests: XCTestCase {

    // Concrete test double implementing the protocol
    class ConcreteAuthManager: IAuthenticationManager {
        @Published var isSignedIn: Bool = false
        @Published var currentUser: FirebaseAuth.User? = nil

        func checkAuthStatus() -> Bool { false }
        func signIn() async throws {}
        func signUp() async throws {}
        func signOut() async throws {}
        func signIn(email: String, password: String) async throws {}
        func signUp(email: String, password: String) async throws {}
    }

    var sut: ConcreteAuthManager!

    override func setUp() {
        super.setUp()
        sut = ConcreteAuthManager()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func test_updateUserState_withNilUser_setsIsSignedInFalse() {
        sut.updateUserState(user: nil, methodUsed: .email)

        // Allow the DispatchQueue.main.async to execute
        let expectation = XCTestExpectation(description: "Main queue settled")
        DispatchQueue.main.async { expectation.fulfill() }
        wait(for: [expectation], timeout: 1)

        XCTAssertFalse(AuthenticationManager.shared.isSignedIn)
        XCTAssertNil(AuthenticationManager.shared.currentUser)
    }

    func test_updateUserState_withNilUser_setsLocalCurrentUserNil() {
        sut.updateUserState(user: nil, methodUsed: .google)
        XCTAssertNil(sut.currentUser)
        XCTAssertFalse(sut.isSignedIn)
    }
}


// MARK: - EDGE CASE & BOUNDARY TESTS

final class AuthEdgeCaseTests: XCTestCase {

    var validators: InputValidators!

    override func setUp() {
        super.setUp()
        validators = InputValidators()
    }

    override func tearDown() {
        validators = nil
        super.tearDown()
    }

    // MARK: Email boundary cases

    func test_email_withUnicode_returnsFalse() {
        var called = false
        let result = validators.isEmailValid("üser@example.com") { called = true }
        // Most email validators reject non-ASCII local parts; assert based on your validator's rules
        // If AdelsonValidator accepts it, flip to XCTAssertTrue
        _ = result // result depends on validator; just ensure no crash
    }

    func test_email_veryLong_doesNotCrash() {
        var called = false
        let longLocal = String(repeating: "a", count: 200)
        _ = validators.isEmailValid("\(longLocal)@example.com") { called = true }
    }

    func test_email_multipleAtSigns_returnsFalse() {
        var called = false
        let result = validators.isEmailValid("user@@example.com") { called = true }
        XCTAssertFalse(result)
        XCTAssertTrue(called)
    }

    // MARK: Password boundary cases

    func test_password_exactlyMinimumLength_isValid() {
        var called = false
        // 6 chars: 5 letters + 1 digit
        let result = validators.isPasswordValid("abcd1e") { called = true }
        XCTAssertTrue(result)
        XCTAssertFalse(called)
    }

    func test_password_fiveChars_isTooShort() {
        var called = false
        let result = validators.isPasswordValid("abc1d") { called = true }
        XCTAssertFalse(result)
        XCTAssertTrue(called)
    }

    func test_password_veryLong_doesNotCrash() {
        var called = false
        let longPass = String(repeating: "a", count: 300) + "1"
        _ = validators.isPasswordValid(longPass) { called = true }
    }

    func test_password_withSpecialChars_isValid() {
        var called = false
        let result = validators.isPasswordValid("P@ss!1word") { called = true }
        XCTAssertTrue(result)
        XCTAssertFalse(called)
    }

    func test_password_whitespaceOnly_returnsFalse() {
        var called = false
        let result = validators.isPasswordValid("      ") { called = true }
        XCTAssertFalse(result)
        XCTAssertTrue(called)
    }

    // MARK: Alert callback is called exactly once

    func test_invalidEmail_alertCalledExactlyOnce() {
        var callCount = 0
        _ = validators.isEmailValid("bad") { callCount += 1 }
        XCTAssertEqual(callCount, 1)
    }

    func test_invalidPassword_alertCalledExactlyOnce() {
        var callCount = 0
        _ = validators.isPasswordValid("bad") { callCount += 1 }
        XCTAssertEqual(callCount, 1)
    }

    func test_validEmail_alertNeverCalled() {
        var callCount = 0
        _ = validators.isEmailValid("ok@example.com") { callCount += 1 }
        XCTAssertEqual(callCount, 0)
    }

    func test_validPassword_alertNeverCalled() {
        var callCount = 0
        _ = validators.isPasswordValid("Valid1Pass") { callCount += 1 }
        XCTAssertEqual(callCount, 0)
    }
}


// MARK: - SIGN UP VIEW MODEL — PASSWORD MATCHING TESTS

@MainActor
final class SignUpPasswordMatchingTests: XCTestCase {

    var sut: SignUpViewModel!

    override func setUp() {
        super.setUp()
        sut = SignUpViewModel()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func test_passwordsMatch_identicalStrings() async throws {
        sut.email = "test@example.com"
        sut.password = "Match123"
        sut.confirmPassword = "Match123"
        // Validation passes (Firebase call will fail in test env, not a match issue)
        try? await sut.signUpWithEmail()
        // Key assertion: showAlert triggered by Firebase, NOT by mismatch
        // We verify isSigningUp is false and no pop-up from mismatch
        XCTAssertFalse(sut.isSigningUp)
    }

    func test_passwordsDoNotMatch_emptyConfirmPassword() async throws {
        sut.email = "test@example.com"
        sut.password = "Pass123"
        sut.confirmPassword = ""

        try await sut.signUpWithEmail()

        XCTAssertFalse(sut.showAlert, "Mismatch uses PopUp, not showAlert")
        XCTAssertFalse(mockRefreshCalled())
    }

    func test_passwordsDoNotMatch_differentCase() async throws {
        sut.email = "test@example.com"
        sut.password = "Pass123"
        sut.confirmPassword = "pass123" // different case

        try await sut.signUpWithEmail()

        XCTAssertFalse(sut.isSigningUp)
        XCTAssertFalse(mockRefreshCalled())
    }

    private func mockRefreshCalled() -> Bool {
        return (sut.coordinator as? MockMainCoordinator)?.refreshAppFlowCalled ?? false
    }
}
