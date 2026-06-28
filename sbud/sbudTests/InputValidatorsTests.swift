//
//  InputValidatorsTests.swift
//  sbudTests
//

import XCTest
@testable import sbud

final class InputValidatorsTests: XCTestCase {

    private var sut: InputValidators!

    override func setUp() {
        super.setUp()
        sut = InputValidators()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // MARK: - isEmailValid — happy paths

    func test_isEmailValid_withStandardEmail_returnsTrue() {
        var alertCalled = false
        let result = sut.isEmailValid("user@example.com") { alertCalled = true }
        XCTAssertTrue(result)
        XCTAssertFalse(alertCalled)
    }

    func test_isEmailValid_withSubdomainEmail_returnsTrue() {
        var alertCalled = false
        let result = sut.isEmailValid("athlete@mail.co.uk") { alertCalled = true }
        XCTAssertTrue(result)
        XCTAssertFalse(alertCalled)
    }

    func test_isEmailValid_withPlusAddressing_returnsTrue() {
        var alertCalled = false
        let result = sut.isEmailValid("user+tag@example.com") { alertCalled = true }
        XCTAssertTrue(result)
        XCTAssertFalse(alertCalled)
    }

    // MARK: - isEmailValid — failure paths

    func test_isEmailValid_withEmptyString_returnsFalseAndCallsAlert() {
        var alertCalled = false
        let result = sut.isEmailValid("") { alertCalled = true }
        XCTAssertFalse(result)
        XCTAssertTrue(alertCalled)
    }

    func test_isEmailValid_withNoAtSign_returnsFalseAndCallsAlert() {
        var alertCalled = false
        let result = sut.isEmailValid("notanemail") { alertCalled = true }
        XCTAssertFalse(result)
        XCTAssertTrue(alertCalled)
    }

    func test_isEmailValid_withMissingDomain_returnsFalseAndCallsAlert() {
        var alertCalled = false
        let result = sut.isEmailValid("user@") { alertCalled = true }
        XCTAssertFalse(result)
        XCTAssertTrue(alertCalled)
    }

    func test_isEmailValid_withMissingLocalPart_returnsFalseAndCallsAlert() {
        var alertCalled = false
        let result = sut.isEmailValid("@domain.com") { alertCalled = true }
        XCTAssertFalse(result)
        XCTAssertTrue(alertCalled)
    }

    func test_isEmailValid_withSpacesInEmail_returnsFalseAndCallsAlert() {
        var alertCalled = false
        let result = sut.isEmailValid("user @example.com") { alertCalled = true }
        XCTAssertFalse(result)
        XCTAssertTrue(alertCalled)
    }

    // MARK: - isPasswordValid — happy paths

    func test_isPasswordValid_withMinimumValidPassword_returnsTrue() {
        var alertCalled = false
        let result = sut.isPasswordValid("abc123") { alertCalled = true }
        XCTAssertTrue(result)
        XCTAssertFalse(alertCalled)
    }

    func test_isPasswordValid_withLongMixedPassword_returnsTrue() {
        var alertCalled = false
        let result = sut.isPasswordValid("SecurePass99") { alertCalled = true }
        XCTAssertTrue(result)
        XCTAssertFalse(alertCalled)
    }

    // MARK: - isPasswordValid — failure paths

    func test_isPasswordValid_withEmptyString_returnsFalseAndCallsAlert() {
        var alertCalled = false
        let result = sut.isPasswordValid("") { alertCalled = true }
        XCTAssertFalse(result)
        XCTAssertTrue(alertCalled)
    }

    func test_isPasswordValid_withTooShort_returnsFalseAndCallsAlert() {
        var alertCalled = false
        let result = sut.isPasswordValid("ab1") { alertCalled = true }
        XCTAssertFalse(result)
        XCTAssertTrue(alertCalled)
    }

    func test_isPasswordValid_withOnlyLetters_returnsFalseAndCallsAlert() {
        // Missing required digit
        var alertCalled = false
        let result = sut.isPasswordValid("abcdefgh") { alertCalled = true }
        XCTAssertFalse(result)
        XCTAssertTrue(alertCalled)
    }

    func test_isPasswordValid_withOnlyNumbers_returnsFalseAndCallsAlert() {
        // Missing required letter
        var alertCalled = false
        let result = sut.isPasswordValid("123456") { alertCalled = true }
        XCTAssertFalse(result)
        XCTAssertTrue(alertCalled)
    }

    func test_isPasswordValid_withFiveCharsMixed_returnsFalseAndCallsAlert() {
        // One under minimum length even with letter + number
        var alertCalled = false
        let result = sut.isPasswordValid("abc12") { alertCalled = true }
        XCTAssertFalse(result)
        XCTAssertTrue(alertCalled)
    }

    // MARK: - validateInputs — combined

    func test_validateInputs_withValidEmailAndPassword_returnsTrue() {
        var emailAlertCalled = false
        var passwordAlertCalled = false
        let result = sut.validateInputs(
            email: "user@example.com",
            password: "abc123",
            emailAlertFunction: { emailAlertCalled = true },
            passwordAlertFunction: { passwordAlertCalled = true }
        )
        XCTAssertTrue(result)
        XCTAssertFalse(emailAlertCalled)
        XCTAssertFalse(passwordAlertCalled)
    }

    func test_validateInputs_withInvalidEmail_returnsFalseAndCallsEmailAlertOnly() {
        var emailAlertCalled = false
        var passwordAlertCalled = false
        let result = sut.validateInputs(
            email: "invalid",
            password: "abc123",
            emailAlertFunction: { emailAlertCalled = true },
            passwordAlertFunction: { passwordAlertCalled = true }
        )
        XCTAssertFalse(result)
        XCTAssertTrue(emailAlertCalled)
        XCTAssertFalse(passwordAlertCalled)
    }

    func test_validateInputs_withInvalidPassword_returnsFalseAndCallsPasswordAlert() {
        var emailAlertCalled = false
        var passwordAlertCalled = false
        let result = sut.validateInputs(
            email: "user@example.com",
            password: "abc",        // too short, no number
            emailAlertFunction: { emailAlertCalled = true },
            passwordAlertFunction: { passwordAlertCalled = true }
        )
        XCTAssertFalse(result)
        XCTAssertFalse(emailAlertCalled)
        XCTAssertTrue(passwordAlertCalled)
    }

    func test_validateInputs_withBothInvalid_shortCircuitsOnEmail() {
        // && short-circuits: email fails first, password alert is never invoked
        var emailAlertCalled = false
        var passwordAlertCalled = false
        let result = sut.validateInputs(
            email: "bad",
            password: "x",
            emailAlertFunction: { emailAlertCalled = true },
            passwordAlertFunction: { passwordAlertCalled = true }
        )
        XCTAssertFalse(result)
        XCTAssertTrue(emailAlertCalled)
        XCTAssertFalse(passwordAlertCalled, "Password alert must not fire when email already failed")
    }

    func test_validateInputs_withEmptyEmailAndValidPassword_returnsFalse() {
        var emailAlertCalled = false
        let result = sut.validateInputs(
            email: "",
            password: "abc123",
            emailAlertFunction: { emailAlertCalled = true },
            passwordAlertFunction: {}
        )
        XCTAssertFalse(result)
        XCTAssertTrue(emailAlertCalled)
    }

    func test_validateInputs_withValidEmailAndEmptyPassword_returnsFalse() {
        var passwordAlertCalled = false
        let result = sut.validateInputs(
            email: "user@example.com",
            password: "",
            emailAlertFunction: {},
            passwordAlertFunction: { passwordAlertCalled = true }
        )
        XCTAssertFalse(result)
        XCTAssertTrue(passwordAlertCalled)
    }

}
