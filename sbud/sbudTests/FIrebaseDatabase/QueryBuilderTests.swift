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
    private let db = Firestore.firestore()

    override func setUp() {
        super.setUp()
        firebaseClient = FirebaseClient()
    }

    override func tearDown() {
        firebaseClient = nil
        super.tearDown()
    }

    private func makeCollectionBuilder(_ path: String = "Events") -> QueryCollectionBuilder {
        QueryCollectionBuilder(collectionPath: path, firebaseClient: firebaseClient)
    }

    private func makeGroupBuilder(_ id: String = "hosts") -> QueryCollectionGroupBuilder {
        QueryCollectionGroupBuilder(collectionGroupId: id, firebaseClient: firebaseClient)
    }

    // MARK: - QueryCollectionBuilder: ogni operatore

    func test_collectionBuilder_isEqualTo() {
        var b = makeCollectionBuilder()
        let q = b.appendFilter(Filter(field: "status", operation: .isEqualTo, value: "proposed")).build()
        XCTAssertEqual(q, db.collection("Events").whereField("status", isEqualTo: "proposed"))
    }

    func test_collectionBuilder_isGreaterThan() {
        var b = makeCollectionBuilder()
        let q = b.appendFilter(Filter(field: "capacity", operation: .isGreaterThan, value: 10)).build()
        XCTAssertEqual(q, db.collection("Events").whereField("capacity", isGreaterThan: 10))
    }

    func test_collectionBuilder_isLessThan() {
        var b = makeCollectionBuilder()
        let q = b.appendFilter(Filter(field: "capacity", operation: .isLessThan, value: 50)).build()
        XCTAssertEqual(q, db.collection("Events").whereField("capacity", isLessThan: 50))
    }

    func test_collectionBuilder_isGreaterThanOrEqualTo() {
        var b = makeCollectionBuilder()
        let q = b.appendFilter(Filter(field: "capacity", operation: .isGreaterThanOrEqualTo, value: 5)).build()
        XCTAssertEqual(q, db.collection("Events").whereField("capacity", isGreaterThanOrEqualTo: 5))
    }

    func test_collectionBuilder_isLessThanOrEqualTo() {
        var b = makeCollectionBuilder()
        let q = b.appendFilter(Filter(field: "capacity", operation: .isLessThanOrEqualTo, value: 100)).build()
        XCTAssertEqual(q, db.collection("Events").whereField("capacity", isLessThanOrEqualTo: 100))
    }

    func test_collectionBuilder_arrayContains() {
        var b = makeCollectionBuilder()
        let q = b.appendFilter(Filter(field: "tags", operation: .arrayContains, value: "running")).build()
        XCTAssertEqual(q, db.collection("Events").whereField("tags", arrayContains: "running"))
    }

    func test_collectionBuilder_whereIn_isNotImplemented_returnsUnfilteredQuery() {
        // whereIn non è implementato nel builder (TODO nel codice):
        // il filtro viene ignorato e la query resta quella base.
        var b = makeCollectionBuilder()
        let q = b.appendFilter(Filter(field: "id", operation: .whereIn, value: ["a", "b"])).build()
        XCTAssertEqual(q, db.collection("Events"))
    }

    // MARK: - QueryCollectionBuilder: composizione e limiti noti

    func test_collectionBuilder_multipleFilters_appliedInOrder() {
        var b = makeCollectionBuilder()
        b = b.appendFilter(Filter(field: "status", operation: .isEqualTo, value: "proposed"))
        b = b.appendFilter(Filter(field: "isPublic", operation: .isEqualTo, value: true))
        let q = b.build()

        XCTAssertEqual(q, db.collection("Events")
            .whereField("status", isEqualTo: "proposed")
            .whereField("isPublic", isEqualTo: true))
    }

    func test_collectionBuilder_noFilters_returnsPlainCollection() {
        XCTAssertEqual(makeCollectionBuilder("users").build(), db.collection("users"))
    }

    func test_collectionBuilder_limitAndOrderBy_areCurrentlyIgnoredByBuild() {
        // Comportamento attuale documentato: build() non applica limit/orderBy
        // (a differenza di QueryCollectionGroupBuilder). Segnalato al team.
        var b = makeCollectionBuilder()
        b = b.setLimit(10)
        b = b.setOrderBy(OrderByAggregate(field: "createdAt", descending: true))
        let q = b.build()

        XCTAssertEqual(q, db.collection("Events"))
    }

    // MARK: - QueryCollectionGroupBuilder: ogni operatore

    func test_groupBuilder_isEqualTo() {
        var b = makeGroupBuilder()
        let q = b.appendFilter(Filter(field: "status", operation: .isEqualTo, value: "pending")).build()
        XCTAssertEqual(q, db.collectionGroup("hosts").whereField("status", isEqualTo: "pending"))
    }

    func test_groupBuilder_isGreaterThan() {
        var b = makeGroupBuilder()
        let q = b.appendFilter(Filter(field: "count", operation: .isGreaterThan, value: 1)).build()
        XCTAssertEqual(q, db.collectionGroup("hosts").whereField("count", isGreaterThan: 1))
    }

    func test_groupBuilder_isLessThan() {
        var b = makeGroupBuilder()
        let q = b.appendFilter(Filter(field: "count", operation: .isLessThan, value: 9)).build()
        XCTAssertEqual(q, db.collectionGroup("hosts").whereField("count", isLessThan: 9))
    }

    func test_groupBuilder_isGreaterThanOrEqualTo() {
        var b = makeGroupBuilder()
        let q = b.appendFilter(Filter(field: "count", operation: .isGreaterThanOrEqualTo, value: 2)).build()
        XCTAssertEqual(q, db.collectionGroup("hosts").whereField("count", isGreaterThanOrEqualTo: 2))
    }

    func test_groupBuilder_isLessThanOrEqualTo() {
        var b = makeGroupBuilder()
        let q = b.appendFilter(Filter(field: "count", operation: .isLessThanOrEqualTo, value: 8)).build()
        XCTAssertEqual(q, db.collectionGroup("hosts").whereField("count", isLessThanOrEqualTo: 8))
    }

    func test_groupBuilder_arrayContains() {
        var b = makeGroupBuilder()
        let q = b.appendFilter(Filter(field: "tags", operation: .arrayContains, value: "x")).build()
        XCTAssertEqual(q, db.collectionGroup("hosts").whereField("tags", arrayContains: "x"))
    }

    func test_groupBuilder_whereIn_isNotImplemented() {
        var b = makeGroupBuilder()
        let q = b.appendFilter(Filter(field: "id", operation: .whereIn, value: ["a"])).build()
        XCTAssertEqual(q, db.collectionGroup("hosts"))
    }

    // MARK: - QueryCollectionGroupBuilder: limit e orderBy (qui SONO applicati)

    func test_groupBuilder_appliesLimit() {
        var b = makeGroupBuilder()
        b = b.setLimit(10)
        XCTAssertEqual(b.build(), db.collectionGroup("hosts").limit(to: 10))
    }

    func test_groupBuilder_appliesOrderByDescending() {
        var b = makeGroupBuilder()
        b = b.setOrderBy(OrderByAggregate(field: "invitedAt", descending: true))
        XCTAssertEqual(b.build(), db.collectionGroup("hosts").order(by: "invitedAt", descending: true))
    }

    func test_groupBuilder_appliesOrderByAscending() {
        var b = makeGroupBuilder()
        b = b.setOrderBy(OrderByAggregate(field: "invitedAt", descending: false))
        XCTAssertEqual(b.build(), db.collectionGroup("hosts").order(by: "invitedAt", descending: false))
    }

    func test_groupBuilder_filterLimitAndOrder_combined() {
        var b = makeGroupBuilder()
        b = b.appendFilter(Filter(field: "status", operation: .isEqualTo, value: "pending"))
        b = b.setLimit(5)
        b = b.setOrderBy(OrderByAggregate(field: "invitedAt", descending: false))

        XCTAssertEqual(b.build(), db.collectionGroup("hosts")
            .whereField("status", isEqualTo: "pending")
            .limit(to: 5)
            .order(by: "invitedAt", descending: false))
    }

    // MARK: - Modelli

    func test_filter_storesFieldOperationValue() {
        let f = Filter(field: "createdAt", operation: .isGreaterThan, value: "2026-01-01")
        XCTAssertEqual(f.field, "createdAt")
        XCTAssertEqual(f.operation, .isGreaterThan)
        XCTAssertEqual(f.value as? String, "2026-01-01")
    }

    func test_orderByAggregate_storesFieldAndDirection() {
        let o = OrderByAggregate(field: "title", descending: true)
        XCTAssertEqual(o.field, "title")
        XCTAssertTrue(o.descending)
    }
}
