//
//  PhoneServiceTests.swift
//  sbud
//
//  Created by Riccardo Maria Cadario on 11/07/2026.
//


import XCTest
@testable import sbud

// MARK: - PhoneService

final class PhoneServiceTests: XCTestCase {

    func test_validate_validItalianNumber() {
        XCTAssertTrue(PhoneService.validate("+39 345 123 4567"))
    }

    func test_validate_garbage_false() {
        XCTAssertFalse(PhoneService.validate("ciao"))
        XCTAssertFalse(PhoneService.validate("123"))
        XCTAssertFalse(PhoneService.validate(""))
    }

    func test_e164_normalizesWithSpacesAndTrim() {
        XCTAssertEqual(PhoneService.e164("  +39 345 123 4567  "), "+393451234567")
    }

    func test_e164_invalid_returnsNil() {
        XCTAssertNil(PhoneService.e164("not a number"))
    }
}


// MARK: - ProfileSetupVM (validators)

@MainActor
final class ProfileSetupVMTests: XCTestCase {

    private var sut: ProfileSetupVM!

    override func setUp() {
        super.setUp()
        sut = ProfileSetupVM()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    /// Porta il VM in stato valido fino allo step richiesto
    private func makeStepOneValid() {
        sut.photo.uploadedURL = "http://img.test/p.jpg"
        sut.profile.name = "Riccardo"
        sut.profile.surName = "Test"
    }

    private func makeStepTwoValid() {
        sut.isPhoneVerified = true
        sut.profile.gender = "M"
        sut.profile.birthDate = Calendar.current.date(byAdding: .year, value: -25, to: Date())
    }

    // Step 1

    func test_stepOne_missingPhoto_fails() {
        sut.profile.name = "A"; sut.profile.surName = "B"
        XCTAssertFalse(sut.validateStepOne())
        XCTAssertEqual(sut.errorMessage, "Profile image is required.")
    }

    func test_stepOne_missingName_fails() {
        sut.photo.uploadedURL = "http://x"
        sut.profile.name = "   "
        sut.profile.surName = "B"
        XCTAssertFalse(sut.validateStepOne())
        XCTAssertEqual(sut.errorMessage, "First name is required.")
    }

    func test_stepOne_allValid_passes() {
        makeStepOneValid()
        XCTAssertTrue(sut.validateStepOne())
        XCTAssertNil(sut.errorMessage)
    }

    // Step 2

    func test_stepTwo_phoneNotVerified_fails() {
        XCTAssertFalse(sut.validateStepTwo())
        XCTAssertEqual(sut.errorMessage, "Verify your phone number with the SMS code to continue.")
    }

    func test_stepTwo_missingGender_fails() {
        sut.isPhoneVerified = true
        XCTAssertFalse(sut.validateStepTwo())
        XCTAssertEqual(sut.errorMessage, "Please select your gender.")
    }

    func test_stepTwo_under18_fails() {
        sut.isPhoneVerified = true
        sut.profile.gender = "F"
        sut.profile.birthDate = Calendar.current.date(byAdding: .year, value: -16, to: Date())
        XCTAssertFalse(sut.validateStepTwo())
        XCTAssertEqual(sut.errorMessage, "Under 18 years old not allowed.")
    }

    func test_stepTwo_adult_passes() {
        makeStepTwoValid()
        XCTAssertTrue(sut.validateStepTwo())
    }

    // Step 3 e 4

    func test_stepThree_emptyBio_fails() {
        XCTAssertFalse(sut.validateStepThree())
        XCTAssertEqual(sut.errorMessage, "Bio is required.")
    }

    func test_stepThree_withBio_passes() {
        sut.profile.bio = "Ciao, corro."
        XCTAssertTrue(sut.validateStepThree())
    }

    func test_stepFour_noLocation_fails() {
        XCTAssertFalse(sut.validateStepFour())
        XCTAssertEqual(sut.errorMessage, "Location could not be determined.")
    }

    func test_stepFour_withLocation_passes() {
        sut.location.latitude = 45.0
        sut.location.longitude = 9.0
        XCTAssertTrue(sut.validateStepFour())
    }

    func test_save_withoutAuthUser_returnsFalse() async {
        // Nei test (emulatore, signOut nel tearDown altrove) non c'è utente:
        // save deve fermarsi ai guard senza crashare
        let ok = await sut.save()
        XCTAssertFalse(ok)
        XCTAssertNotNil(sut.errorMessage)
    }

    func test_clearError() {
        sut.errorMessage = "x"
        sut.clearError()
        XCTAssertNil(sut.errorMessage)
    }
}

// MARK: - SignInViewModel

final class MockAuthOrchestrator: IAuthOrchestrator {
    var signInShouldThrow = false
    private(set) var signInCalled = false
    private(set) var emailSignInCalled = false
    private(set) var lastEmail: String?
    private(set) var authTypeGoogleSet = false
    private(set) var authTypeEmailSet = false
    private(set) var passwordResetEmail: String?
    private(set) var signUpCalled = false
    private(set) var emailSignUpCalled = false
    private(set) var verificationEmailSent = false

    var resetShouldThrow = false
    
    func signUp() async throws {
        signUpCalled = true
        if signInShouldThrow { throw URLError(.userAuthenticationRequired) }
    }

    func signUp(email: String, password: String) async throws {
        emailSignUpCalled = true
        lastEmail = email
        if signInShouldThrow { throw URLError(.userAuthenticationRequired) }
    }

    func sendVerificationEmail() { verificationEmailSent = true }

    func setAuthTypeGoogle() { authTypeGoogleSet = true }
    func setAuthTypeEmailAndPassword() { authTypeEmailSet = true }
    func signIn() async throws {
        signInCalled = true
        if signInShouldThrow { throw URLError(.userAuthenticationRequired) }
    }
    func signIn(email: String, password: String) async throws {
        emailSignInCalled = true
        lastEmail = email
        if signInShouldThrow { throw URLError(.userAuthenticationRequired) }
    }
    func sendPasswordReset(email: String) async throws {
        passwordResetEmail = email
        if resetShouldThrow { throw URLError(.userAuthenticationRequired) }
    }
}

@MainActor
final class SignInViewModelTests: XCTestCase {

    private var auth: MockAuthOrchestrator!
    private var sut: SignInViewModel!

    override func setUp() {
        super.setUp()
        auth = MockAuthOrchestrator()
        sut = SignInViewModel(authManager: auth)
    }

    func test_emailSignIn_invalidEmail_showsAlert_withoutCallingAuth() async throws {
        sut.email = "nonvalida"
        sut.password = "Password1"

        try await sut.singInWithEmail()

        XCTAssertTrue(sut.showAlert)
        XCTAssertFalse(auth.emailSignInCalled)
    }

    func test_emailSignIn_valid_trimsEmail_andCallsAuth() async throws {
        sut.email = "  test@mail.com  "
        sut.password = "Password1"

        try await sut.singInWithEmail()

        XCTAssertTrue(auth.authTypeEmailSet)
        XCTAssertEqual(auth.lastEmail, "test@mail.com")
        XCTAssertFalse(sut.showAlert)
        XCTAssertFalse(sut.isLoading)
    }

    func test_emailSignIn_authFails_showsAlert() async throws {
        sut.email = "test@mail.com"
        sut.password = "Password1"
        auth.signInShouldThrow = true

        try await sut.singInWithEmail()

        XCTAssertTrue(sut.showAlert)
        XCTAssertFalse(sut.isSigningIn)
        XCTAssertFalse(sut.isLoading)
    }

    func test_googleSignIn_failure_showsAlert() async {
        auth.signInShouldThrow = true
        await sut.signUpWithGoogle()
        XCTAssertTrue(auth.authTypeGoogleSet)
        XCTAssertTrue(sut.showAlert)
    }

    func test_forgotPassword_emptyEmail_showsAlert_withoutCalling() async {
        sut.email = ""
        await sut.forgotPassword()
        XCTAssertTrue(sut.showAlert)
        XCTAssertNil(auth.passwordResetEmail)
    }

    func test_forgotPassword_valid_sendsReset() async {
        sut.email = " test@mail.com "
        await sut.forgotPassword()
        XCTAssertEqual(auth.passwordResetEmail, "test@mail.com")
        XCTAssertTrue(sut.showAlert) // conferma di invio
    }
}
