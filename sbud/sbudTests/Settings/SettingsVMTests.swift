//
//  SettingsVMTests.swift
//  sbud
//
//  Created by Riccardo Maria Cadario on 06/07/2026.
//


import XCTest
@testable import sbud

@MainActor
final class SettingsVMTests: XCTestCase {

    private var savedProfile: UserProfile?
    private var sut: SettingsVM!

    override func setUp() {
        super.setUp()
        savedProfile = ProfileManager.shared.getLocalProfile()
        sut = SettingsVM()
    }

    override func tearDown() {
        if let savedProfile {
            ProfileManager.shared.saveProfileToLocale(profile: savedProfile)
        } else {
            ProfileManager.shared.deleteProfileFromLocale()
        }
        sut = nil
        super.tearDown()
    }

    private func seedLocalProfile(isPrivate: Bool = false,
                                  showEmail: Bool = false,
                                  showPhone: Bool = false,
                                  showAddress: Bool = false) {
        var profile = UserProfile(id: "settings_test_user")
        profile.isPrivate = isPrivate
        profile.showEmail = showEmail
        profile.showPhone = showPhone
        profile.showAddress = showAddress
        ProfileManager.shared.saveProfileToLocale(profile: profile)
    }

    // MARK: - Stato iniziale

    func test_initialState_allTogglesOff() {
        XCTAssertFalse(sut.isPrivate)
        XCTAssertFalse(sut.showEmail)
        XCTAssertFalse(sut.showPhone)
        XCTAssertFalse(sut.showAddress)
        XCTAssertFalse(sut.isSaving)
    }

    // MARK: - loadFromLocal

    func test_loadFromLocal_readsAllFlagsFromProfile() {
        seedLocalProfile(isPrivate: true, showEmail: true, showPhone: false, showAddress: true)

        sut.loadFromLocal()

        XCTAssertTrue(sut.isPrivate)
        XCTAssertTrue(sut.showEmail)
        XCTAssertFalse(sut.showPhone)
        XCTAssertTrue(sut.showAddress)
    }

    func test_loadFromLocal_allFalseProfile_keepsTogglesOff() {
        seedLocalProfile()

        sut.loadFromLocal()

        XCTAssertFalse(sut.isPrivate)
        XCTAssertFalse(sut.showEmail)
        XCTAssertFalse(sut.showPhone)
    }

    func test_loadFromLocal_noLocalProfile_leavesDefaultsUntouched() {
        ProfileManager.shared.deleteProfileFromLocale()

        sut.loadFromLocal()

        XCTAssertFalse(sut.isPrivate)
        XCTAssertFalse(sut.showEmail)
        XCTAssertFalse(sut.showPhone)
    }

    // MARK: - savePrivacySettings (guard di uscita)

    func test_savePrivacySettings_withoutLoggedUser_doesNotCrash_andIsSavingStaysFalse() async {
        // Nei test non c'è un utente Firebase loggato, quindi il guard deve
        // far uscire subito senza toccare isSaving
        seedLocalProfile()
        sut.isPrivate = true

        await sut.savePrivacySettings()

        XCTAssertFalse(sut.isSaving)
    }
}