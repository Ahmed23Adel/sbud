//
//  FriendRepositoryTests.swift
//  sbudTests
//
//  Created by Riccardo Maria Cadario on 03/07/2026.
//

import XCTest
@testable import sbud

final class FriendRepositoryTests: XCTestCase {

    func test_friendRepository_canBeInstantiated() {
        
        let repo = FriendRepository()
        XCTAssertNotNil(repo)
    }
}
