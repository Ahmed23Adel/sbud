//
//  EditProfileVMTests.swift
//  sbud
//
//  Created by Erdal on 2.07.2026.
//

import XCTest
@testable import sbud

@MainActor
final class EditProfileVMTests: XCTestCase {

    private var mockManager: MockProfileServiceManager!
    private var mockRepo: MockUserProfileUpdating!
    private var mockProvider: MockCurrentUserProvider!
    private var base: UserProfile!
    private var sut: EditProfileVM!

    override func setUp() {
        super.setUp()
        mockManager = MockProfileServiceManager()
        mockRepo = MockUserProfileUpdating()
        mockProvider = MockCurrentUserProvider()
        mockProvider.currentUserId = "me"

        var p = UserProfile(id: "me")
        p.name = "Alice"; p.surName = "Smith"; p.bio = "Runner"
        p.preferredActivity = .running
        p.birthDate = Calendar.current.date(byAdding: .year, value: -25, to: Date())
        base = p
        mockManager.storedProfile = p

        sut = EditProfileVM(profile: base, profileManager: mockManager,
                            userRepository: mockRepo, currentUserProvider: mockProvider)
    }

    override func tearDown() {
        sut = nil; base = nil; mockProvider = nil; mockRepo = nil; mockManager = nil
        super.tearDown()
    }

    // MARK: - validate()

    func test_validate_emptyName_setsNameError() {
        sut.name = ""
        let result = sut.validate()
        XCTAssertFalse(result)
        XCTAssertNotNil(sut.nameError)
    }

    func test_validate_emptySurName_setsSurNameError() {
        sut.surName = ""
        let result = sut.validate()
        XCTAssertFalse(result)
        XCTAssertNotNil(sut.surNameError)
    }

    func test_validate_bioOver120_setBioError() {
        sut.bio = String(repeating: "x", count: 121)
        let result = sut.validate()
        XCTAssertFalse(result)
        XCTAssertNotNil(sut.bioError)
    }

    func test_validate_under18_setsShowError() {
        sut.birthDate = Calendar.current.date(byAdding: .year, value: -17, to: Date())!
        let result = sut.validate()
        XCTAssertFalse(result)
        XCTAssertTrue(sut.showError)
    }

    func test_validate_allValid_returnsTrue() {
        sut.name = "Alice"; sut.surName = "Smith"; sut.bio = "Short"
        sut.birthDate = Calendar.current.date(byAdding: .year, value: -20, to: Date())!
        let result = sut.validate()
        XCTAssertTrue(result)
        XCTAssertNil(sut.nameError)
    }

    func test_validate_clearsPreviousErrors() {
        sut.name = ""; _ = sut.validate()
        XCTAssertNotNil(sut.nameError)
        sut.name = "Alice"; _ = sut.validate()
        XCTAssertNil(sut.nameError)
    }

    // MARK: - hasChanges

    func test_hasChanges_noEdits_isFalse() {
        XCTAssertFalse(sut.hasChanges)
    }

    func test_hasChanges_nameChanged_isTrue() {
        sut.name = "Bob"
        XCTAssertTrue(sut.hasChanges)
    }

    func test_hasChanges_activityChanged_isTrue() {
        sut.preferredActivity = .cycling
        XCTAssertTrue(sut.hasChanges)
    }

    // MARK: - save()

    func test_save_validationFails_returnsNil() async {
        sut.name = ""
        let result = await sut.save()
        XCTAssertNil(result)
        XCTAssertEqual(mockRepo.callCount, 0)
    }

    func test_save_notAuthenticated_returnsNil() async {
        mockProvider.currentUserId = nil
        let result = await sut.save()
        XCTAssertNil(result)
    }

    func test_save_noOriginalProfile_returnsNil() async {
        let vm = EditProfileVM(profile: nil, profileManager: mockManager,
                               userRepository: mockRepo, currentUserProvider: mockProvider)
        let result = await vm.save()
        XCTAssertNil(result)
    }

    func test_save_nameChanged_sendsNameField() async {
        sut.name = "Bob"
        _ = await sut.save()
        let sent = mockRepo.lastFields?["name"] as? String
        XCTAssertEqual(sent, "Bob")
    }

    func test_save_surNameChanged_sendsSurNameField() async {
        sut.surName = "Jones"
        _ = await sut.save()
        let sent = mockRepo.lastFields?["surName"] as? String
        XCTAssertEqual(sent, "Jones")
    }

    func test_save_activityChanged_sendsActivityField() async {
        sut.preferredActivity = .cycling
        _ = await sut.save()
        let sent = mockRepo.lastFields?["preferredActivity"] as? String
        XCTAssertEqual(sent, ActivityType.cycling.rawValue)
    }

    func test_save_noChanges_doesNotCallRepository() async {
        _ = await sut.save()
        XCTAssertEqual(mockRepo.callCount, 0)
    }

    func test_save_onSuccess_savesLocally() async {
        sut.name = "NewName"
        _ = await sut.save()
        XCTAssertEqual(mockManager.storedProfile?.name, "NewName")
    }

    func test_save_repositoryThrows_setsShowError() async {
        sut.name = "Changed"
        mockRepo.stubbedResult = .failure(URLError(.notConnectedToInternet))
        _ = await sut.save()
        XCTAssertTrue(sut.showError)
    }

    func test_save_trimsWhitespace() async {
        sut.name = "  Bob  "; sut.surName = "  Jones  "
        _ = await sut.save()
        XCTAssertEqual(mockRepo.lastFields?["name"] as? String, "Bob")
        XCTAssertEqual(mockRepo.lastFields?["surName"] as? String, "Jones")
    }

    func test_save_setsIsSavingFalseAfterCompletion() async {
        sut.name = "Changed"
        _ = await sut.save()
        XCTAssertFalse(sut.isSaving)
    }
}

