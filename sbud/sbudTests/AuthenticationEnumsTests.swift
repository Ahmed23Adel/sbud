//
//  AuthenticationEnumsTests.swift
//  sbudTests
//

import XCTest
@testable import sbud

final class AuthenticationEnumsTests: XCTestCase {

    // MARK: - AuthType raw values

    func test_authType_unknown_rawValue() {
        XCTAssertEqual(AuthType.unknown.rawValue, "Unknown")
    }

    func test_authType_google_rawValue() {
        XCTAssertEqual(AuthType.google.rawValue, "MethodIsGoogle")
    }

    func test_authType_email_rawValue() {
        XCTAssertEqual(AuthType.email.rawValue, "Email")
    }

    // MARK: - AuthType init from raw value

    func test_authType_initFromRawValue_unknown() {
        XCTAssertEqual(AuthType(rawValue: "Unknown"), .unknown)
    }

    func test_authType_initFromRawValue_google() {
        XCTAssertEqual(AuthType(rawValue: "MethodIsGoogle"), .google)
    }

    func test_authType_initFromRawValue_email() {
        XCTAssertEqual(AuthType(rawValue: "Email"), .email)
    }

    func test_authType_initFromRawValue_invalidString_returnsNil() {
        XCTAssertNil(AuthType(rawValue: "SomethingUnknown"))
    }

    func test_authType_initFromRawValue_emptyString_returnsNil() {
        XCTAssertNil(AuthType(rawValue: ""))
    }

    func test_authType_initFromRawValue_caseSensitive() {
        // "email" (lowercase) should NOT match "Email"
        XCTAssertNil(AuthType(rawValue: "email"))
        XCTAssertNil(AuthType(rawValue: "google"))
        XCTAssertNil(AuthType(rawValue: "unknown"))
    }

    // MARK: - AuthError

    func test_authError_unauthorizedAction_isError() {
        let error: Error = AuthError.unauthorizedAction
        XCTAssertNotNil(error)
    }

    func test_authError_unauthorizedAction_matchesPattern() {
        let error = AuthError.unauthorizedAction
        if case .unauthorizedAction = error {
            // ✅ expected
        } else {
            XCTFail("Expected AuthError.unauthorizedAction")
        }
    }

    func test_authError_canBeThrown() async {
        do {
            throw AuthError.unauthorizedAction
            XCTFail("Should not reach here")
        } catch AuthError.unauthorizedAction {
            // ✅ expected
        } catch {
            XCTFail("Wrong error type: \(error)")
        }
    }

    // MARK: - GoogleSignUpError

    func test_googleSignUpError_missingClientID_isError() {
        let error: Error = GoogleSignUpError.missingClientID
        XCTAssertNotNil(error)
    }

    func test_googleSignUpError_cannotGetRootViewController_isError() {
        let error: Error = GoogleSignUpError.cannotGetRootViewController
        XCTAssertNotNil(error)
    }

    func test_googleSignUpError_cannotFindIdToken_isError() {
        let error: Error = GoogleSignUpError.cannotFindIdToken
        XCTAssertNotNil(error)
    }

    func test_googleSignUpError_allCasesAreDistinct() {
        let cases: [GoogleSignUpError] = [
            .missingClientID,
            .cannotGetRootViewController,
            .cannotFindIdToken
        ]
        let descriptions = cases.map { "\($0)" }
        XCTAssertEqual(Set(descriptions).count, 3, "All GoogleSignUpError cases must be distinct")
    }

    func test_googleSignUpError_missingClientID_canBeCaught() async {
        do {
            throw GoogleSignUpError.missingClientID
            XCTFail("Should not reach here")
        } catch GoogleSignUpError.missingClientID {
            // ✅ expected
        } catch {
            XCTFail("Wrong error: \(error)")
        }
    }
}
