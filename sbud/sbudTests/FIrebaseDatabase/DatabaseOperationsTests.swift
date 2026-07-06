//
//  DatabaseOperationsTests.swift
//  sbudTests
//
//  Created by Riccardo Maria Cadario on 03/07/2026.
//

import XCTest
import FirebaseFirestore
@testable import sbud

final class DatabaseOperationsTests: XCTestCase {

    func test_filterStructure_initializesCorrectly() {
        // Arrange & Act
        let filter = Filter(field: "createdAt", operation: .isGreaterThan, value: "2026-01-01")
        
        // Assert
        XCTAssertEqual(filter.field, "createdAt")
        XCTAssertEqual(filter.operation, .isGreaterThan)
        XCTAssertEqual(filter.value as? String, "2026-01-01")
    }
    
    func test_orderByAggregate_initializesCorrectly() {
        // Arrange & Act
        let orderBy = OrderByAggregate(field: "title", descending: true)
        
        // Assert
        XCTAssertEqual(orderBy.field, "title")
        XCTAssertTrue(orderBy.descending)
    }
    
    func test_hostInvitationStatus_enum_rawValues() {
        
        XCTAssertEqual(HostInvitationStatus.pending.rawValue, "pending")
        XCTAssertEqual(HostInvitationStatus.accepted.rawValue, "accepted")
        XCTAssertEqual(HostInvitationStatus.rejected.rawValue, "rejected")
        XCTAssertEqual(HostInvitationStatus.notInvited.rawValue, "notInvited")
    }
    
    func test_usersEventStatus_colorAndIconMapping() {
    
        let proposedStatus = UsersEventStatus.proposed
        let confirmedStatus = UsersEventStatus.confirmed
        let completedStatus = UsersEventStatus.completed
        
        XCTAssertEqual(proposedStatus.icon, "clock")
        XCTAssertEqual(confirmedStatus.icon, "checkmark.seal.fill")
        XCTAssertEqual(completedStatus.icon, "flag.checkered")
    }
}
