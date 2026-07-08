//
//  CentralPopupIntegrationTests.swift
//  sbud
//
//  Created by Erdal on 30.06.2026.
//

import XCTest
@testable import sbud

// MARK: - centralPopupType

final class CentralPopupTypeTests: XCTestCase {

    func test_themeColor_warning_isYellow() {
        XCTAssertEqual(centralPopupType.warning.themeColor, .yellow)
    }

    func test_themeColor_error_isRed() {
        XCTAssertEqual(centralPopupType.error.themeColor, .red)
    }

    func test_themeColor_notification_isGreen() {
        XCTAssertEqual(centralPopupType.notification.themeColor, .green)
    }

    func test_themeColor_information_isGreen() {
        XCTAssertEqual(centralPopupType.information.themeColor, .green)
    }

    func test_animationName_notification() {
        XCTAssertEqual(centralPopupType.notification.animationName, "ring")
    }

    func test_animationName_warning() {
        XCTAssertEqual(centralPopupType.warning.animationName, "warning")
    }

    func test_animationName_error() {
        XCTAssertEqual(centralPopupType.error.animationName, "alert")
    }

    func test_animationName_information() {
        XCTAssertEqual(centralPopupType.information.animationName, "speaker")
    }
}

// MARK: - PopUpInfo

final class PopUpInfoTests: XCTestCase {

    func test_init_setsMessage() {
        let info = PopUpInfo(msg: "Hello", type: .notification)
        XCTAssertEqual(info.msg, "Hello")
    }

    func test_init_setsType_viaAnimationName() {
        let info = PopUpInfo(msg: "Hello", type: .error)
        XCTAssertEqual(info.type.animationName, "alert")
    }

    func test_init_isBeingDismissed_defaultsFalse() {
        let info = PopUpInfo(msg: "Hello", type: .error)
        XCTAssertFalse(info.isBeingDismissed)
    }

    func test_isBeingDismissed_isMutable() {
        let info = PopUpInfo(msg: "Hello", type: .error)
        info.isBeingDismissed = true
        XCTAssertTrue(info.isBeingDismissed)
    }

    func test_id_isUniquePerInstance() {
        let a = PopUpInfo(msg: "Same", type: .error)
        let b = PopUpInfo(msg: "Same", type: .error)
        XCTAssertNotEqual(a.id, b.id)
    }
}

// MARK: - PopUpGenerator

final class PopUpGeneratorTests: XCTestCase {

    private var sut: PopUpGenerator!

    override func setUp() {
        super.setUp()
        sut = PopUpGenerator.shared
        sut.clearAll()
    }

    override func tearDown() {
        sut.clearAll()
        sut = nil
        super.tearDown()
    }

    func test_shared_isSingleton() {
        XCTAssertTrue(PopUpGenerator.shared === PopUpGenerator.shared)
    }

    func test_initialState_isEmpty() {
        XCTAssertTrue(sut.popUps.isEmpty)
    }

    func test_show_addsOnePopUp() async throws {
        sut.show(msg: "Hello", type: .notification)
        try await Task.sleep(nanoseconds: 200_000_000)
        XCTAssertEqual(sut.popUps.count, 1)
        XCTAssertEqual(sut.popUps.first?.msg, "Hello")
    }

    func test_show_insertsNewestAtFront() async throws {
        sut.show(msg: "First", type: .notification)
        try await Task.sleep(nanoseconds: 150_000_000)
        sut.show(msg: "Second", type: .warning)
        try await Task.sleep(nanoseconds: 150_000_000)
        XCTAssertEqual(sut.popUps.first?.msg, "Second")
        XCTAssertEqual(sut.popUps.last?.msg, "First")
    }

    func test_show_beyondCap_keepsOnlyThree() async throws {
        for i in 1...4 {
            sut.show(msg: "\(i)", type: .notification)
            try await Task.sleep(nanoseconds: 120_000_000)
        }
        XCTAssertEqual(sut.popUps.count, 3)
    }

    func test_show_beyondCap_evictsOldest() async throws {
        sut.show(msg: "oldest", type: .notification)
        try await Task.sleep(nanoseconds: 120_000_000)
        sut.show(msg: "mid", type: .notification)
        try await Task.sleep(nanoseconds: 120_000_000)
        sut.show(msg: "newer", type: .notification)
        try await Task.sleep(nanoseconds: 120_000_000)
        sut.show(msg: "newest", type: .notification)
        try await Task.sleep(nanoseconds: 120_000_000)
        let messages = sut.popUps.map(\.msg)
        XCTAssertFalse(messages.contains("oldest"))
        XCTAssertTrue(messages.contains("newest"))
    }

    func test_dismiss_removesTargetPopUp() async throws {
        sut.show(msg: "Keep", type: .notification)
        try await Task.sleep(nanoseconds: 150_000_000)
        sut.show(msg: "Remove", type: .error)
        try await Task.sleep(nanoseconds: 150_000_000)
        guard let toRemove = sut.popUps.first(where: { $0.msg == "Remove" }) else {
            return XCTFail("Popup not found")
        }
        sut.dismiss(toRemove)
        try await Task.sleep(nanoseconds: 150_000_000)
        let removed = sut.popUps.contains { $0.id == toRemove.id }
        XCTAssertFalse(removed)
        let kept = sut.popUps.contains { $0.msg == "Keep" }
        XCTAssertTrue(kept)
    }

    func test_clearAll_emptiesQueue() async throws {
        sut.show(msg: "A", type: .notification)
        sut.show(msg: "B", type: .warning)
        try await Task.sleep(nanoseconds: 200_000_000)
        sut.clearAll()
        try await Task.sleep(nanoseconds: 150_000_000)
        XCTAssertTrue(sut.popUps.isEmpty)
    }
}
