//
//  SettingsVMTests.swift
//  sbud
//
//  Created by Erdal on 2.07.2026.
//

import XCTest
@testable import sbud

@MainActor
final class SettingsVMTests: XCTestCase {

    private var mockManager: MockProfileServiceManager!
    private var mockProvider: MockCurrentUserProvider!
    private var sut: SettingsVM!

    override func setUp() {
        super.setUp()
        mockManager = MockProfileServiceManager()
        mockProvider = MockCurrentUserProvider()
        mockProvider.currentUserId = "me"
        sut = SettingsVM(profileManager: mockManager, currentUserProvider: mockProvider)
    }

    override func tearDown() {
        sut = nil; mockProvider = nil; mockManager = nil
        super.tearDown()
    }

    // MARK: - loadFromLocal

    func test_loadFromLocal_noProfile_stateUnchanged() {
        mockManager.storedProfile = nil
        sut.loadFromLocal()
        XCTAssertFalse(sut.isPrivate)
        XCTAssertFalse(sut.showEmail)
    }

    func test_loadFromLocal_populatesAllFields() {
        var p = UserProfile(id: "me")
        p.isPrivate = true; p.showEmail = true; p.showPhone = false
        mockManager.storedProfile = p
        sut.loadFromLocal()
        XCTAssertTrue(sut.isPrivate)
        XCTAssertTrue(sut.showEmail)
        XCTAssertFalse(sut.showPhone)
    }

    // MARK: - savePrivacySettings

    func test_savePrivacySettings_whenNotAuthenticated_noUpdate() async {
        mockProvider.currentUserId = nil
        mockManager.storedProfile = UserProfile(id: "me")
        await sut.savePrivacySettings()
        XCTAssertEqual(mockManager.updateStepCallCount, 0)
    }

    func test_savePrivacySettings_whenNoLocalProfile_noUpdate() async {
        mockManager.storedProfile = nil
        await sut.savePrivacySettings()
        XCTAssertEqual(mockManager.updateStepCallCount, 0)
    }

    func test_savePrivacySettings_callsUpdateWithCorrectUid() async {
        mockManager.storedProfile = UserProfile(id: "me")
        await sut.savePrivacySettings()
        XCTAssertEqual(mockManager.lastUpdatedUid, "me")
    }

    func test_savePrivacySettings_sendsIsPrivateField() async {
        mockManager.storedProfile = UserProfile(id: "me")
        sut.isPrivate = true
        await sut.savePrivacySettings()
        let sent = mockManager.lastUpdatedFields?["isPrivate"] as? Bool
        XCTAssertEqual(sent, true)
    }

    func test_savePrivacySettings_sendsShowEmailField() async {
        mockManager.storedProfile = UserProfile(id: "me")
        sut.showEmail = true
        await sut.savePrivacySettings()
        let sent = mockManager.lastUpdatedFields?["showEmail"] as? Bool
        XCTAssertEqual(sent, true)
    }

    func test_savePrivacySettings_setsIsSavingFalseAfterSuccess() async {
        mockManager.storedProfile = UserProfile(id: "me")
        await sut.savePrivacySettings()
        XCTAssertFalse(sut.isSaving)
    }

    func test_savePrivacySettings_setsIsSavingFalseAfterFailure() async {
        mockManager.storedProfile = UserProfile(id: "me")
        mockManager.updateProfileStepResult = .failure(URLError(.notConnectedToInternet))
        await sut.savePrivacySettings()
        XCTAssertFalse(sut.isSaving)
    }

    func test_savePrivacySettings_updatesLocalProfile() async {
        var p = UserProfile(id: "me"); p.isPrivate = false
        mockManager.storedProfile = p
        sut.isPrivate = true
        await sut.savePrivacySettings()
        XCTAssertEqual(mockManager.storedProfile?.isPrivate, true)
    }
}
