//
//  MultipleDateLocationsHolderTests.swift
//  sbudTests
//

import XCTest
import FirebaseFirestore
@testable import sbud

final class MultipleDateLocationsHolderTests: XCTestCase {

    private var sut: MultipleDateLocationsHolder!

    override func setUp() {
        super.setUp()
        sut = MultipleDateLocationsHolder()
    }

    override func tearDown() {
        sut = nil
        super.tearDown()
    }

    // MARK: - Fixtures

    private func makeEntry(
        start: Date = Date(),
        end: Date = Date().addingTimeInterval(3600)
    ) -> DateLocations {
        DateLocations(
            startDateTime: start,
            endDateTime: end,
            locations: [GeoPoint(latitude: 45, longitude: 9)]
        )
    }

    // MARK: - Initial state

    func test_init_isEmpty() {
        XCTAssertTrue(sut.lst.isEmpty)
    }

    func test_init_startIndexIsZero() {
        XCTAssertEqual(sut.startIndex, 0)
    }

    func test_init_endIndexIsZero() {
        XCTAssertEqual(sut.endIndex, 0)
    }

    // MARK: - areFieldsValid

    func test_areFieldsValid_whenEmpty_returnsFalse() {
        XCTAssertFalse(sut.areFieldsValid())
    }

    func test_areFieldsValid_afterAppend_returnsTrue() {
        sut.append(makeEntry())
        XCTAssertTrue(sut.areFieldsValid())
    }

    func test_areFieldsValid_withMultipleItems_returnsTrue() {
        sut.append(makeEntry())
        sut.append(makeEntry())
        XCTAssertTrue(sut.areFieldsValid())
    }

    // MARK: - append

    func test_append_incrementsCount() {
        sut.append(makeEntry())
        XCTAssertEqual(sut.lst.count, 1)
    }

    func test_append_twice_countIsTwo() {
        sut.append(makeEntry())
        sut.append(makeEntry())
        XCTAssertEqual(sut.lst.count, 2)
    }

    // MARK: - subscript

    func test_subscript_returnsCorrectItem() {
        let now = Date()
        let entry = makeEntry(start: now)
        sut.append(entry)
        XCTAssertEqual(sut[0].startDateTime, now)
    }

    func test_subscript_multipleItems_secondItemCorrect() {
        let first = makeEntry(start: Date(timeIntervalSince1970: 1000))
        let second = makeEntry(start: Date(timeIntervalSince1970: 2000))
        sut.append(first)
        sut.append(second)
        XCTAssertEqual(sut[1].startDateTime.timeIntervalSince1970, 2000, accuracy: 0.001)
    }

    // MARK: - RandomAccessCollection

    func test_startIndex_afterAppend_isZero() {
        sut.append(makeEntry())
        XCTAssertEqual(sut.startIndex, 0)
    }

    func test_endIndex_afterTwoAppends_isTwo() {
        sut.append(makeEntry())
        sut.append(makeEntry())
        XCTAssertEqual(sut.endIndex, 2)
    }

    func test_collection_canIterateWithForEach() {
        sut.append(makeEntry(start: Date(timeIntervalSince1970: 100)))
        sut.append(makeEntry(start: Date(timeIntervalSince1970: 200)))

        var starts: [Double] = []
        for entry in sut {
            starts.append(entry.startDateTime.timeIntervalSince1970)
        }
        XCTAssertEqual(starts, [100, 200])
    }

    func test_collection_countMatchesLstCount() {
        sut.append(makeEntry())
        sut.append(makeEntry())
        sut.append(makeEntry())
        XCTAssertEqual(sut.count, sut.lst.count)
    }
}
