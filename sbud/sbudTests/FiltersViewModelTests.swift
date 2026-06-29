//
//  FiltersViewModelTests.swift
//  sbudTests
//

import XCTest
import SwiftUI
@testable import sbud

final class FiltersViewModelTests: XCTestCase {

    // Helpers to build a sut from a live AvailabilityFiltersResults
    private func makeSUT(
        filters: AvailabilityFiltersResults = AvailabilityFiltersResults()
    ) -> (sut: FiltersViewModel, filters: AvailabilityFiltersResults) {
        // We need a @State-like mutable binding; use a box
        var boxed = filters
        let binding = Binding(get: { boxed }, set: { boxed = $0 })
        let sut = FiltersViewModel(availabilityFiltersResults: binding)
        return (sut, filters)
    }

    // MARK: - Init

    func test_init_selectedActivityIndex_matchesBindingValue() {
        let filters = AvailabilityFiltersResults()
        filters.selectedActivityIndex = 4
        let (sut, _) = makeSUT(filters: filters)
        XCTAssertEqual(sut.selectedActivityIndex, 4)
    }

    func test_init_selectedActivityIndex_defaultIsZero() {
        let (sut, _) = makeSUT()
        XCTAssertEqual(sut.selectedActivityIndex, 0)
    }

    func test_init_icons_comesFromConfig() {
        let (sut, _) = makeSUT()
        XCTAssertEqual(sut.icons, AvailabilityConfig.icons)
    }

    func test_init_activityNames_comesFromConfig() {
        let (sut, _) = makeSUT()
        XCTAssertEqual(sut.activityNames, AvailabilityConfig.activityNames)
    }

    func test_init_isWheelBig_defaultsFalse() {
        let (sut, _) = makeSUT()
        XCTAssertFalse(sut.isWheelBig)
    }

    // MARK: - selectedActivityType

    func test_selectedActivityType_index0_returnsRunning() {
        let (sut, _) = makeSUT()
        XCTAssertEqual(sut.selectedActivityType, .running)
    }

    func test_selectedActivityType_index1_returnsCycling() {
        let (sut, _) = makeSUT()
        sut.selectedActivityIndex = 1
        XCTAssertEqual(sut.selectedActivityType, .cycling)
    }

    func test_selectedActivityType_index2_returnsGym() {
        let (sut, _) = makeSUT()
        sut.selectedActivityIndex = 2
        XCTAssertEqual(sut.selectedActivityType, .gym)
    }

    func test_selectedActivityType_index3_returnsSkiing() {
        let (sut, _) = makeSUT()
        sut.selectedActivityIndex = 3
        XCTAssertEqual(sut.selectedActivityType, .skiing)
    }

    func test_selectedActivityType_index4_returnsSwimming() {
        let (sut, _) = makeSUT()
        sut.selectedActivityIndex = 4
        XCTAssertEqual(sut.selectedActivityType, .swimming)
    }

    func test_selectedActivityType_index5_returnsHiking() {
        let (sut, _) = makeSUT()
        sut.selectedActivityIndex = 5
        XCTAssertEqual(sut.selectedActivityType, .hiking)
    }

    func test_selectedActivityType_index6_returnsYoga() {
        let (sut, _) = makeSUT()
        sut.selectedActivityIndex = 6
        XCTAssertEqual(sut.selectedActivityType, .yoga)
    }

    func test_selectedActivityType_index7_returnsTennis() {
        let (sut, _) = makeSUT()
        sut.selectedActivityIndex = 7
        XCTAssertEqual(sut.selectedActivityType, .tennis)
    }

    func test_selectedActivityType_outOfRange_returnsRunning() {
        let (sut, _) = makeSUT()
        sut.selectedActivityIndex = 99
        XCTAssertEqual(sut.selectedActivityType, .running)
    }

    // MARK: - selectedActivityIndex didSet → syncs back to binding

    func test_settingSelectedActivityIndex_syncedToFiltersResults() {
        let filters = AvailabilityFiltersResults()
        var boxed = filters
        let binding = Binding(get: { boxed }, set: { boxed = $0 })
        let sut = FiltersViewModel(availabilityFiltersResults: binding)

        sut.selectedActivityIndex = 3
        // The didSet writes through the @Binding — binding.wrappedValue should now reflect 3
        XCTAssertEqual(binding.wrappedValue.selectedActivityIndex, 3)
    }

    func test_settingSelectedActivityIndex_updatesSelectedActivityType() {
        let (sut, _) = makeSUT()
        sut.selectedActivityIndex = 5
        XCTAssertEqual(sut.selectedActivityType, .hiking)
    }

    // MARK: - isWheelBig

    func test_isWheelBig_canBeSetToTrue() {
        let (sut, _) = makeSUT()
        sut.isWheelBig = true
        XCTAssertTrue(sut.isWheelBig)
    }

    func test_isWheelBig_canBeToggled() {
        let (sut, _) = makeSUT()
        sut.isWheelBig = true
        sut.isWheelBig = false
        XCTAssertFalse(sut.isWheelBig)
    }
}
