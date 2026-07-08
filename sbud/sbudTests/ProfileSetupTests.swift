//
//  ProfileSetupTests.swift
//  sbud
//
//  Created by Erdal on 2.07.2026.
//

import XCTest
@testable import sbud

// MARK: - ProfileSetupCoordinatorTests

@MainActor
final class ProfileSetupCoordinatorTests: XCTestCase {

    private var sut: ProfileSetupCoordinator!

    override func setUp() {
        super.setUp()
        sut = ProfileSetupCoordinator()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    func test_init_startsOnIdentity() {
        XCTAssertEqual(sut.currentStep, .identity)
    }

    func test_init_isFirstStep() { XCTAssertTrue(sut.isFirstStep) }
    func test_init_notFinalStep() { XCTAssertFalse(sut.isFinalStep) }

    func test_advance_valid_movesToNextStep() {
        sut.advance(validating: { true })
        XCTAssertEqual(sut.currentStep, .details)
    }

    func test_advance_invalid_staysOnCurrentStep() {
        sut.advance(validating: { false })
        XCTAssertEqual(sut.currentStep, .identity)
    }

    func test_advance_throughAllSteps_endsOnLocation() {
        while !sut.isFinalStep { sut.advance(validating: { true }) }
        XCTAssertEqual(sut.currentStep, .location)
        XCTAssertTrue(sut.isFinalStep)
    }

    func test_advance_fromFinalStep_staysOnFinal() {
        while !sut.isFinalStep { sut.advance(validating: { true }) }
        sut.advance(validating: { true })
        XCTAssertEqual(sut.currentStep, .location)
    }

    func test_goBack_fromDetails_returnsToIdentity() {
        sut.advance(validating: { true })
        sut.goBack()
        XCTAssertEqual(sut.currentStep, .identity)
    }

    func test_goBack_fromFirstStep_staysOnFirst() {
        sut.goBack()
        XCTAssertEqual(sut.currentStep, .identity)
    }

    func test_goBack_fromLocation_returnsToBio() {
        while !sut.isFinalStep { sut.advance(validating: { true }) }
        sut.goBack()
        XCTAssertEqual(sut.currentStep, .bio)
    }

    func test_displayNumbers_areCorrect() {
        XCTAssertEqual(ProfileSetupStep.identity.displayNumber, "01")
        XCTAssertEqual(ProfileSetupStep.details.displayNumber,  "02")
        XCTAssertEqual(ProfileSetupStep.bio.displayNumber,      "03")
        XCTAssertEqual(ProfileSetupStep.location.displayNumber, "04")
    }

    func test_totalDisplay_lastStepIsFinal() {
        XCTAssertEqual(ProfileSetupStep.location.totalDisplay, "FINAL")
        XCTAssertEqual(ProfileSetupStep.identity.totalDisplay, "04")
    }

    func test_allCasesCount_isFour() {
        XCTAssertEqual(ProfileSetupStep.allCases.count, 4)
    }

    func test_advanceThenGoBack_returnsToOriginal() {
        let before = sut.currentStep
        sut.advance(validating: { true })
        sut.goBack()
        XCTAssertEqual(sut.currentStep, before)
    }

    func test_noMemoryLeak() {
        var c: ProfileSetupCoordinator? = ProfileSetupCoordinator()
        weak var w = c
        addTeardownBlock { XCTAssertNil(w) }
        c = nil
    }
}

// MARK: - ProfileSetupVMTests (pure validation logic, no network)

@MainActor
final class ProfileSetupVMTests: XCTestCase {

    private var sut: ProfileSetupVM!
    private var mockProvider: MockCurrentUserProvider!

    override func setUp() {
        super.setUp()
        mockProvider = MockCurrentUserProvider()
        mockProvider.currentUserId = "test-uid"
        sut = ProfileSetupVM(currentUserProvider: mockProvider)
    }

    override func tearDown() {
        sut = nil; mockProvider = nil
        super.tearDown()
    }

    func test_init_profileIdMatchesCurrentUser() {
        XCTAssertEqual(sut.profile.id, "test-uid")
    }

    func test_init_noAuth_profileIdIsEmpty() {
        mockProvider.currentUserId = nil
        let vm = ProfileSetupVM(currentUserProvider: mockProvider)
        XCTAssertEqual(vm.profile.id, "")
    }

    func test_validateStepOne_noPhoto_fails() {
        sut.photo.uploadedURL = nil
        sut.profile.name = "Alice"; sut.profile.surName = "Smith"
        XCTAssertFalse(sut.validateStepOne())
    }

    func test_validateStepOne_emptyName_fails() {
        sut.photo.uploadedURL = "https://cdn.sbud.app/p.jpg"
        sut.profile.name = ""; sut.profile.surName = "Smith"
        XCTAssertFalse(sut.validateStepOne())
    }

    func test_validateStepOne_emptySurName_fails() {
        sut.photo.uploadedURL = "https://cdn.sbud.app/p.jpg"
        sut.profile.name = "Alice"; sut.profile.surName = ""
        XCTAssertFalse(sut.validateStepOne())
    }

    func test_validateStepOne_allValid_succeeds() {
        sut.photo.uploadedURL = "https://cdn.sbud.app/p.jpg"
        sut.profile.name = "Alice"; sut.profile.surName = "Smith"
        XCTAssertTrue(sut.validateStepOne())
        XCTAssertNil(sut.errorMessage)
    }

    func test_validateStepTwo_invalidPhone_fails() {
        sut.phoneNumber = "not-a-phone"
        XCTAssertFalse(sut.validateStepTwo())
    }

    func test_validateStepTwo_noGender_fails() {
        sut.phoneNumber = "+905551234567"
        sut.profile.gender = nil
        XCTAssertFalse(sut.validateStepTwo())
    }

    func test_validateStepTwo_noBirthDate_fails() {
        sut.phoneNumber = "+905551234567"
        sut.profile.gender = "Male"
        sut.profile.birthDate = nil
        XCTAssertFalse(sut.validateStepTwo())
    }

    func test_validateStepTwo_under18_fails() {
        sut.phoneNumber = "+905551234567"
        sut.profile.gender = "Male"
        sut.profile.birthDate = Calendar.current.date(byAdding: .year, value: -10, to: Date())
        XCTAssertFalse(sut.validateStepTwo())
    }

    func test_validateStepThree_emptyBio_fails() {
        sut.profile.bio = ""
        XCTAssertFalse(sut.validateStepThree())
    }

    func test_validateStepThree_whitespaceOnly_fails() {
        sut.profile.bio = "   "
        XCTAssertFalse(sut.validateStepThree())
    }

    func test_validateStepThree_withContent_succeeds() {
        sut.profile.bio = "I love running"
        XCTAssertTrue(sut.validateStepThree())
    }

    func test_validateStepFour_noLocation_fails() {
        XCTAssertFalse(sut.validateStepFour())
    }

    func test_clearError_nilsErrorMessage() {
        sut.errorMessage = "Some error"
        sut.clearError()
        XCTAssertNil(sut.errorMessage)
    }
}

