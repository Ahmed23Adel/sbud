//
//  JoinStateTests.swift
//  sbudTests
//

import XCTest
@testable import sbud

final class JoinStateTests: XCTestCase {

    // MARK: - isDisabled

    func test_isDisabled_idle_isFalse()      { XCTAssertFalse(JoinState.idle.isDisabled) }
    func test_isDisabled_withdrawn_isFalse() { XCTAssertFalse(JoinState.withdrawn.isDisabled) }
    func test_isDisabled_rejected_isFalse()  { XCTAssertFalse(JoinState.rejected.isDisabled) }
    func test_isDisabled_left_isFalse()      { XCTAssertFalse(JoinState.left.isDisabled) }

    func test_isDisabled_pending_isTrue()              { XCTAssertTrue(JoinState.pending.isDisabled) }
    func test_isDisabled_confirmed_isTrue()            { XCTAssertTrue(JoinState.confirmed.isDisabled) }
    func test_isDisabled_full_isTrue()                 { XCTAssertTrue(JoinState.full.isDisabled) }
    func test_isDisabled_waitlisted_isTrue()           { XCTAssertTrue(JoinState.waitlisted(position: 1).isDisabled) }

    // MARK: - labelText

    func test_labelText_idle_isJoinActivity()      { XCTAssertEqual(JoinState.idle.labelText, "Join Activity") }
    func test_labelText_withdrawn_isJoinActivity() { XCTAssertEqual(JoinState.withdrawn.labelText, "Join Activity") }
    func test_labelText_left_isJoinActivity()      { XCTAssertEqual(JoinState.left.labelText, "Join Activity") }
    func test_labelText_pending_isRequestSent()    { XCTAssertEqual(JoinState.pending.labelText, "Request Sent") }
    func test_labelText_confirmed_isJoined()       { XCTAssertEqual(JoinState.confirmed.labelText, "Joined ✓") }
    func test_labelText_rejected_isRejected()      { XCTAssertEqual(JoinState.rejected.labelText, "Rejected") }
    func test_labelText_full_isEventFull()         { XCTAssertEqual(JoinState.full.labelText, "Event Full") }

    func test_labelText_waitlisted_includesPosition() {
        XCTAssertEqual(JoinState.waitlisted(position: 3).labelText, "Waitlist #3")
    }

    func test_labelText_waitlisted_positionZero() {
        XCTAssertEqual(JoinState.waitlisted(position: 0).labelText, "Waitlist #0")
    }

    func test_labelText_waitlisted_largePosition() {
        XCTAssertEqual(JoinState.waitlisted(position: 99).labelText, "Waitlist #99")
    }

    // MARK: - iconName

    func test_iconName_idle_isDoor()      { XCTAssertEqual(JoinState.idle.iconName, "door.left.hand.open") }
    func test_iconName_withdrawn_isDoor() { XCTAssertEqual(JoinState.withdrawn.iconName, "door.left.hand.open") }
    func test_iconName_rejected_isDoor()  { XCTAssertEqual(JoinState.rejected.iconName, "door.left.hand.open") }
    func test_iconName_left_isDoor()      { XCTAssertEqual(JoinState.left.iconName, "door.left.hand.open") }
    func test_iconName_pending_isClock()  { XCTAssertEqual(JoinState.pending.iconName, "clock") }
    func test_iconName_waitlisted_isList() { XCTAssertEqual(JoinState.waitlisted(position: 1).iconName, "list.number") }
    func test_iconName_confirmed_isCheckmark() { XCTAssertEqual(JoinState.confirmed.iconName, "checkmark.circle.fill") }
    func test_iconName_full_isPersonXmark()    { XCTAssertEqual(JoinState.full.iconName, "person.fill.xmark") }

    // MARK: - canLeave

    func test_canLeave_onlyTrueForConfirmed() {
        XCTAssertTrue(JoinState.confirmed.canLeave)

        let nonLeaveStates: [JoinState] = [.idle, .pending, .waitlisted(position: 1),
                                           .rejected, .withdrawn, .left, .full]
        for state in nonLeaveStates {
            XCTAssertFalse(state.canLeave, "\(state) should not allow leave")
        }
    }

    // MARK: - canWithdraw

    func test_canWithdraw_pending_isTrue()          { XCTAssertTrue(JoinState.pending.canWithdraw) }
    func test_canWithdraw_waitlisted_isTrue()        { XCTAssertTrue(JoinState.waitlisted(position: 2).canWithdraw) }

    func test_canWithdraw_otherStates_areFalse() {
        let nonWithdrawStates: [JoinState] = [.idle, .confirmed, .rejected, .withdrawn, .left, .full]
        for state in nonWithdrawStates {
            XCTAssertFalse(state.canWithdraw, "\(state) should not allow withdraw")
        }
    }

    // MARK: - Equatable

    func test_waitlisted_samePosition_equal() {
        XCTAssertEqual(JoinState.waitlisted(position: 5), JoinState.waitlisted(position: 5))
    }

    func test_waitlisted_differentPosition_notEqual() {
        XCTAssertNotEqual(JoinState.waitlisted(position: 1), JoinState.waitlisted(position: 2))
    }

    func test_differentCases_notEqual() {
        XCTAssertNotEqual(JoinState.idle, JoinState.pending)
        XCTAssertNotEqual(JoinState.confirmed, JoinState.left)
    }
}
