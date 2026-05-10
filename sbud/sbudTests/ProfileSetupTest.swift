//
//  ProfileSetupTest.swift
//  sbud
//
//  Created by Erdal on 1.05.2026.
//

import XCTest
@testable import sbud

// MARK: - ProfileSetupVM Tests


@MainActor
final class ProfileSetupVMTests: XCTestCase {


    var sut: ProfileSetupVM!

    override func setUp() {
        super.setUp()
        sut = ProfileSetupVM()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // MARK: - Default State

    func test_defaultState_currentStepIsZero() {
        XCTAssertEqual(sut.currentStep, 0)
    }

    func test_defaultState_errorMessageIsNil() {
        XCTAssertNil(sut.errorMessage)
    }

    func test_defaultState_isLoadingIsFalse() {
        XCTAssertFalse(sut.isLoading)
    }

    func test_defaultState_isSavingIsFalse() {
        XCTAssertFalse(sut.isSaving)
    }

    func test_defaultState_phoneNumberIsEmpty() {
        XCTAssertTrue(sut.phoneNumber.isEmpty)
    }

    func test_defaultState_nameIsEmpty() {
        XCTAssertTrue(sut.profile.name.isEmpty)
    }

    // MARK: - Navigation

    func test_goNext_incrementsCurrentStep() {
        sut.goNext()
        XCTAssertEqual(sut.currentStep, 1)
    }

    func test_goNext_twice_incrementsToTwo() {
        sut.goNext()
        sut.goNext()
        XCTAssertEqual(sut.currentStep, 2)
    }

    func test_goBack_decrementsCurrentStep() {
        sut.goNext()
        sut.goBack()
        XCTAssertEqual(sut.currentStep, 0)
    }

    func test_goBack_atStepZero_remainsAtZero() {
        sut.goBack()
        XCTAssertEqual(sut.currentStep, 0)
    }

    func test_goBack_doesNotGoBelowZero() {
        sut.goBack()
        sut.goBack()
        XCTAssertEqual(sut.currentStep, 0)
    }

    // MARK: - clearError

    func test_clearError_removesExistingError() {
        sut.errorMessage = "Some error"
        sut.clearError()
        XCTAssertNil(sut.errorMessage)
    }

    func test_clearError_onNilError_remainsNil() {
        sut.clearError()
        XCTAssertNil(sut.errorMessage)
    }

    // MARK: - validateStepOne

    func test_validateStepOne_emptyName_returnsFalse() {
        sut.profile.name = ""
        sut.profile.surName = "Doe"
        sut.profile.profileImageUrl = "https://example.com/img.jpg"
        XCTAssertFalse(sut.validateStepOne())
    }

    func test_validateStepOne_emptyName_setsErrorMessage() {
        sut.profile.name = ""
        sut.profile.surName = "Doe"
        sut.profile.profileImageUrl = "https://example.com/img.jpg"
        sut.validateStepOne()
        XCTAssertNotNil(sut.errorMessage)
    }

    func test_validateStepOne_whitespaceOnlyName_returnsFalse() {
        sut.profile.name = "   "
        sut.profile.surName = "Doe"
        sut.profile.profileImageUrl = "https://example.com/img.jpg"
        XCTAssertFalse(sut.validateStepOne())
    }

    func test_validateStepOne_emptySurname_returnsFalse() {
        sut.profile.name = "John"
        sut.profile.surName = ""
        sut.profile.profileImageUrl = "https://example.com/img.jpg"
        XCTAssertFalse(sut.validateStepOne())
    }

    func test_validateStepOne_emptySurname_setsErrorMessage() {
        sut.profile.name = "John"
        sut.profile.surName = ""
        sut.profile.profileImageUrl = "https://example.com/img.jpg"
        sut.validateStepOne()
        XCTAssertNotNil(sut.errorMessage)
    }

    func test_validateStepOne_missingProfileImage_returnsFalse() {
        sut.profile.name = "John"
        sut.profile.surName = "Doe"
        sut.profile.profileImageUrl = nil
        XCTAssertFalse(sut.validateStepOne())
    }

    func test_validateStepOne_allValid_returnsTrue() {
        sut.profile.name = "John"
        sut.profile.surName = "Doe"
        sut.profile.profileImageUrl = "https://example.com/img.jpg"
        XCTAssertTrue(sut.validateStepOne())
    }

    func test_validateStepOne_allValid_clearsErrorMessage() {
        sut.errorMessage = "previous error"
        sut.profile.name = "John"
        sut.profile.surName = "Doe"
        sut.profile.profileImageUrl = "https://example.com/img.jpg"
        sut.validateStepOne()
        XCTAssertNil(sut.errorMessage)
    }

    // MARK: - validateStepTwo

    func test_validateStepTwo_missingGender_returnsFalse() {
        sut.profile.gender = nil
        sut.profile.birthDate = adultBirthDate()
        sut.phoneNumber = "+905551234567"
        XCTAssertFalse(sut.validateStepTwo())
    }

    func test_validateStepTwo_missingGender_setsErrorMessage() {
        sut.profile.gender = nil
        sut.profile.birthDate = adultBirthDate()
        sut.phoneNumber = "+905551234567"
        sut.validateStepTwo()
        XCTAssertNotNil(sut.errorMessage)
    }

    func test_validateStepTwo_missingBirthDate_returnsFalse() {
        sut.profile.gender = "Male"
        sut.profile.birthDate = nil
        sut.phoneNumber = "+905551234567"
        XCTAssertFalse(sut.validateStepTwo())
    }

    func test_validateStepTwo_under18_returnsFalse() {
        sut.profile.gender = "Male"
        sut.profile.birthDate = under18BirthDate()
        sut.phoneNumber = "+905551234567"
        XCTAssertFalse(sut.validateStepTwo())
    }

    func test_validateStepTwo_under18_setsErrorMessage() {
        sut.profile.gender = "Male"
        sut.profile.birthDate = under18BirthDate()
        sut.phoneNumber = "+905551234567"
        sut.validateStepTwo()
        XCTAssertNotNil(sut.errorMessage)
    }

    func test_validateStepTwo_emptyPhone_returnsFalse() {
        sut.profile.gender = "Male"
        sut.profile.birthDate = adultBirthDate()
        sut.phoneNumber = ""
        XCTAssertFalse(sut.validateStepTwo())
    }

    func test_validateStepTwo_invalidPhone_returnsFalse() {
        sut.profile.gender = "Male"
        sut.profile.birthDate = adultBirthDate()
        sut.phoneNumber = "123"
        XCTAssertFalse(sut.validateStepTwo())
    }

    func test_validateStepTwo_allValid_returnsTrue() {
        sut.profile.gender = "Male"
        sut.profile.birthDate = adultBirthDate()
        sut.phoneNumber = "+905551234567"
        XCTAssertTrue(sut.validateStepTwo())
    }

    func test_validateStepTwo_allValid_clearsError() {
        sut.errorMessage = "old error"
        sut.profile.gender = "Female"
        sut.profile.birthDate = adultBirthDate()
        sut.phoneNumber = "+905551234567"
        sut.validateStepTwo()
        XCTAssertNil(sut.errorMessage)
    }

    // MARK: - validateStepThree

    func test_validateStepThree_emptyBio_returnsFalse() {
        sut.profile.bio = ""
        XCTAssertFalse(sut.validateStepThree())
    }

    func test_validateStepThree_emptyBio_setsErrorMessage() {
        sut.profile.bio = ""
        sut.validateStepThree()
        XCTAssertNotNil(sut.errorMessage)
    }

    func test_validateStepThree_whitespaceBio_returnsFalse() {
        sut.profile.bio = "   \n  "
        XCTAssertFalse(sut.validateStepThree())
    }

    func test_validateStepThree_validBio_returnsTrue() {
        sut.profile.bio = "I love running in the mornings."
        XCTAssertTrue(sut.validateStepThree())
    }

    func test_validateStepThree_validBio_clearsError() {
        sut.errorMessage = "old error"
        sut.profile.bio = "Athletic and motivated."
        sut.validateStepThree()
        XCTAssertNil(sut.errorMessage)
    }

    // MARK: - validateLocationStep

    func test_validateLocationStep_zeroCoordinates_returnsFalse() {
        sut.profile.location.latitude = 0
        sut.profile.location.longitude = 0
        XCTAssertFalse(sut.validateLocationStep())
    }

    func test_validateLocationStep_zeroCoordinates_setsErrorMessage() {
        sut.profile.location.latitude = 0
        sut.profile.location.longitude = 0
        sut.validateLocationStep()
        XCTAssertNotNil(sut.errorMessage)
    }

    func test_validateLocationStep_validCoordinates_returnsTrue() {
        sut.profile.location.latitude = 41.0082
        sut.profile.location.longitude = 28.9784
        XCTAssertTrue(sut.validateLocationStep())
    }

    func test_validateLocationStep_zeroLatOnly_returnsFalse() {
        sut.profile.location.latitude = 0
        sut.profile.location.longitude = 28.9784
        XCTAssertFalse(sut.validateLocationStep())
    }

    func test_validateLocationStep_zeroLonOnly_returnsFalse() {
        sut.profile.location.latitude = 41.0082
        sut.profile.location.longitude = 0
        XCTAssertFalse(sut.validateLocationStep())
    }

    // MARK: - validateCurrentStep

    func test_validateCurrentStep_step0_delegatesToStepOne() {
        sut.currentStep = 0
        sut.profile.name = ""
        XCTAssertFalse(sut.validateCurrentStep())
    }

    func test_validateCurrentStep_step1_delegatesToStepTwo() {
        sut.currentStep = 1
        sut.profile.gender = nil
        XCTAssertFalse(sut.validateCurrentStep())
    }

    func test_validateCurrentStep_step2_delegatesToStepThree() {
        sut.currentStep = 2
        sut.profile.bio = ""
        XCTAssertFalse(sut.validateCurrentStep())
    }

    func test_validateCurrentStep_unknownStep_returnsTrue() {
        sut.currentStep = 99
        XCTAssertTrue(sut.validateCurrentStep())
    }

    // MARK: - preferredActivity

    func test_defaultPreferredActivity_isRunning() {
        XCTAssertEqual(sut.profile.preferredActivity, .running)
    }

    func test_setPreferredActivity_cycling_persists() {
        sut.profile.preferredActivity = .cycling
        XCTAssertEqual(sut.profile.preferredActivity, .cycling)
    }

    func test_setPreferredActivity_yoga_persists() {
        sut.profile.preferredActivity = .yoga
        XCTAssertEqual(sut.profile.preferredActivity, .yoga)
    }

    func test_allActivityTypes_canBeSet() {
        for activity in ActivityType.allCases {
            sut.profile.preferredActivity = activity
            XCTAssertEqual(sut.profile.preferredActivity, activity)
        }
    }
}

// MARK: - Helpers

private extension ProfileSetupVMTests {

    func adultBirthDate() -> Date {
        Calendar.current.date(byAdding: .year, value: -30, to: Date())!
    }

    func under18BirthDate() -> Date {
        Calendar.current.date(byAdding: .year, value: -16, to: Date())!
    }
}
