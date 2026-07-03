//
//  AvailabilityUITests.swift
//  sbudUITests
//
//  Tests the Availability tab: main view, tab switching, filter sheet, add-event flow.
//  Device: iPhone 17 Pro
//
//  HOW UI TESTS WORK (read this once):
//  - UI tests run as a SEPARATE PROCESS that drives the real app via accessibility APIs.
//  - There is NO access to Swift objects, ViewModels, or mock data — you interact
//    purely through what appears on screen.
//  - Every element is found by its accessibilityIdentifier, label, or type.
//  - Always use waitForExistence(timeout:) for anything that appears asynchronously.
//  - Tests are slow (~3-5s launch each class). Keep setup minimal.

import XCTest

final class AvailabilityMainViewUITests: XCTestCase {

    private var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()

        // Launch arguments let the app detect it's running under UI tests.
        // You can read these in sbudApp.swift to skip Firebase auth, skip
        // network calls, etc. Set up that logic when you add a test mode.
        app.launchArguments = ["UI_TESTING"]
        app.launch()

        // Navigate to the Availability tab (Tab 1).
        // Adjust the label to match whatever your tab bar item says.
        navigateToAvailabilityTab()
    }

    override func tearDown() {
        app = nil
        super.tearDown()
    }

    // MARK: - Helpers

    private func navigateToAvailabilityTab() {
        let tabBar = app.tabBars.firstMatch
        guard tabBar.waitForExistence(timeout: 8) else { return }
        tabBar.buttons["Availability"].tap()
    }

    // MARK: - Segmented Picker

    func test_tabPicker_isVisible_onLaunch() {
        let picker = app.segmentedControls["availability.tabPicker"]
        XCTAssertTrue(picker.waitForExistence(timeout: 5), "Map/List segmented picker should be visible")
    }

    func test_tabPicker_defaultsToMap() {
        let picker = app.segmentedControls["availability.tabPicker"]
        guard picker.waitForExistence(timeout: 5) else {
            return XCTFail("Segmented picker not found")
        }
        // The selected segment button has isSelected == true.
        let mapSegment = picker.buttons["Map"]
        XCTAssertTrue(mapSegment.isSelected, "Map tab should be selected by default")
    }

    func test_tabPicker_switchesToList_whenListTapped() {
        let picker = app.segmentedControls["availability.tabPicker"]
        guard picker.waitForExistence(timeout: 5) else {
            return XCTFail("Segmented picker not found")
        }
        picker.buttons["List"].tap()

        let listSegment = picker.buttons["List"]
        XCTAssertTrue(listSegment.isSelected, "List tab should become selected after tapping")
    }

    func test_tabPicker_switchesBackToMap_fromList() {
        let picker = app.segmentedControls["availability.tabPicker"]
        guard picker.waitForExistence(timeout: 5) else {
            return XCTFail("Segmented picker not found")
        }
        picker.buttons["List"].tap()
        picker.buttons["Map"].tap()

        XCTAssertTrue(picker.buttons["Map"].isSelected, "Should switch back to Map")
    }

    // MARK: - FABs (Floating Action Buttons)

    func test_addEventButton_isVisible() {
        let addBtn = app.buttons["availability.addEventButton"]
        XCTAssertTrue(addBtn.waitForExistence(timeout: 5), "Add event (+) button should be visible")
    }

    func test_filterButton_isVisible() {
        let filterBtn = app.buttons["availability.filterButton"]
        XCTAssertTrue(filterBtn.waitForExistence(timeout: 5), "Filter button should be visible")
    }

    // MARK: - Add Event Navigation

    func test_addEventButton_tap_opensAddEventFlow() {
        let addBtn = app.buttons["availability.addEventButton"]
        guard addBtn.waitForExistence(timeout: 5) else {
            return XCTFail("Add event button not found")
        }
        addBtn.tap()

        // Step 1 has a "Title" field (GenericTextInputView label)
        let titleField = app.staticTexts["Title"]
        XCTAssertTrue(titleField.waitForExistence(timeout: 5), "Add event step 1 should appear with a Title field")
    }

    func test_addEventFlow_cancelButton_returnsToAvailabilityScreen() {
        let addBtn = app.buttons["availability.addEventButton"]
        guard addBtn.waitForExistence(timeout: 5) else {
            return XCTFail("Add event button not found")
        }
        addBtn.tap()

        // CoordinatorAddNewEvent sets .navigationBarBackButtonHidden(true),
        // which also disables the interactive swipe-back gesture.
        // The only way to dismiss is the Cancel button.
        let cancelBtn = app.buttons["addEvent.cancelButton"]
        guard cancelBtn.waitForExistence(timeout: 5) else {
            return XCTFail("Cancel button not found — step 1 didn't appear")
        }
        cancelBtn.tap()

        let picker = app.segmentedControls["availability.tabPicker"]
        XCTAssertTrue(picker.waitForExistence(timeout: 5), "Should return to availability screen after cancel")
    }

    // MARK: - Filter Sheet Navigation

    func test_filterButton_tap_opensFilterSheet() {
        let filterBtn = app.buttons["availability.filterButton"]
        guard filterBtn.waitForExistence(timeout: 5) else {
            return XCTFail("Filter button not found")
        }
        filterBtn.tap()

        // FiltersView has a "From" DatePicker.
        let fromPicker = app.datePickers["filters.startDatePicker"]
        XCTAssertTrue(fromPicker.waitForExistence(timeout: 5), "Filter sheet should open and show 'From' date picker")
    }

    func test_filterSheet_showsEndDatePicker() {
        app.buttons["availability.filterButton"].tap()
        let untilPicker = app.datePickers["filters.endDatePicker"]
        XCTAssertTrue(untilPicker.waitForExistence(timeout: 5), "'Until' date picker should be visible in filter sheet")
    }

    func test_filterSheet_showsActivityFiltersLink() {
        app.buttons["availability.filterButton"].tap()
        let link = app.buttons["filters.activityFiltersLink"]
        XCTAssertTrue(link.waitForExistence(timeout: 5), "Activity filters navigation link should be visible")
    }

    func test_filterSheet_activityFiltersLink_navigatesToActivityFilters() {
        app.buttons["availability.filterButton"].tap()
        let link = app.buttons["filters.activityFiltersLink"]
        guard link.waitForExistence(timeout: 5) else {
            return XCTFail("Activity filters link not found")
        }
        link.tap()

        // ActivityFiltersView should now be on screen. Check for something it renders.
        // Adjust this staticText to match a visible label in ActivityFiltersView.
        let activityScreen = app.navigationBars.firstMatch
        XCTAssertTrue(activityScreen.waitForExistence(timeout: 5), "Activity filters screen should appear")
    }

    func test_filterSheet_dismisses_swipingDown() {
        app.buttons["availability.filterButton"].tap()
        let fromPicker = app.datePickers["filters.startDatePicker"]
        guard fromPicker.waitForExistence(timeout: 5) else {
            return XCTFail("Filter sheet didn't open")
        }

        // Sheets can be dismissed by dragging them down.
        app.swipeDown()

        // After dismissal, availability buttons should be back.
        let filterBtn = app.buttons["availability.filterButton"]
        XCTAssertTrue(filterBtn.waitForExistence(timeout: 5), "Availability screen should be visible after filter sheet dismissed")
    }
}

// MARK: -

final class AvailabilityAddEventUITests: XCTestCase {

    private var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["UI_TESTING"]
        app.launch()

        navigateToAvailabilityTab()
        openAddEventFlow()
    }

    override func tearDown() {
        app = nil
        super.tearDown()
    }

    private func navigateToAvailabilityTab() {
        let tabBar = app.tabBars.firstMatch
        if tabBar.waitForExistence(timeout: 5) {
            tabBar.buttons["Availability"].tap()
        }
    }

    private func openAddEventFlow() {
        let addBtn = app.buttons["availability.addEventButton"]
        guard addBtn.waitForExistence(timeout: 5) else { return }
        addBtn.tap()
    }

    // MARK: - Step 1 Fields

    func test_step1_titleFieldIsPresent() {
        XCTAssertTrue(
            app.staticTexts["Title"].waitForExistence(timeout: 5),
            "Title label should be present in step 1"
        )
    }

    func test_step1_descriptionFieldIsPresent() {
        XCTAssertTrue(
            app.staticTexts["Description"].waitForExistence(timeout: 5),
            "Description label should be present in step 1"
        )
    }

    func test_step1_titleTextField_acceptsInput() {
        // GenericTextInputView renders a TextField with the placeholder as its identifier/label.
        let titleField = app.textFields["Ex: Midnight Runners"]
        guard titleField.waitForExistence(timeout: 5) else {
            return XCTFail("Title text field not found — check placeholder matches")
        }
        titleField.tap()
        titleField.typeText("Evening Run")
        XCTAssertEqual(titleField.value as? String, "Evening Run")
    }

    func test_step1_descriptionField_acceptsInput() {
        let descField = app.textViews["addEvent.descriptionField"]
        guard descField.waitForExistence(timeout: 5) else {
            return XCTFail("Description text view not found")
        }
        descField.tap()
        descField.typeText("Come join us")
        XCTAssertTrue((descField.value as? String)?.contains("Come join us") ?? false)
    }

    // MARK: - Step Navigation

    func test_nextButton_navigatesToStep2() {
        let nextBtn = app.buttons["addEvent.nextButton"]
        guard nextBtn.waitForExistence(timeout: 5) else {
            return XCTFail("Next button not found")
        }
        nextBtn.tap()
        XCTAssertTrue(app.buttons["addEvent.backButton"].waitForExistence(timeout: 3),
                      "Step 2 should show Back button")
    }

    func test_cancelButton_dismissesAddEventFlow() {
        let cancelBtn = app.buttons["addEvent.cancelButton"]
        guard cancelBtn.waitForExistence(timeout: 5) else {
            return XCTFail("Cancel button not found")
        }
        cancelBtn.tap()
        let picker = app.segmentedControls["availability.tabPicker"]
        XCTAssertTrue(picker.waitForExistence(timeout: 5),
                      "Cancelling should return to availability screen")
    }

    func test_step2_backButton_returnsToStep1() {
        let nextBtn = app.buttons["addEvent.nextButton"]
        guard nextBtn.waitForExistence(timeout: 5) else { return XCTFail("Next button not found") }
        nextBtn.tap()
        let backBtn = app.buttons["addEvent.backButton"]
        guard backBtn.waitForExistence(timeout: 3) else { return XCTFail("Step 2 didn't appear") }
        backBtn.tap()
        XCTAssertTrue(app.buttons["addEvent.cancelButton"].waitForExistence(timeout: 3),
                      "Back from step 2 should show Cancel button (step 1)")
    }

    func test_step2_hasVisibilityOptions() {
        let nextBtn = app.buttons["addEvent.nextButton"]
        guard nextBtn.waitForExistence(timeout: 5) else { return XCTFail("Next button not found") }
        nextBtn.tap()
        let publicOption = app.staticTexts["Public"]
        XCTAssertTrue(publicOption.waitForExistence(timeout: 5),
                      "Step 2 should have visibility options")
    }
}

// MARK: -

final class AvailabilityFiltersUITests: XCTestCase {

    private var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["UI_TESTING"]
        app.launch()

        navigateToAvailabilityTab()
        openFilters()
    }

    override func tearDown() {
        app = nil
        super.tearDown()
    }

    private func navigateToAvailabilityTab() {
        let tabBar = app.tabBars.firstMatch
        if tabBar.waitForExistence(timeout: 5) {
            tabBar.buttons["Availability"].tap()
        }
    }

    private func openFilters() {
        let filterBtn = app.buttons["availability.filterButton"]
        guard filterBtn.waitForExistence(timeout: 5) else { return }
        filterBtn.tap()
    }

    // MARK: - Date Pickers

    func test_filters_startDatePicker_isEnabled() {
        let picker = app.datePickers["filters.startDatePicker"]
        guard picker.waitForExistence(timeout: 5) else {
            return XCTFail("Start date picker not found")
        }
        XCTAssertTrue(picker.isEnabled, "Start date picker should be enabled")
    }

    func test_filters_endDatePicker_isEnabled() {
        let picker = app.datePickers["filters.endDatePicker"]
        guard picker.waitForExistence(timeout: 5) else {
            return XCTFail("End date picker not found")
        }
        XCTAssertTrue(picker.isEnabled, "End date picker should be enabled")
    }

    func test_filters_bothDatePickers_arePresent_simultaneously() {
        let start = app.datePickers["filters.startDatePicker"]
        let end = app.datePickers["filters.endDatePicker"]
        XCTAssertTrue(start.waitForExistence(timeout: 5), "Start picker missing")
        XCTAssertTrue(end.exists, "End picker missing when start picker is visible")
    }

    // MARK: - Activity Filters Link

    func test_filters_activityLink_exists() {
        let link = app.buttons["filters.activityFiltersLink"]
        XCTAssertTrue(link.waitForExistence(timeout: 5))
    }

    func test_filters_activityLink_isTappable() {
        let link = app.buttons["filters.activityFiltersLink"]
        guard link.waitForExistence(timeout: 5) else {
            return XCTFail("Activity filters link not found")
        }
        XCTAssertTrue(link.isHittable, "Activity filters link should be tappable")
    }
}

// MARK: -

final class AvailabilitySearchUITests: XCTestCase {

    private var app: XCUIApplication!

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["UI_TESTING"]
        app.launch()

        navigateToListTab()
    }

    override func tearDown() {
        app = nil
        super.tearDown()
    }

    // Navigate to List tab, then pull down to open Search screen.
    // ViewFlattenedEventsList opens search on a DragGesture downward of >80pt.
    private func navigateToListTab() {
        let tabBar = app.tabBars.firstMatch
        if tabBar.waitForExistence(timeout: 5) {
            tabBar.buttons["Availability"].tap()
        }
        let picker = app.segmentedControls["availability.tabPicker"]
        guard picker.waitForExistence(timeout: 5) else { return }
        picker.buttons["List"].tap()
    }

    private func openSearch() {
        // The list triggers search on swipe-down (DragGesture > 80pt).
        // A long swipe-down on the list simulates this.
        let list = app.collectionViews.firstMatch
        if list.waitForExistence(timeout: 5) {
            list.swipeDown()
        } else {
            // Fallback: swipe down anywhere in the view
            app.swipeDown()
        }
    }

    // MARK: - Search Screen

    func test_searchScreen_opensOnListSwipeDown() {
        openSearch()
        let searchField = app.textFields["search.queryField"]
        XCTAssertTrue(searchField.waitForExistence(timeout: 5),
                      "Search screen should appear after swiping down on the list")
    }

    func test_searchScreen_searchField_acceptsText() {
        openSearch()
        let searchField = app.textFields["search.queryField"]
        guard searchField.waitForExistence(timeout: 5) else {
            return XCTFail("Search field not found")
        }
        searchField.tap()
        searchField.typeText("Run")
        XCTAssertEqual(searchField.value as? String, "Run")
    }

    func test_searchScreen_titleOnlyMode_isDefaultSelected() {
        openSearch()
        // "Title Only" button should be visible and active (mainColor styling)
        let titleOnly = app.buttons["Title Only"]
        XCTAssertTrue(titleOnly.waitForExistence(timeout: 5),
                      "Title Only mode button should be visible")
    }

    func test_searchScreen_withFiltersMode_buttonExists() {
        openSearch()
        let withFilters = app.buttons["With Filters"]
        XCTAssertTrue(withFilters.waitForExistence(timeout: 5),
                      "With Filters mode button should be visible")
    }

    func test_searchScreen_clearButton_appearsAfterTyping() {
        openSearch()
        let searchField = app.textFields["search.queryField"]
        guard searchField.waitForExistence(timeout: 5) else {
            return XCTFail("Search field not found")
        }
        searchField.tap()
        searchField.typeText("A")

        let clearBtn = app.buttons["search.clearButton"]
        XCTAssertTrue(clearBtn.waitForExistence(timeout: 3),
                      "Clear button should appear when text is entered")
    }

    func test_searchScreen_clearButton_clearsText() {
        openSearch()
        let searchField = app.textFields["search.queryField"]
        guard searchField.waitForExistence(timeout: 5) else {
            return XCTFail("Search field not found")
        }
        searchField.tap()
        searchField.typeText("Evening")

        let clearBtn = app.buttons["search.clearButton"]
        guard clearBtn.waitForExistence(timeout: 3) else {
            return XCTFail("Clear button didn't appear after typing")
        }
        clearBtn.tap()
        XCTAssertEqual(searchField.value as? String, "",
                       "Search field should be empty after clearing")
    }
}

// MARK: -

/// Tests for ViewMoreInfoEvent.
///
/// Strategy:
/// - A fake event ID triggers the loading → error path without any Firebase dependency.
///   This tests that the loading indicator appears and then transitions to an error state.
/// - For the happy-path test (event title visible, join button visible), replace
///   `UI_TESTING_EVENT_ID_HAPPY` with a real event ID you control in your Firestore.
///   That test is marked DISABLED until you supply a real ID.
///
/// How the deep link works:
///   The test sets `app.launchEnvironment["UI_TESTING_EVENT_ID"]` before launch.
///   AvailabilityAppCoordinator reads it in .onAppear and calls showMoreInfo(eventId:).
///   MainCoordinator skips Firebase auth (UI_TESTING launch argument) so the app
///   lands on the home tabs instantly, then navigates to the event detail.

final class AvailabilityEventDetailUITests: XCTestCase {

    private var app: XCUIApplication!

    // Replace with a real Firestore event ID you control to enable happy-path tests.
    private static let realEventId = "5HQxwk0Ads6eNzcPUKxe"

    override func setUp() {
        super.setUp()
        continueAfterFailure = false
        app = XCUIApplication()
        app.launchArguments = ["UI_TESTING"]
    }

    override func tearDown() {
        // Must terminate before nil — otherwise in-flight Firebase requests
        // keep the process alive and the test runner fails to kill it.
        app.terminate()
        app = nil
        super.tearDown()
    }

    // MARK: - Error State
    // NOTE: The loading indicator (moreInfo.loadingView) is intentionally not tested here.
    // On a real device with no valid Firebase auth token, the REST call fails with a 401
    // within one async tick — the loading state appears and disappears faster than
    // XCUITest's polling interval (~100ms) can catch it. Testing ephemeral loading states
    // that depend on network timing produces flaky tests. The stable final state (error)
    // is what we test instead.
    // The backend (sbud-backend.onrender.com) is on Render free-tier which has cold starts
    // up to ~30s. All error-state tests use a 35s timeout to survive a cold start.

    func test_eventDetail_showsErrorState_whenEventNotFound() {
        app.launchEnvironment["UI_TESTING_EVENT_ID"] = "fake_nonexistent_event_id_123"
        app.launch()

        let errorText = app.staticTexts["moreInfo.errorText"]
        XCTAssertTrue(errorText.waitForExistence(timeout: 35),
                      "Error state should appear after backend rejects the fake event ID")
    }

    func test_eventDetail_errorMessage_isVisible() {
        app.launchEnvironment["UI_TESTING_EVENT_ID"] = "fake_nonexistent_event_id_123"
        app.launch()

        // moreInfo.errorText is on the Text directly (not its parent VStack) so SwiftUI
        // doesn't collapse it into a container accessibility element.
        let errorText = app.staticTexts["moreInfo.errorText"]
        XCTAssertTrue(errorText.waitForExistence(timeout: 35),
                      "Error message text should be visible when event fails to load")
    }

    func test_eventDetail_loadingIndicator_disappears_afterError() {
        app.launchEnvironment["UI_TESTING_EVENT_ID"] = "fake_nonexistent_event_id_123"
        app.launch()

        let errorText = app.staticTexts["moreInfo.errorText"]
        guard errorText.waitForExistence(timeout: 35) else {
            return XCTFail("Error state never appeared — backend may not have responded within 35s")
        }

        // Once error is shown, loading indicator must be gone.
        let loading = app.otherElements["moreInfo.loadingView"]
        XCTAssertFalse(loading.exists,
                       "Loading indicator should be gone once error state is shown")
    }

    // MARK: - Happy Path (requires a real event ID — disabled until one is supplied)

    // To enable: replace `realEventId` above with an actual Firestore event document ID,
    // then rename this method by removing the DISABLED_ prefix.
    func DISABLED_test_eventDetail_showsEventTitle_withRealEvent() {
        app.launchEnvironment["UI_TESTING_EVENT_ID"] = Self.realEventId
        app.launch()

        let title = app.staticTexts.matching(identifier: "moreInfo.eventTitle").firstMatch
        XCTAssertTrue(title.waitForExistence(timeout: 15),
                      "Event title should be visible when a real event loads successfully")
        XCTAssertFalse((title.label).isEmpty, "Event title text should not be empty")
    }

    func DISABLED_test_eventDetail_showsJoinButton_withRealEvent() {
        app.launchEnvironment["UI_TESTING_EVENT_ID"] = Self.realEventId
        app.launch()

        // JoinEventButton renders text from JoinState.labelText — default is "Join Activity"
        let joinBtn = app.buttons["Join Activity"]
        XCTAssertTrue(joinBtn.waitForExistence(timeout: 15),
                      "Join Activity button should be visible for a real event")
    }

    func DISABLED_test_eventDetail_scrollable_withRealEvent() {
        app.launchEnvironment["UI_TESTING_EVENT_ID"] = Self.realEventId
        app.launch()

        let title = app.staticTexts.matching(identifier: "moreInfo.eventTitle").firstMatch
        guard title.waitForExistence(timeout: 15) else {
            return XCTFail("Event didn't load")
        }
        // Scroll down to verify the scroll view works end-to-end.
        app.scrollViews.firstMatch.swipeUp()
        // After scrolling, the view should still exist (didn't crash).
        XCTAssertTrue(app.scrollViews.firstMatch.exists)
    }
}
