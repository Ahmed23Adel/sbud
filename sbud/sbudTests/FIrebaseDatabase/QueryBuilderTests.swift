//
//  QueryBuilderTests.swift
//  sbudTests
//
//  Created by Riccardo Maria Cadario on 02/07/2026.
//

import XCTest
import FirebaseFirestore
@testable import sbud

final class QueryBuilderTests: XCTestCase {
    
    var firebaseClient: FirebaseClient!
    
    override func setUp() {
        super.setUp()
        // Inizializziamo il client.
        // Nota: Se Firebase non è inizializzato nel target dei test, Firestore.firestore() potrebbe sollevare un'eccezione.
        // Se dovesse succedere, ti mostrerò come inserire un piccolo finto client o configurare Firebase nei test.
        firebaseClient = FirebaseClient()
    }
    
    override func tearDown() {
        firebaseClient = nil
        super.tearDown()
    }
    //
    func test_queryCollectionBuilder_appliesFilterCorrectly() {
        var builder = QueryCollectionBuilder(collectionPath: "users", firebaseClient: firebaseClient)
        let filter = Filter(field: "status", operation: .isEqualTo, value: "pending")

        let query = builder.appendFilter(filter).build()

        let expected = Firestore.firestore()
            .collection("users")
            .whereField("status", isEqualTo: "pending")
        XCTAssertEqual(query, expected)
    }
    //
    func test_queryCollectionGroupBuilder_appliesLimitCorrectly() {
        var builder = QueryCollectionGroupBuilder(collectionGroupId: "hostInvitations", firebaseClient: firebaseClient)
        builder = builder.setLimit(10)

        let query = builder.build()

        let expected = Firestore.firestore()
            .collectionGroup("hostInvitations")
            .limit(to: 10)
        XCTAssertEqual(query, expected)
    }
    
    // MARK: - Tests QueryCollectionGroupBuilder
    
    func test_queryCollectionGroupBuilder_buildsQueryGroup() {
        // Arrange
        let groupId = "hostInvitations"
        var builder = QueryCollectionGroupBuilder(collectionGroupId: groupId, firebaseClient: firebaseClient)
        
        // Act
        builder = builder.setLimit(10)
        let query = builder.build()
        
        // Assert
        XCTAssertNotNil(query)
    }
    
}
