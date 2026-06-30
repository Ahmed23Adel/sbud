//
//  CentralPopupIntegrationTests.swift
//  sbud
//
//  Created by Erdal on 30.06.2026.
//

import XCTest
@testable import sbud

final class CentralPopupIntegrationTests: XCTestCase {

    private var generator: PopUpGenerator!

    override func setUp() {
        super.setUp()
        generator = PopUpGenerator.shared
        generator.clearAll()
    }

    override func tearDown() {
        generator.clearAll()
        generator = nil
        super.tearDown()
    }

    // MARK: - 1. Realistic Toast Sequence (mirrors HomeViewModel.joinEvent / ViewModelMoreInfoEvent)

    func test_joinFlowSequence_pendingThenConfirmed_endsWithLatestMessageOnTop() async throws {
        generator.show(msg: "Request sent, awaiting approval.", type: .notification)
        try await Task.sleep(nanoseconds: 200_000_000)

        generator.show(msg: "You have joined the event!", type: .notification)
        try await Task.sleep(nanoseconds: 200_000_000)

        XCTAssertEqual(generator.popUps.first?.msg, "You have joined the event!")
        XCTAssertEqual(generator.popUps.count, 2)
    }

    func test_errorAfterSuccess_bothCoexistUpToCap() async throws {
        generator.show(msg: "Confirmed", type: .notification)
        try await Task.sleep(nanoseconds: 150_000_000)
        generator.show(msg: "Error: network lost", type: .error)
        try await Task.sleep(nanoseconds: 150_000_000)

        let types = generator.popUps.map { $0.type.animationName }
        XCTAssertEqual(types, ["alert", "ring"], "Newest (error) should be first, oldest (notification) last")
    }

    // MARK: - 2. Tap-to-Dismiss Flow (mirrors CentralPopup.reverseAnimation -> onDismiss -> PopUpGenerator.dismiss)

    func test_userTapsToDismiss_specificPopUpLeavesQueue_othersUnaffected() async throws {
        generator.show(msg: "Toast A", type: .notification)
        try await Task.sleep(nanoseconds: 150_000_000)
        generator.show(msg: "Toast B", type: .warning)
        try await Task.sleep(nanoseconds: 150_000_000)
        generator.show(msg: "Toast C", type: .error)
        try await Task.sleep(nanoseconds: 150_000_000)

        // Simulate what CentralPopup's onTapGesture -> reverseAnimation -> onDismiss does:
        // mark the popup as being dismissed, then ask the generator to remove it.
        guard let middle = generator.popUps.first(where: { $0.msg == "Toast B" }) else {
            return XCTFail("Expected Toast B to be present")
        }
        middle.isBeingDismissed = true
        generator.dismiss(middle)
        try await Task.sleep(nanoseconds: 150_000_000)

        let remainingMessages = generator.popUps.map(\.msg)
        XCTAssertEqual(Set(remainingMessages), Set(["Toast A", "Toast C"]))
        XCTAssertTrue(middle.isBeingDismissed, "Dismissal flag set by the view should still be observable on the model")
    }

    // MARK: - 3. Overflow Behavior Under Realistic Burst (e.g. several errors firing close together)

    func test_burstOfFivePopUps_onlyNewestThreeSurvive() async throws {
        let messages = ["one", "two", "three", "four", "five"]
        for msg in messages {
            generator.show(msg: msg, type: .information)
            try await Task.sleep(nanoseconds: 100_000_000)
        }

        XCTAssertEqual(generator.popUps.count, 3)
        XCTAssertEqual(generator.popUps.map(\.msg), ["five", "four", "three"])
    }

    // MARK: - 4. clearAll Mid-Sequence (e.g. user signs out while toasts are showing)

    func test_clearAllMidSequence_thenNewShow_startsCleanQueue() async throws {
        generator.show(msg: "Stale toast 1", type: .notification)
        generator.show(msg: "Stale toast 2", type: .warning)
        try await Task.sleep(nanoseconds: 200_000_000)
        XCTAssertEqual(generator.popUps.count, 2)

        generator.clearAll()
        try await Task.sleep(nanoseconds: 150_000_000)
        XCTAssertTrue(generator.popUps.isEmpty)

        generator.show(msg: "Fresh toast", type: .notification)
        try await Task.sleep(nanoseconds: 150_000_000)

        XCTAssertEqual(generator.popUps.count, 1)
        XCTAssertEqual(generator.popUps.first?.msg, "Fresh toast")
    }

    // MARK: - 5. Every centralPopupType Renders With a Consistent (color, animation) Pair

    func test_everyPopupType_showThroughGenerator_preservesItsThemeAndAnimation() async throws {
        let cases: [(centralPopupType, expectedAnimation: String)] = [
            (.notification, "ring"),
            (.warning, "warning"),
            (.error, "alert"),
            (.information, "speaker")
        ]

        for (type, expectedAnimation) in cases {
            generator.clearAll()
            try await Task.sleep(nanoseconds: 100_000_000)
            generator.show(msg: "msg-\(expectedAnimation)", type: type)
            try await Task.sleep(nanoseconds: 150_000_000)

            guard let shown = generator.popUps.first else {
                return XCTFail("Expected a popup for \(expectedAnimation)")
            }
            XCTAssertEqual(shown.type.animationName, expectedAnimation)
        }
    }
}
