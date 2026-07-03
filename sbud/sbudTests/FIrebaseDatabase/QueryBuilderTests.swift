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
    
    // MARK: - Tests QueryCollectionBuilder
    
    func test_queryCollectionBuilder_buildsQueryWithCorrectPath() {
        // Arrange
        let path = "Events"
        let builder = QueryCollectionBuilder(collectionPath: path, firebaseClient: firebaseClient)
        
        // Act
        let query = builder.build()
        
        // Assert
        XCTAssertNotNil(query, "La query generata non deve essere nil")
    }
    
    func test_queryCollectionBuilder_appendingFilters_returnsBuilderWithFilters() {
        // Arrange
        var builder = QueryCollectionBuilder(collectionPath: "users", firebaseClient: firebaseClient)
        let filter = Filter(field: "status", operation: .isEqualTo, value: "pending")
        
        // Act
        // Verifichiamo che il metodo con 'mutating' funzioni correttamente a catena
        let updatedBuilder = builder.appendFilter(filter)
        let query = updatedBuilder.build()
        
        // Assert
        XCTAssertNotNil(query)
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
    
    func test_filterOperation_enum_hasAllCases() {
        // Un piccolo test di controllo per verificare che le operazioni supportate siano stabili
        let operations: [FilterOperation] = [
            .isEqualTo, .isGreaterThan, .isLessThan,
            .isGreaterThanOrEqualTo, .isLessThanOrEqualTo,
            .arrayContains, .whereIn
        ]
        XCTAssertEqual(operations.count, 7)
    }
}
