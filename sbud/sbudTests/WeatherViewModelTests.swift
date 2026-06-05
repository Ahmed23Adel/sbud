//
//  WeatherViewModelTests.swift
//  sbudTests
//

import XCTest
@testable import sbud

// MARK: - Mock

final class MockWeatherFetcher: WeatherFetching {
    var callCount = 0
    var lastURL: URL?
    var stubbedResult: Result<Data, Error> = .success(Data())

    func fetchData(from url: URL) async throws -> Data {
        callCount += 1
        lastURL = url
        switch stubbedResult {
        case .success(let d): return d
        case .failure(let e): throw e
        }
    }
}

// MARK: - Tests

final class WeatherViewModelTests: XCTestCase {

    private var mockFetcher: MockWeatherFetcher!
    private var sut: WeatherViewModel!

    override func setUp() {
        super.setUp()
        mockFetcher = MockWeatherFetcher()
        sut = WeatherViewModel(fetcher: mockFetcher)
    }

    override func tearDown() {
        sut = nil
        mockFetcher = nil
        super.tearDown()
    }

    // MARK: - clampEnd (static, pure)

    func test_clampEnd_endWithin24h_returnsOriginalEnd() {
        let start = Date(timeIntervalSince1970: 0)
        let end   = Date(timeIntervalSince1970: 3600) // 1 hour later
        XCTAssertEqual(WeatherViewModel.clampEnd(end, from: start), end)
    }

    func test_clampEnd_endExactly24h_returnsExact24h() {
        let start = Date(timeIntervalSince1970: 0)
        let end   = start.addingTimeInterval(86400)
        XCTAssertEqual(WeatherViewModel.clampEnd(end, from: start), end)
    }

    func test_clampEnd_endBeyond24h_clampedToStartPlus24h() {
        let start   = Date(timeIntervalSince1970: 0)
        let end     = start.addingTimeInterval(86401) // 1 second over
        let clamped = WeatherViewModel.clampEnd(end, from: start)
        XCTAssertEqual(clamped.timeIntervalSince1970, 86400, accuracy: 0.001)
    }

    func test_clampEnd_endFarFuture_clampedToStartPlus24h() {
        let start   = Date(timeIntervalSince1970: 1_000_000)
        let end     = start.addingTimeInterval(7 * 86400) // 7 days
        let clamped = WeatherViewModel.clampEnd(end, from: start)
        XCTAssertEqual(clamped.timeIntervalSinceReferenceDate,
                       start.addingTimeInterval(86400).timeIntervalSinceReferenceDate,
                       accuracy: 0.001)
    }

    func test_clampEnd_endBeforeStart_returnsEnd() {
        // min(end, start+86400) — if end < start then end wins
        let start = Date(timeIntervalSince1970: 1000)
        let end   = Date(timeIntervalSince1970: 500)
        XCTAssertEqual(WeatherViewModel.clampEnd(end, from: start), end)
    }

    // MARK: - buildURLString (static, pure)

    func test_buildURLString_containsLatitude() {
        let url = WeatherViewModel.buildURLString(lat: 45.5, lon: 9.0, startStr: "2026-01-01", endStr: "2026-01-02")
        XCTAssertTrue(url.contains("latitude=45.5"))
    }

    func test_buildURLString_containsLongitude() {
        let url = WeatherViewModel.buildURLString(lat: 45.5, lon: 9.0, startStr: "2026-01-01", endStr: "2026-01-02")
        XCTAssertTrue(url.contains("longitude=9.0"))
    }

    func test_buildURLString_containsStartDate() {
        let url = WeatherViewModel.buildURLString(lat: 0, lon: 0, startStr: "2026-06-01", endStr: "2026-06-02")
        XCTAssertTrue(url.contains("start_date=2026-06-01"))
    }

    func test_buildURLString_containsEndDate() {
        let url = WeatherViewModel.buildURLString(lat: 0, lon: 0, startStr: "2026-06-01", endStr: "2026-06-02")
        XCTAssertTrue(url.contains("end_date=2026-06-02"))
    }

    func test_buildURLString_containsRequiredFields() {
        let url = WeatherViewModel.buildURLString(lat: 0, lon: 0, startStr: "a", endStr: "b")
        XCTAssertTrue(url.contains("temperature_2m"))
        XCTAssertTrue(url.contains("precipitation_probability"))
        XCTAssertTrue(url.contains("weathercode"))
        XCTAssertTrue(url.contains("windspeed_10m"))
        XCTAssertTrue(url.contains("timeformat=unixtime"))
    }

    func test_buildURLString_isValidURL() {
        let str = WeatherViewModel.buildURLString(lat: 48.8, lon: 2.3, startStr: "2026-01-01", endStr: "2026-01-02")
        XCTAssertNotNil(URL(string: str))
    }

    // MARK: - parseData (static, pure)

    private func makeWeatherJSON(times: [Double] = [1_000_000]) -> Data {
        let timesStr = times.map { String($0) }.joined(separator: ",")
        let count = times.count
        let temps  = Array(repeating: "20.0", count: count).joined(separator: ",")
        let precip = Array(repeating: "30.0", count: count).joined(separator: ",")
        let wcode  = Array(repeating: "1.0",  count: count).joined(separator: ",")
        let wind   = Array(repeating: "10.0", count: count).joined(separator: ",")
        let json = """
        {"hourly":{"time":[\(timesStr)],"temperature_2m":[\(temps)],
        "precipitation_probability":[\(precip)],"weathercode":[\(wcode)],
        "windspeed_10m":[\(wind)]}}
        """
        return json.data(using: .utf8)!
    }

    func test_parseData_returnsCorrectNumberOfSlices() throws {
        let data = makeWeatherJSON(times: [1_000_000, 1_003_600, 1_007_200])
        let slices = try WeatherViewModel.parseData(data)
        XCTAssertEqual(slices.count, 3)
    }

    func test_parseData_setsCorrectTimestamp() throws {
        let data = makeWeatherJSON(times: [1_000_000])
        let slices = try WeatherViewModel.parseData(data)
        XCTAssertEqual(slices[0].time.timeIntervalSince1970, 1_000_000, accuracy: 0.001)
    }

    func test_parseData_setsCorrectTemp() throws {
        let data = makeWeatherJSON(times: [1_000_000])
        let slices = try WeatherViewModel.parseData(data)
        XCTAssertEqual(slices[0].temp, 20.0, accuracy: 0.001)
    }

    func test_parseData_invalidJSON_throws() {
        let data = "not json".data(using: .utf8)!
        XCTAssertThrowsError(try WeatherViewModel.parseData(data))
    }

    // MARK: - load — network error sets error state

    func test_load_networkError_setsErrorMessage() async {
        mockFetcher.stubbedResult = .failure(URLError(.notConnectedToInternet))
        await sut.load(lat: 45, lon: 9, start: Date(), end: Date().addingTimeInterval(3600))
        XCTAssertNotNil(sut.error)
        XCTAssertFalse(sut.isLoading)
    }

    func test_load_networkError_slicesEmpty() async {
        mockFetcher.stubbedResult = .failure(URLError(.notConnectedToInternet))
        await sut.load(lat: 45, lon: 9, start: Date(), end: Date().addingTimeInterval(3600))
        XCTAssertTrue(sut.slices.isEmpty)
    }

    func test_load_successfulResponse_populatesSlices() async {
        let data = makeWeatherJSON(times: [1_000_000, 1_003_600])
        mockFetcher.stubbedResult = .success(data)
        await sut.load(lat: 45, lon: 9, start: Date(), end: Date().addingTimeInterval(3600))
        XCTAssertEqual(sut.slices.count, 2)
    }

    func test_load_successfulResponse_isLoadingFalse() async {
        let data = makeWeatherJSON(times: [1_000_000])
        mockFetcher.stubbedResult = .success(data)
        await sut.load(lat: 45, lon: 9, start: Date(), end: Date().addingTimeInterval(3600))
        XCTAssertFalse(sut.isLoading)
    }

    func test_load_callsFetcherOnce() async {
        mockFetcher.stubbedResult = .failure(URLError(.unknown))
        await sut.load(lat: 45, lon: 9, start: Date(), end: Date().addingTimeInterval(3600))
        XCTAssertEqual(mockFetcher.callCount, 1)
    }

    // MARK: - load clamps the end date passed to URL

    func test_load_endBeyond24h_URLContainsClampedDate() async {
        mockFetcher.stubbedResult = .failure(URLError(.unknown))
        let start = Date(timeIntervalSince1970: 0)
        let end   = start.addingTimeInterval(7 * 86400) // 7 days
        await sut.load(lat: 0, lon: 0, start: start, end: end)

        // The URL sent to the fetcher must use the clamped (1-day) end, not 7 days
        guard let url = mockFetcher.lastURL?.absoluteString else {
            XCTFail("No URL captured")
            return
        }
        // start is 1970-01-01, end after clamp is also 1970-01-01 (same day)
        XCTAssertFalse(url.contains("1970-01-08"), "URL should not request 7 days ahead")
    }
}
